import Foundation

#if canImport(FluidAudio)
import FluidAudio

/// Движок Parakeet TDT v3 через FluidAudio (CoreML).
///
/// Живёт РЯДОМ с whisper за тумблером `AppSettings.asrEngine`. Точнее whisper на
/// русском (спайк: 19.3% vs 26.9% WER), ~20-40x realtime. Модель (~470МБ+)
/// качается с HuggingFace при первом запуске и кэшируется в
/// `~/Library/Application Support/FluidAudio`.
///
/// Модель грузится ОДИН раз в `make(...)`, инференс на чанк ~0.2-0.5с. Живой
/// путь `DictationEngine` кормит движок по-чанково, ровно как whisper.
///
/// Весь файл под `#if canImport(FluidAudio)`: голая swiftc-сборка `make app`
/// (без SPM) FluidAudio не видит — файл там компилируется в пустоту, whisper-путь
/// не затрагивается. Сборка с пакетом (xcodebuild + project.yml) включает v3.
final class FluidAudioEngine: TranscriptionEngine, @unchecked Sendable {

    private let manager: AsrManager
    private let vocabTerms: [String]
    private var decoderLayers: Int = 2

    // Отмена: single-flight, как в WhisperBridge. У CoreML нет abort-callback,
    // поэтому проверяем флаг ДО и ПОСЛЕ инференса; по-чанковый live-путь и так
    // отменяется между чанками (по одной фразе на вызов).
    private let cancelLock = NSLock()
    private var activeCancelFlag: CancellationFlag?

    // FluidAudio отклоняет клипы ≤150мс (`invalidAudioData`). Гейтим с запасом
    // (200мс = 3200 сэмплов @16кГц) и пропускаем такой клип с логом, не роняя
    // пайплайн. `residualMeetsMinimum` (~300мс) уже частично это покрывает.
    private static let minSamples = 3200

    // MARK: - CTC vocab boost (best-effort)

    private var boostVocab: CustomVocabularyContext?
    private var spotter: CtcKeywordSpotter?
    private var rescorer: VocabularyRescorer?
    private var boostCbw: Float = 0
    private var boostMinSimilarity: Float = 0
    private var boostMarginSeconds: Double = 0

    private init(manager: AsrManager, vocabTerms: [String]) {
        self.manager = manager
        self.vocabTerms = vocabTerms
    }

    // MARK: - Загрузка (один раз)

    /// Лежат ли модели v3 уже в кэше FluidAudio. Нужно онбордингу: без этого
    /// он считает «модель есть» только по whisper-каталогу `ModelManager`, и
    /// пользователь с готовым Parakeet проходил бы загрузку заново.
    static var isModelDownloaded: Bool {
        AsrModels.modelsExist(at: AsrModels.defaultCacheDirectory(for: .v3), version: .v3)
    }


    /// Скачивает (при необходимости) и загружает модель v3, конфигурирует
    /// CTC-boost словаря и возвращает готовый движок. Тяжёлая операция — звать
    /// один раз при инициализации движка, НЕ на каждую фразу.
    static func make(
        vocabTerms: [String],
        onProgress: (@Sendable (EngineLoadProgress) -> Void)? = nil
    ) async throws -> FluidAudioEngine {
        fputs("[FluidAudioEngine] Loading Parakeet v3 models…\n", stderr)
        // Первый запуск качает ~470МБ с HuggingFace (нужна сеть); далее берётся
        // из кэша `~/Library/Application Support/FluidAudio`. До первого ответа
        // HF размер неизвестен, поэтому начинаем с неопределённой фазы, иначе
        // экран онбординга секундами висел бы на пустом нуле.
        // Сырые события пакета склеивает трекер: доля там считается на каждую
        // модель отдельно и без него полоса откатывалась бы назад.
        // Именно V3-набор, а не `AsrModels.requiredModelNames`: то — список для
        // v2, и совпадение по длине (обе четвёрки) держится только до тех пор,
        // пока пакет не поменяет состав одной из версий. Знаменатель у полосы
        // должен приходить оттуда же, откуда список компилируемых моделей.
        // Точность энкодера на количество не влияет — в наборе всегда 4 имени.
        let tracker = EngineLoadProgressTracker(
            totalModels: ModelNames.ASR.requiredModelsV3().count
        )
        onProgress?(tracker.update(phase: .listing, rawFraction: nil))
        let models = try await AsrModels.downloadAndLoad(
            version: .v3,
            progressHandler: { progress in
                onProgress?(
                    tracker.update(
                        phase: Self.rawPhase(from: progress.phase),
                        rawFraction: progress.fractionCompleted
                    )
                )
            }
        )
        let config = ASRConfig(
            tdtConfig: TdtConfig(blankId: AsrModelVersion.v3.blankId),
            encoderHiddenSize: AsrModelVersion.v3.encoderHiddenSize
        )
        let manager = AsrManager(config: config)
        try await manager.loadModels(models)

        let engine = FluidAudioEngine(manager: manager, vocabTerms: vocabTerms)
        engine.decoderLayers = await manager.decoderLayerCount
        // Догрузка CTC-моделей идёт вслепую: у `CtcModels.downloadAndLoad`
        // прогресс-хендлера в FluidAudio нет. Показываем честную неопределённую
        // фазу вместо застывшего «100%».
        onProgress?(tracker.update(phase: .configuringVocabulary, rawFraction: nil))
        await engine.configureBoostingIfPossible()
        fputs("[FluidAudioEngine] Ready (decoderLayers: \(engine.decoderLayers))\n", stderr)
        return engine
    }

    /// Перевод фаз FluidAudio в наш UI-тип. Единственное место, где типы
    /// библиотеки просачиваются наружу движка, — дальше по коду только
    /// `EngineLoadProgress`, который собирается и без FluidAudio.
    private static func rawPhase(from phase: DownloadPhase) -> EngineLoadProgressTracker.RawPhase {
        switch phase {
        case .listing:
            return .listing
        case .downloading(let completedFiles, let totalFiles):
            return .downloading(completed: completedFiles, total: totalFiles)
        case .compiling(let modelName):
            return .compiling(model: modelName)
        }
    }

    /// Настраивает CTC keyword-spotter + rescorer из наших термов. Требует
    /// ВТОРОЙ модели (CtcModels, качается с HF при первом запуске). Best-effort:
    /// любой сбой оставляет `rescorer == nil` — движок работает на чистом v3.
    private func configureBoostingIfPossible() async {
        guard !vocabTerms.isEmpty else { return }
        do {
            // `loadWithCtcTokens` читает файл (simple one-term-per-line или JSON);
            // пишем наши термы во временный файл.
            let tmp = FileManager.default.temporaryDirectory
                .appendingPathComponent("flowka-parakeet-vocab-\(UUID().uuidString).txt")
            try vocabTerms.joined(separator: "\n").write(to: tmp, atomically: true, encoding: .utf8)
            defer { try? FileManager.default.removeItem(at: tmp) }

            let (vocab, ctcModels) = try await CustomVocabularyContext.loadWithCtcTokens(from: tmp.path)
            let blankId = ctcModels.vocabulary.count
            let spotter = CtcKeywordSpotter(models: ctcModels, blankId: blankId)

            let vocabConfig = ContextBiasingConstants.rescorerConfig(forVocabSize: vocab.terms.count)
            let rescorerConfig = VocabularyRescorer.Config(
                shortTermCbwTaperPivot: ContextBiasingConstants.defaultShortTermCbwTaperPivot,
                spotterRescueMinSimilarity: ContextBiasingConstants.defaultSpotterRescueMinSimilarity,
                spotterRescueMultiWordMinSimilarity: ContextBiasingConstants.defaultSpotterRescueMultiWordMinSimilarity,
                spotterRescueEnabled: ContextBiasingConstants.defaultSpotterRescueEnabled
            )
            let rescorer = try await VocabularyRescorer.create(
                spotter: spotter,
                vocabulary: vocab,
                config: rescorerConfig,
                ctcModelDirectory: CtcModels.defaultCacheDirectory(for: ctcModels.variant)
            )

            self.boostVocab = vocab
            self.spotter = spotter
            self.rescorer = rescorer
            self.boostCbw = vocabConfig.cbw
            self.boostMinSimilarity = vocabConfig.minSimilarity
            self.boostMarginSeconds = ContextBiasingConstants.defaultMarginSeconds
            fputs("[FluidAudioEngine] Vocab boost configured (\(vocab.terms.count) terms)\n", stderr)
        } catch {
            fputs("[FluidAudioEngine] Vocab boost unavailable — plain v3: \(error)\n", stderr)
        }
    }

    // MARK: - TranscriptionEngine

    func warmup() async {
        // CoreML: первый инференс сам прогреет ANE/GPU; отдельный dummy-прогон
        // не даёт заметного выигрыша и требует валидного клипа (>150мс).
    }

    func transcribe(
        audioBuffer: [Float],
        prompt: String,
        language: String,
        cancelFlag externalFlag: CancellationFlag?,
        vad: Bool,
        onSegment: (@Sendable (String) -> Void)?
    ) async throws -> String {
        // `prompt` намеренно игнорируем: у API v3 нет initial_prompt, стилевой
        // промпт не переносим (см. TranscriptionEngine). Словарь работает через
        // CTC-boost, сконфигурированный на загрузке.
        let flag = externalFlag ?? CancellationFlag()
        setActiveCancelFlag(flag)
        defer { clearActiveCancelFlag(ifCurrent: flag) }

        if flag.isCancelled { throw WhisperError.cancelled }

        guard audioBuffer.count >= Self.minSamples else {
            fputs("[FluidAudioEngine] clip too short (\(audioBuffer.count) samples ≈ "
                + String(format: "%.0f", Double(audioBuffer.count) / 16.0) + "ms) — skipped\n", stderr)
            return ""
        }

        let started = CFAbsoluteTimeGetCurrent()
        var decoderState = TdtDecoderState.make(decoderLayers: decoderLayers)
        let lang = Language(rawValue: language)   // "auto"/неизвестный → nil (автоопределение)
        let result = try await manager.transcribe(audioBuffer, decoderState: &decoderState, language: lang)

        if flag.isCancelled { throw WhisperError.cancelled }

        var text = result.text
        if let boosted = await applyBoostIfConfigured(to: result, samples: audioBuffer) {
            text = boosted
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let elapsed = CFAbsoluteTimeGetCurrent() - started
        fputs("[FluidAudioEngine] \(String(format: "%.1f", Double(audioBuffer.count) / 16000.0))s decoded in "
            + "\(String(format: "%.2f", elapsed))s\n", stderr)

        // Один сегмент на чанк: у v3 нет потокового посегментного колбэка, но
        // пайплайн (коррекция + вставка) движок-агностичен — отдаём весь текст.
        if !trimmed.isEmpty { onSegment?(trimmed) }
        return trimmed
    }

    func cancelTranscription() {
        cancelLock.lock()
        let flag = activeCancelFlag
        cancelLock.unlock()
        flag?.cancel()
    }

    func shutdown() {
        // CoreML не роняет at-exit assert (в отличие от ggml/Metal у whisper),
        // поэтому освобождение best-effort: отменяем текущий инференс и просим
        // actor очиститься (может не успеть до exit() — это допустимо).
        cancelTranscription()
        let manager = self.manager
        Task { await manager.cleanup() }
    }

    // MARK: - Boost application

    private func applyBoostIfConfigured(to result: ASRResult, samples: [Float]) async -> String? {
        guard let spotter, let rescorer, let vocab = boostVocab,
              let timings = result.tokenTimings, !timings.isEmpty else { return nil }
        do {
            let spot = try await spotter.spotKeywordsWithLogProbs(
                audioSamples: samples,
                customVocabulary: vocab,
                minScore: nil
            )
            guard !spot.logProbs.isEmpty else { return nil }
            let out = rescorer.ctcTokenRescore(
                transcript: result.text,
                tokenTimings: timings,
                logProbs: spot.logProbs,
                frameDuration: spot.frameDuration,
                cbw: boostCbw,
                marginSeconds: boostMarginSeconds,
                minSimilarity: boostMinSimilarity
            )
            return out.wasModified ? out.text : nil
        } catch {
            fputs("[FluidAudioEngine] boost skipped this chunk: \(error)\n", stderr)
            return nil
        }
    }

    // MARK: - Cancel helpers (без удержания NSLock через suspension point)

    private func setActiveCancelFlag(_ flag: CancellationFlag) {
        cancelLock.lock(); activeCancelFlag = flag; cancelLock.unlock()
    }

    private func clearActiveCancelFlag(ifCurrent flag: CancellationFlag) {
        cancelLock.lock()
        if activeCancelFlag === flag { activeCancelFlag = nil }
        cancelLock.unlock()
    }
}
#endif
