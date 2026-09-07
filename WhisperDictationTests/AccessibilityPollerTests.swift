import XCTest
@testable import WhisperDictation

/// Поллер, ждущий выдачи Accessibility, был вкраплён прямо в `DictationEngine`
/// и дёргал `AXIsProcessTrusted()` напрямую — то есть проверить его можно было
/// только реально выдав разрешение в системных настройках. Здесь он вынесен и
/// проверяется на подставном источнике: тесту не нужны ни TCC, ни AppKit.
final class AccessibilityPollerTests: XCTestCase {

    func testFiresOnceWhenAccessBecomesGranted() {
        var answers = [false, false, true]
        var granted = 0
        let poller = AccessibilityPoller(
            isTrusted: { answers.isEmpty ? true : answers.removeFirst() },
            onGranted: { granted += 1 }
        )

        poller.tick()
        XCTAssertEqual(granted, 0, "доступа ещё нет — колбэк не зовём")
        poller.tick()
        XCTAssertEqual(granted, 0)
        poller.tick()
        XCTAssertEqual(granted, 1, "доступ выдан — колбэк ровно один раз")
    }

    func testStopsPollingAfterGrant() {
        var probes = 0
        var granted = 0
        let poller = AccessibilityPoller(
            isTrusted: { probes += 1; return true },
            onGranted: { granted += 1 }
        )

        poller.tick()
        let probesAfterGrant = probes
        // Лишние тики после выдачи не должны ни опрашивать систему, ни
        // перезапускать монитор хоткея повторно: в старом коде за это отвечал
        // `timer.invalidate()` внутри колбэка, и проверить это было нечем.
        poller.tick()
        poller.tick()

        XCTAssertEqual(granted, 1, "перезапуск хоткея ровно один раз")
        XCTAssertEqual(probes, probesAfterGrant, "после выдачи систему не опрашиваем")
    }

    func testIsFinishedReflectsState() {
        var trusted = false
        let poller = AccessibilityPoller(isTrusted: { trusted }, onGranted: {})

        XCTAssertFalse(poller.isFinished)
        poller.tick()
        XCTAssertFalse(poller.isFinished, "доступа нет — продолжаем ждать")

        trusted = true
        poller.tick()
        XCTAssertTrue(poller.isFinished)
    }
}
