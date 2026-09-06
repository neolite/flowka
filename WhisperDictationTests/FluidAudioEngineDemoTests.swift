import XCTest
@testable import WhisperDictation

#if canImport(FluidAudio)
import FluidAudio
#endif

/// Демо v3-пути: грузит Parakeet v3 ОДИН раз через `FluidAudioEngine.make(...)`
/// и транскрибирует один файл, доказывая, что движок работает end-to-end на
/// реальной модели и нашем наборе термов.
///
/// Гейт по env `FLOWKA_V3_DEMO=1`: обычный `xcodebuild test` его ПРОПУСКАЕТ —
/// он зависит от ~560МБ модели в `~/Library/Application Support/FluidAudio`
/// (и, при первом запуске, от сети). Запуск демо:
///   FLOWKA_V3_DEMO=1 xcodebuild test -only-testing:WhisperDictationTests/FluidAudioEngineDemoTests …
final class FluidAudioEngineDemoTests: XCTestCase {

    func testV3TranscribesSampleClip() async throws {
        #if canImport(FluidAudio)
        guard ProcessInfo.processInfo.environment["FLOWKA_V3_DEMO"] == "1" else {
            throw XCTSkip("Установите FLOWKA_V3_DEMO=1 для демо v3 (грузит ~470МБ модель).")
        }

        let wavPath = "/private/tmp/claude-501/-Users-rafkat/8d0d4f24-a5f0-47ca-9e5d-92feb02df3f7/scratchpad/fluidaudio-spike/_live.wav"
        guard FileManager.default.fileExists(atPath: wavPath) else {
            throw XCTSkip("Нет тестового аудио: \(wavPath)")
        }

        // 16 кГц mono Float через конвертер FluidAudio — тот же путь, что в спайке.
        let samples = try AudioConverter().resampleAudioFile(URL(fileURLWithPath: wavPath))
        XCTAssertGreaterThan(samples.count, 0)

        let terms = AppSettings.parakeetVocabularyTerms(
            glossaryDefaultCanonicals: GlossaryCleaner.defaultRules.map(\.canonical),
            glossaryRuleCanonicals: [],
            customTerms: []
        )

        // Модель грузится ЗДЕСЬ, один раз.
        let engine = try await FluidAudioEngine.make(vocabTerms: terms)

        let text = try await engine.transcribe(
            audioBuffer: samples,
            prompt: "",           // v3 игнорирует стилевой промпт
            language: "ru",
            cancelFlag: nil,
            vad: false,
            onSegment: nil
        )
        print("[V3 DEMO] transcript: \(text)")
        XCTAssertFalse(
            text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            "v3 должен вернуть непустой текст на реальном клипе"
        )
        #else
        throw XCTSkip("FluidAudio не слинкован в этой сборке (голый swiftc).")
        #endif
    }

    /// Edge ≤150мс: очень короткий клип не должен ронять пайплайн — движок
    /// возвращает пустую строку (гейт по minSamples), а не бросает invalidAudioData.
    func testShortClipReturnsEmptyWithoutCrash() async throws {
        #if canImport(FluidAudio)
        guard ProcessInfo.processInfo.environment["FLOWKA_V3_DEMO"] == "1" else {
            throw XCTSkip("Установите FLOWKA_V3_DEMO=1 для демо v3.")
        }
        let engine = try await FluidAudioEngine.make(vocabTerms: [])
        let tiny = [Float](repeating: 0, count: 800)   // 50 мс @16кГц
        let text = try await engine.transcribe(
            audioBuffer: tiny, prompt: "", language: "ru",
            cancelFlag: nil, vad: false, onSegment: nil
        )
        XCTAssertEqual(text, "", "Короткий клип пропускается, пайплайн не падает")
        #else
        throw XCTSkip("FluidAudio не слинкован в этой сборке.")
        #endif
    }
}
