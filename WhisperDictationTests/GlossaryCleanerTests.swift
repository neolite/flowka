import XCTest
@testable import WhisperDictation

/// Проверки словаря замен. Главный риск здесь — границы слов на кириллице:
/// без них «пул» заменится внутри «пульт». ICU-регулярки в NSRegularExpression
/// это поддерживают, но подтверждено это тестом, а не документацией.
final class GlossaryCleanerTests: XCTestCase {

    private func clean(_ text: String) -> String {
        GlossaryCleaner(rules: GlossaryCleaner.defaultRules).clean(text).cleaned
    }

    func testReplacesBasicTerm() {
        XCTAssertEqual(clean("сделай пул реквест"), "сделай pull request")
    }

    /// Регрессия на ложное срабатывание: «пул» внутри «пульт» трогать нельзя.
    func testRespectsWordBoundariesInCyrillic() {
        XCTAssertEqual(clean("возьми пульт"), "возьми пульт")
    }

    func testLongerPhraseWinsOverShorter() {
        XCTAssertEqual(clean("апрувни мёрдж реквест"), "апрувни merge request")
    }

    func testAppliesMultipleRules() {
        XCTAssertEqual(
            clean("задеплой на стейджинг и сделай коммит"),
            "задеплой на staging и сделай commit"
        )
    }

    func testMatchIsCaseInsensitive() {
        XCTAssertEqual(clean("Пул реквест готов"), "pull request готов")
    }

    /// Whisper может вставить между словами произвольный пробельный мусор.
    func testToleratesIrregularWhitespace() {
        XCTAssertEqual(clean("пул   реквест"), "pull request")
    }

    func testLeavesUnrelatedTextAlone() {
        XCTAssertEqual(clean("просто русский текст"), "просто русский текст")
    }

    func testEmptyInput() {
        XCTAssertEqual(clean(""), "")
    }

    // MARK: - Result

    func testResultPreservesOriginalForUndo() {
        let result = GlossaryCleaner(rules: GlossaryCleaner.defaultRules)
            .clean("сделай пул реквест")
        XCTAssertEqual(result.original, "сделай пул реквест")
        XCTAssertTrue(result.didChange)
        XCTAssertEqual(result.appliedRules.count, 1)
    }

    func testResultReportsNoChange() {
        let result = GlossaryCleaner(rules: GlossaryCleaner.defaultRules)
            .clean("обычная фраза")
        XCTAssertFalse(result.didChange)
        XCTAssertTrue(result.appliedRules.isEmpty)
    }

    // MARK: - Парсинг пользовательских правил

    /// Мусорные строки — это пользовательский ввод, на нём нельзя падать.
    func testParsesUserRulesAndSkipsMalformedLines() {
        let rules = GlossaryCleaner.parseRules(from: [
            "брусника = Brusnika",
            "  строка без разделителя  ",
            "= пусто",
            "пусто =",
            "а=б",
        ])
        XCTAssertEqual(rules.count, 2)
        XCTAssertEqual(rules.first, GlossaryCleaner.Rule("брусника", "Brusnika"))
    }

    func testUserRuleIsApplied() {
        let rules = GlossaryCleaner.parseRules(from: ["брусника = Brusnika"])
        XCTAssertEqual(GlossaryCleaner(rules: rules).clean("это брусника").cleaned, "это Brusnika")
    }

    /// Многозначные одиночные слова в словаре по умолчанию быть не должны:
    /// цена ложной замены выше выигрыша.
    func testDefaultRulesExcludeAmbiguousSingleWords() {
        let spoken = Set(GlossaryCleaner.defaultRules.map(\.spoken))
        for ambiguous in ["пул", "вью", "бан", "стек", "код", "прод"] {
            XCTAssertFalse(spoken.contains(ambiguous), "многозначное слово «\(ambiguous)» в словаре")
        }
    }

    /// Пустая замена — тихая ошибка: правило есть, эффекта нет.
    func testDefaultRulesHaveNoIdentityReplacements() {
        for rule in GlossaryCleaner.defaultRules {
            XCTAssertNotEqual(rule.spoken, rule.canonical, "правило-пустышка: \(rule.spoken)")
        }
    }
}
