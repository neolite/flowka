WITHOUT RU

⚠ ДИСКЛЕЙМЕР / DISCLAIMER

Настоящий архив (Design Specimen Archive, vol. 03) предоставляется
исключительно в образовательных и ознакомительных целях, «как есть»
(AS IS), без каких-либо гарантий — явных или подразумеваемых.

1. НАЗНАЧЕНИЕ
   Материалы архива являются референсами и демонстрацией возможностей
   генеративных AI-моделей (нейросетевых суб-агентов) по анализу
   и воспроизведению визуальных паттернов. Архив не претендует на
   полноту, точность или актуальность извлечённых данных.

2. ОТСУТСТВИЕ ОТВЕТСТВЕННОСТИ
   Автор не несёт ответственности за:
   • любой прямой или косвенный ущерб, возникший в результате
     использования, невозможности использования или неверной
     интерпретации материалов;
   • ошибки, неточности, опечатки и расхождения с оригинальными
     сайтами-источниками;
   • последствия применения сниппетов, токенов, анимаций
     или иных фрагментов в коммерческих и/или публичных проектах.

3. ТОЛЬКО ЛИЧНОЕ ИСПОЛЬЗОВАНИЕ
   Архив предназначен для личного изучения, исследований
   и вдохновения. Запрещается:
   • коммерческое распространение материалов целиком или частично;
   • использование извлечённых дизайн-систем, логотипов, товарных
     знаков и фирменных стилей в собственных продуктах;
   • публикация архива на открытых ресурсах без письменного
     согласия автора.

4. ПРАВА ТРЕТЬИХ ЛИЦ
   Все упомянутые бренды, названия сайтов, логотипы и товарные знаки
   принадлежат их законным владельцам. Упоминание в архиве носит
   исключительно справочно-образовательный характер и не является
   одобрением, партнёрством или аффилиацией.

5. ОТСУТСТВИЕ ГАРАНТИЙ
   Материалы предоставляются без гарантий пригодности для какой-либо
   конкретной цели, ненарушения прав третьих лиц, безошибочности
   или бесперебойности. Автор вправе изменять, дополнять
   или удалять содержимое архива в любой момент без уведомления.

6. ОТКАЗ ОТ ПРЕТЕНЗИЙ
   Открывая и используя файлы архива, вы подтверждаете, что принимаете
   данные условия и отказываетесь от любых претензий к автору,
   связанных с использованием материалов.

Используя архив, вы подтверждаете, что ознакомились с настоящим
дисклеймером и принимаете его условия в полном объёме.

Если вы не согласны — не используйте материалы.

---

# Wispr Flow — типографика

> Источник: https://wisprflow.ai/?ref=producthunt · @font-face из flowsite-dev.webflow.shared.b45cb3c42.min.css · 2026-07-29

## Шрифты

| Family | Веса | Назначение | Подключение | Fallback |
|---|---|---|---|---|
| **Eb garamond** (EB Garamond) | 400, 400 italic | Display: h1–h6, цитаты, стат-цифры | `@font-face`, woff2 с cdn.prod.website-files.com, `font-display: swap` | `Arial, sans-serif` (переменная `--_text-collection---font--primary-font`) |
| **Figtree** | 400, 500, 600, 700 | Body/UI: параграфы, кнопки, нав, чипы | `@font-face`, woff2, swap | `Arial, sans-serif` (`--_text-collection---font--body-font`) |
| **Monaspace Neon** | 300 | Код/сниппеты (snippet library, «wpm»-метрики) | `@font-face`, woff, swap | — |
| **Inter** (18pt) | 300, 400, 500, 800 | Вспомогательные блоки (новые секции) | `@font-face`, ttf, swap | — |
| **IBM Plex Mono** | 200 | Вспомогательный моно | `@font-face`, ttf, swap | — |
| **Twemoji Country Flags** | 400 | Эмодзи-флаги (unicode-range U+1F1E6–1F1FF) | inline `@font-face`, jsdelivr | `'Segoe UI Emoji', 'Segoe UI Symbol', sans-serif` |

Google Fonts не используется — всё через `@font-face` с Webflow CDN.
В demo EB Garamond и Figtree подключены через Google Fonts (публичные),
Monaspace Neon заменён на IBM Plex Mono (ближайший аналог).

Глобально: `body { -webkit-font-smoothing: antialiased; text-rendering: optimizeLegibility; }`

## Шкала (desktop)

Все заголовки: `font-family: "Eb garamond"; font-weight: 400; margin: 0`.

| Уровень | Size | Line-height | Letter-spacing | Примечание |
|---|---|---|---|---|
| h1 | `7.5rem` (120px) | `.85` | `-.05em` | моб. `h1-small` = `6rem`, lh `.95` |
| h2 | `4rem` (64px) | `.95` | `-.03em` | есть `h2-big` = `4.6875rem` |
| h3 | `3rem` (48px) | `1.1` | — | |
| h4 | `2rem` (32px) | `1.3` | `-.03em` | |
| h5 | `1.25rem` (20px) | `1.3` | — | |
| h6 | `1rem` (16px) | `1.3` | — | |
| body xlarge | `1.5rem` (24px) | — | — | |
| body large-medium | `1.375rem` (22px) | — | — | |
| body large | `1.25rem` (20px) | — | — | подзаголовок hero (`p.text-size-large`) |
| body medium | `1.125rem` (18px) | — | — | базовый `p` (`font-weight: 500`) |
| body regular | `1rem` (16px) | — | — | |
| body small | `.875rem` (14px) | — | — | копирайт, подписи |
| body xsmall | `.8125rem` (13px) | — | — | |
| tiny | `.75rem` (12px) | — | — | `.text-size-tiny` |

Мобильные корректировки (из media-блоков): `.nav_menu-link` → `body--medium`,
promo-div `1.25rem → 1rem`, hero_record_sentence `1.5rem → 1.25rem`,
marquee-кегли растут вверх по брейкпоинтам (`1.375rem → 2.3rem → 3.4rem` у
faster_flow-marquee — SVG масштабируется).

## Спецэффекты

1. **«Выцветший» заголовок hero** — спаны `.text-color-black20 { color: #8a8a80 }`:
   `Do` / `n` / `’` / `t type, ` серым, `just speak` — полным #1a1a1a.
   Плюс микро-кернинг спанов `.ls-7`, `.ls-13` (letter-spacing .07em/.13em).
2. **Eyebrow / overline**: `color: #1a1a1ab3; letter-spacing: .08em; font-family:
   Figtree; font-weight: 500; line-height: 1.3em` (`.hero_text_eyebrown`),
   светлый вариант `#ffffeb`. Footer-заголовки колонок: `uppercase; ls .08em;
   body--small; weight 500; color #1a1a1a80`.
3. **Ask-AI заголовок**: Figtree, h4-размер, `uppercase`, `weight 700`, ls 0.
4. **Маркерный хайлайт**: `box-shadow: inset 0 -25px 0 0 var(--base-color--dawn)`
   (лиловый «фломастер» под текстом).
5. **Italic** EB Garamond — цитаты отзывов (`.text-style-italic`), слово «you»
   в «Made for the way you work».
6. **SVG text-marquee**: кегль наследуется от контейнера (`font-size: inherit`),
   `baseline-shift: -20%/-30%`; сырой текст `weight 400, fill #1A1A1A, opacity .4`;
   чистый — `weight 600, fill #fff` на кривой `stroke #1A1A1A stroke-width 30`;
   «keyboard» — `weight 600, fill #8d8d83`; «Flow» — `weight 600, fill #FFFFEB`.
7. **Heading-underline**: SVG `#heading-underline` со `stroke-width: 8`
   (≤1024px → 12) — рисованное подчёркивание заголовков (GSAP DrawSVG).
8. **Blog-ссылки**: `text-decoration-thickness: 3px`, цвет прозрачный →
   `currentColor` за `.25s ease` при hover.

## Примеры реальных заголовков

- H1 hero: **«Don’t type, just speak»** (серая + чёрная части).
- Подзаголовок: «The voice-to-text AI that turns speech into clear, polished
  writing in every app.»
- H2-секции: **«Write faster in all your apps, on any device»**;
  **«Made for the way *you* work»**; **«Love letters to Flow»**;
  **«Start flowing»**; **«4x faster than typing»**.
- Eyebrow-подписи: «Flow for Developers», «Your Dictionary», «Your Snippets».
- Стат-цифры (EB Garamond h3, ls −.03em, lh .95): «90% faster everywhere»,
  «4x faster responses», «200+ employees · B2B Software».
- Мелкий текст под CTA: «Available on Mac, Windows, iPhone, and Android.
  Free for 14 days.» (`.text-size-small.text-color-black70` = #1a1a1ab3).


---

> **Дисклеймер / Disclaimer**
>
> Все материалы в данном репозитории созданы с использованием нейросетей (AI) исключительно в целях **тестирования интерфейсов**, изучения дизайн-паттернов и повторения отдельных элементов для **личных, некоммерческих, законных целей**.
>
> Содержимое **не противоречит законодательству Российской Федерации** и иных применимых юрисдикций. Автор публикует все материалы в открытом доступе для использования в **персональных проектах** (собственных сайтах, портфолио, учебных целях).
>
> Автор **не несёт никакой ответственности** за использование материалов третьими лицами. Все торговые марки, логотипы и дизайн-системы принадлежат их правообладателям.
