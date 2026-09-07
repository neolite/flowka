import Foundation

/// Ход подготовки ASR-движка к работе — то, что видит пользователь, пока
/// приложение молча качало ~470МБ и компилировало CoreML.
///
/// Свой тип, а не `FluidAudio.DownloadProgress`, по двум причинам. Первая
/// техническая: `make app` собирается голым swiftc без SPM, FluidAudio там
/// недоступен, и любой публичный API движка, упоминающий его типы, ломал бы
/// whisper-only сборку. Вторая важнее: у whisper своя загрузка через
/// `ModelManager`, и UI не должен знать, чья именно модель едет.
///
/// Подписи и нормализация доли живут здесь (а не в SwiftUI-вью), потому что
/// это единственная часть загрузки, которую можно проверить тестом, не выходя
/// в сеть.
struct EngineLoadProgress: Equatable {

    enum Phase: Equatable {
        /// Узнаём у HuggingFace список файлов — до этого момента общий размер неизвестен.
        case listing
        case downloading(completed: Int, total: Int)
        /// CoreML компилирует модель под конкретный Mac. Те самые ~30 секунд
        /// после скачивания, за которые приложение раньше выглядело зависшим.
        /// Счётчик проставляет `EngineLoadProgressTracker`: сам FluidAudio шлёт
        /// только имя очередной модели.
        case compiling(model: String, completed: Int, total: Int)
        /// Догрузка CTC-моделей для словарного boost. У `CtcModels.downloadAndLoad`
        /// в FluidAudio прогресс-хендлера нет, поэтому фаза всегда без процентов.
        case configuringVocabulary
    }

    let phase: Phase

    /// Доля выполнения в 0…1, либо `nil` — «неизвестно, крутим бесконечный индикатор».
    let fraction: Double?

    var isDeterminate: Bool { fraction != nil }

    init(phase: Phase, fraction: Double?) {
        self.phase = phase
        // Доля приходит из чужой библиотеки, а уезжает прямо в `ProgressView`,
        // который вне 0…1 рисует мусор, а на NaN — ломается.
        if case .configuringVocabulary = phase {
            self.fraction = nil
        } else if let fraction, fraction.isFinite {
            self.fraction = min(max(fraction, 0), 1)
        } else {
            self.fraction = nil
        }
    }

    var label: String {
        switch phase {
        case .listing:
            return "Preparing download…"
        case .downloading(let completed, let total):
            // Список файлов ещё не получен — «0 of 0 files» читалось бы как сбой.
            guard total > 0 else { return "Downloading model…" }
            return "Downloading model… \(completed) of \(total) files"
        case .compiling(_, let completed, let total):
            // Имя модели пользователю ничего не говорит — оно есть в фазе для логов.
            guard total > 0 else { return "Optimizing for this Mac…" }
            return "Optimizing for this Mac… \(completed) of \(total)"
        case .configuringVocabulary:
            return "Configuring vocabulary…"
        }
    }
}
