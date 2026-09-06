import XCTest
@testable import WhisperDictation

/// Бейдж в меню-баре должен отражать ВЫБРАННЫЙ движок, а не всегда имя
/// whisper-модели. Логика чистая — тестируется без UI.
final class EngineBadgeLabelTests: XCTestCase {

    func testParakeetEngineShowsParakeetLabelRegardlessOfWhisperModel() {
        XCTAssertEqual(
            engineBadgeLabel(engine: .parakeetV3, whisperModel: "large-v3-turbo-q5_0"),
            "Parakeet v3"
        )
        // Даже если whisper-модель какая угодно — движок паракет, значит паракет.
        XCTAssertEqual(
            engineBadgeLabel(engine: .parakeetV3, whisperModel: "small.en"),
            "Parakeet v3"
        )
    }

    func testWhisperEngineKeepsShortFriendlyModelName() {
        // Whisper-ветка НЕ меняется — прежняя логика modelShortName сохранена.
        XCTAssertEqual(engineBadgeLabel(engine: .whisper, whisperModel: "small.en"), "Small")
        XCTAssertEqual(engineBadgeLabel(engine: .whisper, whisperModel: "base.en-q5_1"), "Base Q5")
        XCTAssertEqual(
            engineBadgeLabel(engine: .whisper, whisperModel: "large-v3-turbo-q5_0"),
            "Large-V3-Turbo-Q5_0 Q5"
        )
    }
}
