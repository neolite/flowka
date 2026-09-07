import SwiftUI

@main
struct WhisperDictationApp: App {
    @State private var engine: DictationEngine

    init() {
        let engine = DictationEngine()
        _engine = State(initialValue: engine)

        // Free whisper's Metal-backed contexts before exit(): NSApplication's
        // terminate path never runs Swift deinits, and ggml aborts at exit
        // (GGML_ASSERT in ggml_metal_rsets_free) if Metal resources are still
        // alive when its static device registry is destroyed. Posted on the
        // main thread; the engine lives for the whole process, so the observer
        // is never removed.
        //
        // Живёт здесь, а не в самом движке: `NSApplication` — это App-слой, и
        // из-за одной этой подписки `DictationEngine` тянул `import Cocoa`.
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            engine.prepareForTermination()
        }
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(engine: engine)
        } label: {
            // The label renders at launch (it's the menu bar icon), so it's a reliable
            // place to trigger first-launch onboarding for an LSUIElement app that has
            // no window open at startup.
            MenuBarLabel(engine: engine)
        }
        .menuBarExtraStyle(.window)

        Window("Flowka Settings", id: "settings") {
            SettingsView(engine: engine)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        Window("Welcome to Flowka", id: "onboarding") {
            OnboardingView(engine: engine)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

// MARK: - Menu Bar Label + Onboarding Trigger

/// Wraps the menu bar icon and, once per launch, decides whether to present onboarding.
/// Lives here (not in MenuBarIcon) so the icon stays a pure presentation view and the
/// trigger has access to `@Environment(\.openWindow)`.
private struct MenuBarLabel: View {
    let engine: DictationEngine
    @Environment(\.openWindow) private var openWindow
    @State private var didEvaluateOnboarding = false

    var body: some View {
        MenuBarIcon(state: engine.state, isHoldingForToggle: engine.isHoldingForToggle)
            .task {
                // Guard against the label view re-appearing: evaluate at most once per launch.
                guard !didEvaluateOnboarding else { return }
                didEvaluateOnboarding = true
                presentOnboardingIfNeeded()
            }
    }

    /// В сборке без FluidAudio (голый `make app`) Parakeet недоступен в принципе.
    private static var hasParakeetModel: Bool {
        #if canImport(FluidAudio)
        return FluidAudioEngine.isModelDownloaded
        #else
        return false
        #endif
    }

    private func presentOnboardingIfNeeded() {
        let settings = AppSettings.shared
        guard !settings.hasCompletedOnboarding else { return }

        // Модель может лежать в двух разных местах: whisper — в каталоге
        // `ModelManager`, Parakeet — в кэше FluidAudio. Учитывая только первый,
        // мы гнали пользователя с уже скачанным Parakeet качать модель заново.
        let hasAnyModel = !ModelManager.shared.downloadedModels().isEmpty || Self.hasParakeetModel
        if OnboardingView.shouldShowOnboarding(hasCompleted: settings.hasCompletedOnboarding, hasAnyModel: hasAnyModel) {
            openWindow(id: "onboarding")
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // Existing/upgrading user: a model is already installed, so skip the flow
            // and mark complete so this check never runs again.
            settings.hasCompletedOnboarding = true
        }
    }
}

struct MenuBarIcon: View {
    let state: DictationState
    let isHoldingForToggle: Bool

    var body: some View {
        if isHoldingForToggle {
            // Pulsing dotted ring: visual confirmation the toggle hold is being registered.
            Image(systemName: "circle.dotted")
                .foregroundStyle(.orange)
                .symbolEffect(.pulse, options: .repeating)
        } else {
            switch state {
            case .idle:
                Image(systemName: "waveform.badge.mic")
            case .recording:
                Image(systemName: "mic.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
            case .processing:
                Image(systemName: "brain.head.profile.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.orange)
            case .typing:
                Image(systemName: "text.cursor")
            }
        }
    }
}
