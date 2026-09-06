import AppKit
import SwiftUI

/// Плавающая капсула-индикатор поверх всех окон.
///
/// Критично: панель **не активирующаяся**. Обычное окно, получив фокус,
/// сделало бы активным наше приложение — и текст было бы некуда вставлять,
/// потому что целевое поле ввода потеряло бы фокус ровно в момент диктовки.
final class OverlayPanel: NSPanel {

    init(content: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 220, height: 56),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .statusBar
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        // Панель видна на всех рабочих столах и поверх полноэкранных приложений:
        // диктовать в них нужно так же, как в обычных.
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        ignoresMouseEvents = true
        isReleasedWhenClosed = false
        contentView = content
    }

    /// Панель не должна становиться ключевой или главной — иначе она заберёт
    /// фокус у целевого приложения, несмотря на `.nonactivatingPanel`.
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

// MARK: - Палитра

/// Палитра неизвестного происхождения, взятая как отправная точка из
/// `docs/design-reference/01-tokens.md`.
///
/// Имена токенов достались от источника, но выдавать их за дизайн-систему
/// Wispr Flow нельзя: архив, из которого они извлечены, сам себя объявляет
/// воссозданием сайта нейросетью и не претендует на точность. Подробности —
/// в README рядом с токенами. Практически это ничего не меняет: оверлей
/// нарисован свой, палитра просто подошла.
private enum Palette {
    /// `--base-color--vast`
    static let vast = Color(red: 0.102, green: 0.102, blue: 0.102)
    /// `--base-color--lumen` — тёплый ivory
    static let lumen = Color(red: 1.0, green: 1.0, blue: 0.922)
    /// `--base-color--dawn` — лиловый
    static let dawn = Color(red: 0.941, green: 0.843, blue: 1.0)
    /// `--base-color--glow` — оранжевый CTA
    static let glow = Color(red: 1.0, green: 0.663, blue: 0.275)
    /// `--base-color--flare` — коралловый, ошибки
    static let flare = Color(red: 1.0, green: 0.424, blue: 0.298)
}

// MARK: - Содержимое

struct OverlayView: View {
    let state: DictationState
    let level: Float
    let hasError: Bool

    var body: some View {
        HStack(spacing: 12) {
            indicator
            Text(caption)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Palette.lumen)
                .fixedSize()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Palette.vast.opacity(0.92))
                .overlay(
                    Capsule().strokeBorder(accent.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.28), radius: 18, y: 6)
        )
        .animation(.easeOut(duration: 0.18), value: state)
    }

    private var accent: Color {
        if hasError { return Palette.flare }
        switch state {
        case .recording: return Palette.glow
        case .processing, .typing: return Palette.dawn
        case .idle: return Palette.lumen
        }
    }

    private var caption: String {
        if hasError { return "Ошибка" }
        switch state {
        case .recording: return "Слушаю"
        case .processing: return "Распознаю"
        case .typing: return "Вставляю"
        case .idle: return "Готово"
        }
    }

    @ViewBuilder
    private var indicator: some View {
        if hasError {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.flare)
        } else {
            switch state {
            case .recording:
                LevelBars(level: level, color: accent)
            case .processing, .typing:
                PulsingDot(color: accent)
            case .idle:
                Circle()
                    .fill(accent.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

/// Пять полосок, реагирующих на громкость.
///
/// Полоски имеют разный вес относительно общего уровня: если бы все они
/// двигались одинаково, это читалось бы как один прыгающий блок, а не как
/// звук. Центральные реагируют сильнее — так выглядит привычная индикация.
private struct LevelBars: View {
    let level: Float
    let color: Color

    private static let weights: [CGFloat] = [0.55, 0.85, 1.0, 0.8, 0.5]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(Array(Self.weights.enumerated()), id: \.offset) { _, weight in
                Capsule()
                    .fill(color)
                    .frame(width: 3, height: height(for: weight))
            }
        }
        .frame(width: 27, height: 20)
        .animation(.easeOut(duration: 0.08), value: level)
    }

    private func height(for weight: CGFloat) -> CGFloat {
        let minHeight: CGFloat = 4
        let maxHeight: CGFloat = 20
        let scaled = CGFloat(level) * weight
        return minHeight + (maxHeight - minHeight) * min(1, scaled)
    }
}

/// Точка, пульсирующая во время распознавания. Показывает, что процесс идёт,
/// когда сказать о прогрессе нечего: whisper не сообщает долю выполнения.
private struct PulsingDot: View {
    let color: Color
    @State private var expanded = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .scaleEffect(expanded ? 1.0 : 0.6)
            .opacity(expanded ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true), value: expanded)
            .onAppear { expanded = true }
    }
}

// MARK: - Контроллер

/// Показывает и прячет оверлей по состоянию движка, позиционируя его внизу
/// экрана, где сейчас курсор — на многомониторной конфигурации капсула должна
/// появляться там, где человек работает, а не всегда на основном дисплее.
@MainActor
final class OverlayController {
    /// Синглтон, а не поле движка: панель принадлежит главному потоку, а
    /// `DictationEngine.init` вызывается вне него. Окно оверлея в приложении
    /// всё равно ровно одно.
    static let shared = OverlayController()

    private init() {}

    private var panel: OverlayPanel?
    private var hostingView: NSHostingView<OverlayView>?

    /// Отступ от нижнего края экрана.
    private let bottomInset: CGFloat = 120

    func update(state: DictationState, level: Float, hasError: Bool) {
        guard state != .idle || hasError else {
            hide()
            return
        }
        show(state: state, level: level, hasError: hasError)
    }

    private func show(state: DictationState, level: Float, hasError: Bool) {
        let view = OverlayView(state: state, level: level, hasError: hasError)

        if let hostingView {
            hostingView.rootView = view
        } else {
            let hosting = NSHostingView(rootView: view)
            hosting.frame = NSRect(x: 0, y: 0, width: 220, height: 56)
            let panel = OverlayPanel(content: hosting)
            self.hostingView = hosting
            self.panel = panel
        }

        guard let panel else { return }
        position(panel)
        // orderFrontRegardless, а не makeKeyAndOrderFront: второй активировал бы
        // приложение и отобрал фокус у поля ввода.
        panel.orderFrontRegardless()
    }

    private func position(_ panel: OverlayPanel) {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main
        guard let frame = screen?.visibleFrame else { return }

        let size = panel.frame.size
        panel.setFrameOrigin(NSPoint(
            x: frame.midX - size.width / 2,
            y: frame.minY + bottomInset
        ))
    }

    func hide() {
        panel?.orderOut(nil)
    }
}
