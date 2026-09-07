import Foundation

/// Ожидание выдачи Accessibility: пользователь ставит галку в системных
/// настройках уже после запуска, и приложению нужно об этом узнать.
///
/// Раньше вся логика жила прямо в замыкании `Timer` внутри `DictationEngine` и
/// дёргала `AXIsProcessTrusted()` напрямую — проверить её можно было только
/// вручную, реально переключая тумблер в System Settings. Здесь отделено
/// решение («доступ появился — зовём колбэк ровно один раз и перестаём
/// опрашивать») от механики опроса: таймер остаётся снаружи, тут только Foundation.
final class AccessibilityPoller {
    /// Опрос завершён: доступ выдан, колбэк отработал, дальше спрашивать нечего.
    private(set) var isFinished = false

    private let isTrusted: () -> Bool
    private let onGranted: () -> Void

    init(isTrusted: @escaping () -> Bool, onGranted: @escaping () -> Void) {
        self.isTrusted = isTrusted
        self.onGranted = onGranted
    }

    /// Один шаг опроса. После завершения не трогает систему повторно —
    /// в старом коде за это отвечал `timer.invalidate()` в теле замыкания,
    /// то есть корректность зависела от того, кто вызывает.
    func tick() {
        guard !isFinished else { return }
        guard isTrusted() else { return }
        isFinished = true
        onGranted()
    }
}
