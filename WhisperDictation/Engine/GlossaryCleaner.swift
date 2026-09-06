import Foundation

/// Возврат канонического написания латинских терминов, которые Whisper
/// транслитерировал в кириллицу: «пул реквест» → `pull request`.
///
/// Почему детерминированный словарь, а не LLM: языковая модель способна
/// восстановить термин, но столь же способна переписать смысл, имя переменной
/// или идентификатор. Здесь нужна предсказуемость, а не сообразительность.
///
/// Не зависит ни от чего, кроме Foundation — это единственный модуль движка,
/// который собирается и тестируется вне macOS.
struct GlossaryCleaner: Sendable {

    /// Одно правило замены. `spoken` — то, что услышал Whisper, `canonical` —
    /// как это должно выглядеть в тексте.
    struct Rule: Sendable, Equatable {
        let spoken: String
        let canonical: String

        init(_ spoken: String, _ canonical: String) {
            self.spoken = spoken
            self.canonical = canonical
        }
    }

    /// Результат очистки. Исходный текст сохраняется, чтобы замену можно было
    /// откатить — по одной испорченной строке исходное написание не всегда
    /// восстановимо однозначно, и пользователю нужен путь назад.
    struct Result: Sendable, Equatable {
        let cleaned: String
        let original: String
        let appliedRules: [Rule]

        var didChange: Bool { cleaned != original }
    }

    private let rules: [Rule]

    /// Правила сортируются по убыванию длины: «пул реквест» должно сработать
    /// раньше, чем одиночное «пул», иначе длинная фраза уже не совпадёт.
    init(rules: [Rule]) {
        self.rules = rules.sorted { $0.spoken.count > $1.spoken.count }
    }

    func clean(_ text: String) -> Result {
        guard !text.isEmpty else {
            return Result(cleaned: text, original: text, appliedRules: [])
        }

        var current = text
        var applied: [Rule] = []

        for rule in rules {
            guard let regex = Self.regex(for: rule.spoken) else { continue }
            let range = NSRange(current.startIndex..., in: current)
            guard regex.firstMatch(in: current, range: range) != nil else { continue }

            current = regex.stringByReplacingMatches(
                in: current,
                range: range,
                withTemplate: NSRegularExpression.escapedTemplate(for: rule.canonical)
            )
            applied.append(rule)
        }

        return Result(cleaned: current, original: text, appliedRules: applied)
    }

    // MARK: - Regex

    /// Кэш скомпилированных регулярок. Замена выполняется в горячем пути между
    /// распознаванием и вставкой, компилировать заново на каждую фразу незачем.
    private static let cache = RegexCache()

    private static func regex(for spoken: String) -> NSRegularExpression? {
        cache.regex(for: spoken)
    }

    /// Разделитель между словами фразы словаря: пробельное, дефис-минус,
    /// неразрывный дефис, короткое и длинное тире.
    ///
    /// Символы подставлены буквально, а НЕ как `\\u{2011}`: ICU-движок
    /// `NSRegularExpression` фигурные скобки в `\\u` не понимает, такая
    /// регулярка не компилируется — а `regex(for:)` возвращает `nil` и правило
    /// молча пропускается. Проверено: с `\\u{...}` не срабатывало ни одно
    /// правило из нескольких слов.
    private static let separatorPattern = "[\\s\\-\u{2011}\u{2013}\u{2014}]+"

    private final class RegexCache: @unchecked Sendable {
        private var storage: [String: NSRegularExpression] = [:]
        private let lock = NSLock()

        func regex(for spoken: String) -> NSRegularExpression? {
            lock.lock()
            defer { lock.unlock() }

            if let cached = storage[spoken] { return cached }

            // Границы слова обязательны: без них «пул» внутри «пульт» тоже
            // заменится.
            //
            // Пробел во фразе словаря соответствует не только пробелу.
            // Замерено на large-v3-turbo: без промпта модель выдаёт
            // «пул-реквест» — ЧЕРЕЗ ДЕФИС. Правило, ищущее только пробел, такую
            // строку не видит, а это ровно тот случай, ради которого словарь и
            // нужен (промпт не сработал). Поэтому разделителем считается любой
            // пробельный символ, дефис или тире — в любом количестве.
            let escaped = NSRegularExpression.escapedPattern(for: spoken)
                .replacingOccurrences(of: "\\ ", with: GlossaryCleaner.separatorPattern)
                .replacingOccurrences(of: " ", with: GlossaryCleaner.separatorPattern)
            let pattern = "\\b\(escaped)\\b"

            guard let compiled = try? NSRegularExpression(
                pattern: pattern,
                options: [.caseInsensitive]
            ) else { return nil }

            storage[spoken] = compiled
            return compiled
        }
    }
}

// MARK: - Словарь по умолчанию

extension GlossaryCleaner {

    /// Стартовый набор для русской технической речи.
    ///
    /// Правило отбора: сюда попадает только то, где транслитерация **однозначна**.
    /// Одиночные многозначные слова («пул», «стек», «код») намеренно отсутствуют —
    /// цена ложной замены выше выигрыша.
    static let defaultRules: [Rule] = [
        // Git и процесс
        Rule("пул реквест", "pull request"),
        Rule("пулл реквест", "pull request"),
        Rule("мёрдж реквест", "merge request"),
        Rule("мерж реквест", "merge request"),
        Rule("коммит", "commit"),
        Rule("ребейз", "rebase"),
        Rule("чери пик", "cherry-pick"),
        Rule("сквош", "squash"),
        Rule("бранч", "branch"),
        Rule("хотфикс", "hotfix"),
        Rule("ревью", "review"),

        // Окружения и деплой
        Rule("стейджинг", "staging"),
        Rule("продакшн", "production"),
        Rule("деплой", "deploy"),
        Rule("роллбек", "rollback"),

        // Фронтенд
        Rule("эффектор", "Effector"),
        Rule("юз юнит", "useUnit"),
        Rule("юз стейт", "useState"),
        Rule("юз эффект", "useEffect"),
        Rule("юз мемо", "useMemo"),
        Rule("юз колбэк", "useCallback"),
        Rule("юз рефф", "useRef"),
        Rule("реакт", "React"),
        Rule("некст джей эс", "Next.js"),
        Rule("свелт", "Svelte"),
        Rule("тейлвинд", "Tailwind"),
        Rule("сторибук", "Storybook"),
        Rule("сэмпл", "sample"),

        // Языки и рантаймы
        Rule("тайпскрипт", "TypeScript"),
        Rule("джаваскрипт", "JavaScript"),
        Rule("свифт", "Swift"),
        Rule("питон", "Python"),

        // Инфраструктура
        Rule("докер", "Docker"),
        Rule("кубернетес", "Kubernetes"),
        Rule("кубер", "Kubernetes"),
        Rule("постгрес", "PostgreSQL"),
        Rule("редис", "Redis"),
        Rule("нгинкс", "nginx"),
        Rule("энджинкс", "nginx"),

        // API и данные
        Rule("эндпоинт", "endpoint"),
        Rule("миддлвар", "middleware"),
        Rule("вебхук", "webhook"),
        Rule("джейсон", "JSON"),
        Rule("графкуэл", "GraphQL"),
        Rule("рест", "REST"),

        // Инструменты
        Rule("фигма", "Figma"),
        Rule("гитхаб", "GitHub"),
        Rule("гитлаб", "GitLab"),
        Rule("икскод", "Xcode"),
        Rule("линтер", "linter"),
        Rule("тайпчек", "typecheck"),
    ]

    /// Словарь из настроек: строки вида `произнесённое = каноническое`.
    /// Пустые строки и строки без разделителя игнорируются молча — это
    /// пользовательский ввод, падать на нём нельзя.
    static func parseRules(from lines: [String]) -> [Rule] {
        lines.compactMap { line in
            let parts = line.split(separator: "=", maxSplits: 1).map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            guard parts.count == 2, !parts[0].isEmpty, !parts[1].isEmpty else { return nil }
            return Rule(parts[0], parts[1])
        }
    }
}
