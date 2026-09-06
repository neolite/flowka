import Foundation

/// Единая точка постобработки распознанного текста.
///
/// Существует, чтобы обычный и живой режимы диктовки не расходились в
/// поведении: раньше каждый вызывал `TextCorrector` самостоятельно, и любое
/// новое правило пришлось бы добавлять в двух местах.
///
/// Порядок намеренный:
/// 1. `TextCorrector` — регистр, пунктуация, числа. Англоцентричен, поэтому
///    на русском часть его проходов отключается.
/// 2. `GlossaryCleaner` — возврат латиницы. Идёт **после** корректора: тот
///    может изменить регистр слова, а словарь задаёт каноническое написание
///    и должен быть последним словом.
final class TextPipeline: @unchecked Sendable {
    static let shared = TextPipeline()

    private let lock = NSLock()
    private var cachedGlossary: GlossaryCleaner?
    private var cachedRulesSignature: [String] = []

    /// Словарь пересобирается только при изменении пользовательских правил:
    /// компиляция регулярок на каждую фразу в горячем пути не нужна.
    private func glossary() -> GlossaryCleaner {
        let userRules = AppSettings.shared.glossaryRules

        lock.lock()
        defer { lock.unlock() }

        if let cached = cachedGlossary, cachedRulesSignature == userRules {
            return cached
        }

        let rules = GlossaryCleaner.defaultRules + GlossaryCleaner.parseRules(from: userRules)
        let cleaner = GlossaryCleaner(rules: rules)
        cachedGlossary = cleaner
        cachedRulesSignature = userRules
        return cleaner
    }

    func process(_ text: String, context: CorrectionContext = .standalone) -> String {
        let corrected = TextCorrector.shared.correct(text, context: context)
        guard AppSettings.shared.glossaryEnabled else { return corrected }
        return glossary().clean(corrected).cleaned
    }

    /// Сбрасывает кэш словаря. Вызывается после правки правил в настройках.
    func invalidateGlossary() {
        lock.lock()
        cachedGlossary = nil
        cachedRulesSignature = []
        lock.unlock()
    }
}
