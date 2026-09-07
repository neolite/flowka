import Foundation

/// Склеивает поток событий FluidAudio в одну монотонную полосу.
///
/// Нужен из-за того, как пакет отдаёт прогресс: доля считается ОТДЕЛЬНО на
/// каждую модель, поэтому на прогретом кэше приходит `0.5 → 1.0`, потом снова
/// `0.5 → 1.0`, и так на все четыре модели. Привязав `ProgressView` к сырому
/// значению, мы бы четыре раза отмотали полосу назад — выглядит как сбой.
///
/// Отдельный тип, а не пара переменных в замыкании: это единственная часть
/// загрузки с настоящей логикой, и её можно прогнать тестом, не выходя в сеть
/// и не качая 470МБ.
///
/// Класс, а не структура: у экземпляра есть память между событиями, и живёт он
/// внутри одного `FluidAudioEngine.make`.
///
/// `@unchecked Sendable`: FluidAudio зовёт прогресс-хендлер «с неуказанной
/// очереди» (так написано в его же документации), поэтому состояние закрыто
/// замком вручную.
final class EngineLoadProgressTracker: @unchecked Sendable {

    private let lock = NSLock()

    /// Доля общей полосы, отданная скачиванию. Остальное — компиляция CoreML.
    /// Границу пришлось назначить: сквозного прогресса «скачал+скомпилировал»
    /// FluidAudio не даёт, а два разных индикатора подряд читаются хуже, чем
    /// один. При попадании в кэш стадия скачивания просто проскакивается.
    private static let downloadShare = 0.6

    private let totalModels: Int

    /// Имена уже виденных моделей. Пустое имя приходит как «эта готова» и новой
    /// моделью не считается.
    private var compiledModels: Set<String> = []

    /// Полоса не должна отматываться назад ни при каких входных данных.
    private var highWaterMark: Double = 0

    init(totalModels: Int) {
        self.totalModels = totalModels
    }

    /// Событие ровно в том виде, в каком его присылает FluidAudio: без счётчика
    /// моделей — его знает только трекер. Отдельный тип от `EngineLoadProgress.Phase`
    /// именно поэтому: на входе сырой факт, на выходе — то, что видит пользователь.
    enum RawPhase: Equatable {
        case listing
        case downloading(completed: Int, total: Int)
        case compiling(model: String)
        case configuringVocabulary
    }

    func update(phase: RawPhase, rawFraction: Double?) -> EngineLoadProgress {
        lock.lock()
        defer { lock.unlock() }
        switch phase {
        case .listing:
            return EngineLoadProgress(phase: .listing, fraction: nil)

        case .downloading(let completed, let total):
            // Кэш-хит: файлов к скачиванию нет, но событие всё равно приходит.
            // Показывать «Downloading model…» здесь — врать.
            guard total > 0 else {
                return EngineLoadProgress(phase: .listing, fraction: nil)
            }
            let fraction = advance(to: (rawFraction ?? 0) * Self.downloadShare)
            return EngineLoadProgress(
                phase: .downloading(completed: completed, total: total),
                fraction: fraction
            )

        case .compiling(let model):
            if !model.isEmpty { compiledModels.insert(model) }
            guard totalModels > 0 else {
                return EngineLoadProgress(
                    phase: .compiling(model: model, completed: compiledModels.count, total: 0),
                    fraction: nil
                )
            }
            // Список моделей мог вырасти в новой версии пакета — не даём доле
            // уехать за единицу.
            let done = min(Double(compiledModels.count) / Double(totalModels), 1)
            let fraction = advance(to: Self.downloadShare + (1 - Self.downloadShare) * done)
            return EngineLoadProgress(
                phase: .compiling(model: model, completed: compiledModels.count, total: totalModels),
                fraction: fraction
            )

        case .configuringVocabulary:
            // Прогресса у догрузки CTC-моделей в FluidAudio нет вообще, так что
            // здесь честная крутилка, а не полоса, замершая на 100%.
            return EngineLoadProgress(phase: .configuringVocabulary, fraction: nil)
        }
    }

    private func advance(to candidate: Double) -> Double {
        highWaterMark = max(highWaterMark, candidate)
        return highWaterMark
    }
}
