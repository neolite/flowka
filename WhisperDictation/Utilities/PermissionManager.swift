import AVFoundation
import Cocoa

final class PermissionManager: ObservableObject, @unchecked Sendable {
    static let shared = PermissionManager()

    @Published var microphoneGranted = false
    @Published var accessibilityGranted = false

    var allPermissionsGranted: Bool {
        microphoneGranted && accessibilityGranted
    }

    init() {
        checkPermissions()
    }

    func checkPermissions() {
        checkMicrophone()
        checkAccessibility()
    }

    // MARK: - Microphone

    func checkMicrophone() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            microphoneGranted = true
        case .notDetermined:
            microphoneGranted = false
        case .denied, .restricted:
            microphoneGranted = false
        @unknown default:
            microphoneGranted = false
        }
    }

    func requestMicrophone() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                self?.microphoneGranted = granted
            }
        }
    }

    // MARK: - Accessibility

    /// Единственное место, где приложение спрашивает у системы про AX-доступ.
    /// Статический, потому что `DictationEngine` спрашивает то же самое, но
    /// ему не нужен ни экземпляр менеджера, ни его `@Published`-состояние —
    /// раньше он звал `AXIsProcessTrusted()` сам, и источников правды было два.
    static func isProcessTrusted() -> Bool {
        AXIsProcessTrusted()
    }

    func checkAccessibility() {
        accessibilityGranted = Self.isProcessTrusted()
    }

    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    func openMicrophoneSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!
        NSWorkspace.shared.open(url)
    }
}
