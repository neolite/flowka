import AppKit
import CoreGraphics
import Foundation

/// @unchecked Sendable: the only stored state is an immutable `CGEventSource?` and
/// a serial `DispatchQueue`. All typing runs on that queue; no mutable shared state.
final class TextInjector: @unchecked Sendable {
    private let source: CGEventSource?
    private let typingQueue = DispatchQueue(label: "com.whisperdictation.typing", qos: .userInteractive)

    init() {
        source = CGEventSource(stateID: .hidSystemState)
    }

    // MARK: - Вставка через буфер обмена

    /// Основной способ доставки текста в активное приложение.
    ///
    /// Почему не синтетические клавиши: Apple прямо документирует, что
    /// приложение вправе проигнорировать Unicode-строку синтетического события
    /// клавиатуры. На практике это и происходит в Electron-приложениях и
    /// терминалах, а на длинной кириллице ещё и упирается в размер события.
    /// Буфер обмена + ⌘V — то, что работает везде.
    ///
    /// Прежний путь `type(text:)` сохранён как **явный** запасной вариант.
    /// Автоматически переключаться на него нельзя: если первая вставка всё же
    /// сработала, вторая продублирует текст.
    func paste(text: String) {
        guard !text.isEmpty else { return }

        typingQueue.async { [source] in
            let pasteboard = NSPasteboard.general
            let saved = Self.snapshot(of: pasteboard)

            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
            let ourChangeCount = pasteboard.changeCount

            // Зажатый модификатор превратит ⌘V во что-то другое: пользователь
            // держит хоткей (правый ⌥) и мог не успеть его отпустить.
            Self.waitForModifiersRelease()

            guard let down = CGEvent(keyboardEventSource: source, virtualKey: Self.vKeyCode, keyDown: true),
                  let up = CGEvent(keyboardEventSource: source, virtualKey: Self.vKeyCode, keyDown: false)
            else { return }

            down.flags = .maskCommand
            up.flags = .maskCommand
            down.post(tap: .cghidEventTap)
            up.post(tap: .cghidEventTap)

            // Восстановление буфера — эвристика: отправка ⌘V не подтверждает,
            // что приложение уже прочитало содержимое. Ждём, затем возвращаем
            // прежнее содержимое, но только если никто не писал в буфер после
            // нас — иначе мы затрём чужую запись.
            Thread.sleep(forTimeInterval: 0.15)
            guard pasteboard.changeCount == ourChangeCount else { return }
            Self.restore(saved, to: pasteboard)
        }
    }

    /// Виртуальный код клавиши `V` в раскладке ANSI. Он физический, от
    /// текущей раскладки не зависит, поэтому русская раскладка ⌘V не ломает.
    private static let vKeyCode: CGKeyCode = 9

    /// Снимок буфера: пары «тип → данные» для каждого элемента. Сами
    /// `NSPasteboardItem` после `clearContents()` становятся недействительными,
    /// поэтому сохраняем именно данные и позже создаём новые элементы.
    private static func snapshot(of pasteboard: NSPasteboard) -> [[NSPasteboard.PasteboardType: Data]] {
        (pasteboard.pasteboardItems ?? []).map { item in
            var contents: [NSPasteboard.PasteboardType: Data] = [:]
            for type in item.types {
                if let data = item.data(forType: type) { contents[type] = data }
            }
            return contents
        }
    }

    private static func restore(_ snapshot: [[NSPasteboard.PasteboardType: Data]], to pasteboard: NSPasteboard) {
        pasteboard.clearContents()
        guard !snapshot.isEmpty else { return }
        let items: [NSPasteboardItem] = snapshot.map { contents in
            let item = NSPasteboardItem()
            for (type, data) in contents { item.setData(data, forType: type) }
            return item
        }
        pasteboard.writeObjects(items)
    }

    /// Ждёт, пока пользователь отпустит модификаторы. Ограничено по времени:
    /// зависший модификатор не должен заблокировать вставку навсегда.
    private static func waitForModifiersRelease(timeout: TimeInterval = 0.5) {
        let deadline = Date().addingTimeInterval(timeout)
        let watched: CGEventFlags = [.maskCommand, .maskAlternate, .maskControl, .maskShift]
        while Date() < deadline {
            let flags = CGEventSource.flagsState(.combinedSessionState)
            if flags.intersection(watched).isEmpty { return }
            Thread.sleep(forTimeInterval: 0.01)
        }
    }

    /// Enqueue `text` to be typed at the current cursor position via CGEvent.
    /// Returns immediately — the actual typing happens asynchronously on a dedicated
    /// serial queue, so callers (e.g. the whisper decode thread delivering segments)
    /// are never blocked by the per-chunk `Thread.sleep`. The serial queue preserves
    /// submission order, so segments are typed in the order they were decoded.
    /// Call `flush()` to wait for all enqueued typing to finish.
    func type(text: String) {
        typingQueue.async { [source] in
            let chunks = Self.chunks(of: Array(text.utf16))

            for (i, chunk) in chunks.enumerated() {
                guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true),
                      let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) else {
                    continue
                }

                chunk.withUnsafeBufferPointer { ptr in
                    keyDown.keyboardSetUnicodeString(stringLength: chunk.count, unicodeString: ptr.baseAddress)
                    keyUp.keyboardSetUnicodeString(stringLength: chunk.count, unicodeString: ptr.baseAddress)
                }

                keyDown.post(tap: .cghidEventTap)
                keyUp.post(tap: .cghidEventTap)

                if i < chunks.count - 1 {
                    Thread.sleep(forTimeInterval: 0.005)
                }
            }
        }
    }

    /// Split a UTF-16 buffer into chunks of at most `maxChunk` code units for
    /// `keyboardSetUnicodeString`, **never splitting a surrogate pair across a chunk
    /// boundary**. A split pair would post a lone high surrogate followed by a lone low
    /// surrogate, which macOS renders as replacement characters instead of the intended
    /// emoji/astral glyph. Pure and static so the boundary math is unit-testable
    /// without CGEvent.
    static func chunks(of utf16: [UInt16], maxChunk: Int = 16) -> [[UInt16]] {
        guard maxChunk > 0 else { return utf16.isEmpty ? [] : [utf16] }
        var result: [[UInt16]] = []
        var offset = 0
        while offset < utf16.count {
            var end = min(offset + maxChunk, utf16.count)
            // If the last unit of this chunk is a high surrogate and a unit follows it
            // (its low surrogate), the pair straddles the boundary — back off by one so
            // the whole pair lands in the next chunk. The `end - 1 > offset` guard keeps
            // the chunk non-empty so progress is guaranteed even for pathological input.
            if end < utf16.count, Self.isHighSurrogate(utf16[end - 1]), end - 1 > offset {
                end -= 1
            }
            result.append(Array(utf16[offset..<end]))
            offset = end
        }
        return result
    }

    private static func isHighSurrogate(_ unit: UInt16) -> Bool {
        (0xD800...0xDBFF).contains(unit)
    }

    /// Barrier that blocks the caller until all previously-enqueued typing has
    /// finished. Because `typingQueue` is serial, a `sync {}` submitted after all the
    /// `async` type() work runs only once that work drains. MUST NOT be called on the
    /// main actor (it blocks). Intended to be called once, from the detached
    /// transcription task, before the done sound / return to idle.
    func flush() {
        typingQueue.sync {}
    }
}
