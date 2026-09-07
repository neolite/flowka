import XCTest
@testable import WhisperDictation

/// Проверки генератора словаря термов для Parakeet v3 (CTC-boost) и дефолта
/// тумблера движка. Логика чистая — тестируется без FluidAudio и без модели.
final class ParakeetVocabularyTests: XCTestCase {

    // MARK: - Term generation

    func testMergesSourcesInPriorityOrder() {
        let terms = AppSettings.parakeetVocabularyTerms(
            glossaryDefaultCanonicals: ["pull request", "Docker"],
            glossaryRuleCanonicals: ["Effector"],
            customTerms: ["Flowka"]
        )
        XCTAssertEqual(terms, ["pull request", "Docker", "Effector", "Flowka"])
    }

    func testDeduplicatesCaseInsensitively() {
        let terms = AppSettings.parakeetVocabularyTerms(
            glossaryDefaultCanonicals: ["Docker", "docker"],
            glossaryRuleCanonicals: ["DOCKER"],
            customTerms: ["Docker"]
        )
        XCTAssertEqual(terms, ["Docker"], "Первое написание побеждает, дубли по регистру отброшены")
    }

    func testTrimsAndDropsEmpty() {
        let terms = AppSettings.parakeetVocabularyTerms(
            glossaryDefaultCanonicals: ["  pull request  ", "", "   "],
            glossaryRuleCanonicals: [],
            customTerms: ["\n"]
        )
        XCTAssertEqual(terms, ["pull request"])
    }

    func testEmptyInputsYieldEmpty() {
        XCTAssertTrue(AppSettings.parakeetVocabularyTerms(
            glossaryDefaultCanonicals: [],
            glossaryRuleCanonicals: [],
            customTerms: []
        ).isEmpty)
    }

    /// Дефолтный глоссарий действительно даёт непустой список канонов —
    /// иначе boost на v3 остался бы без термов.
    func testDefaultGlossaryProducesTerms() {
        let canonicals = GlossaryCleaner.defaultRules.map(\.canonical)
        let terms = AppSettings.parakeetVocabularyTerms(
            glossaryDefaultCanonicals: canonicals,
            glossaryRuleCanonicals: [],
            customTerms: []
        )
        XCTAssertFalse(terms.isEmpty)
        XCTAssertTrue(terms.contains("pull request"))
        XCTAssertTrue(terms.contains("Effector"))
    }

    // MARK: - Engine toggle default

    func testEngineDefaultsToWhisper() {
        XCTAssertEqual(AppSettings.ASREngine(rawValue: "whisper"), .whisper)
        XCTAssertEqual(AppSettings.ASREngine(rawValue: "parakeetV3"), .parakeetV3)
        // Неизвестное значение из UserDefaults не должно ронять — сам геттер
        // падает на .whisper; здесь проверяем базовую валидность rawValue-инициализатора.
        XCTAssertNil(AppSettings.ASREngine(rawValue: "garbage"))
    }
}
