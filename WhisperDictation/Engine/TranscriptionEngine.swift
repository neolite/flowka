import Foundation

/// Движок распознавания речи, абстрагированный от конкретной реализации
/// (whisper.cpp или Parakeet TDT v3 через FluidAudio).
///
/// Выделен из монолита `WhisperBridge`, чтобы `DictationEngine` мог работать с
/// любым бэкендом за одинаковым интерфейсом. Сигнатура `transcribe` намеренно
/// повторяет существующие вызовы whisper — рефактор аддитивный, поведение
/// whisper НЕ меняется.
///
/// Отмена. Оба движка сообщают об отмене одним и тем же способом —
/// `throw WhisperError.cancelled`, — так что оба места в `DictationEngine`,
/// ловящие `WhisperError where error.isCancellation`, работают для любого
/// бэкенда без изменений. `CancellationFlag` (объявлен в `WhisperBridge.swift`)
/// — общий примитив: whisper опрашивает его в abort-callback, FluidAudio
/// проверяет до и после инференса (у CoreML нет abort-callback, но
/// по-чанковый live-путь и так отменяется между чанками).
protocol TranscriptionEngine: AnyObject, Sendable {
    /// Прогрев (JIT Metal-шейдеров у whisper). Для CoreML-движка — опционален.
    func warmup() async

    /// Транскрибировать буфер Float-сэмплов 16 кГц mono.
    ///
    /// - Parameters:
    ///   - audioBuffer: сэмплы 16 кГц mono.
    ///   - prompt: стилевой/словарный промпт. whisper использует его как
    ///     `initial_prompt`; у Parakeet v3 API промпта нет — движок игнорирует
    ///     строку и опирается на CTC-boost собственного словаря.
    ///   - language: код языка (`ru`, `en`, `auto`).
    ///   - cancelFlag: внешний флаг отмены; при `nil` каждый вызов получает свой.
    ///   - vad: применять внутренний VAD движка (whisper). Для FluidAudio не
    ///     используется — чанки уже обрезаны сегментером.
    ///   - onSegment: колбэк на каждый декодированный сегмент. whisper зовёт его
    ///     потоково по мере декода; FluidAudio — один раз с полным текстом чанка.
    /// - Returns: полный текст транскрипции (trimmed).
    /// - Throws: `WhisperError.cancelled` при отмене; иную ошибку — при сбое.
    func transcribe(
        audioBuffer: [Float],
        prompt: String,
        language: String,
        cancelFlag: CancellationFlag?,
        vad: Bool,
        onSegment: (@Sendable (String) -> Void)?
    ) async throws -> String

    /// Запросить отмену текущего инференса (идемпотентно, безопасно из любого потока).
    func cancelTranscription()

    /// Освободить ресурсы движка перед выходом. Для whisper это критично
    /// (ggml roняет assert на Metal-ресурсах при exit); для CoreML — best-effort.
    func shutdown()
}
