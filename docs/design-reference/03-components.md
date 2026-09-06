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

# Wispr Flow — компоненты

> Источник: https://wisprflow.ai/?ref=producthunt · 2026-07-29

Инвентарь сверху вниз по главной странице. Сниппеты — в `snippets/`, каждый
самодостаточен (ссылка на `../css/tokens.css` + inline-стили).

## Таблица-инвентарь

| # | Компонент | Классы | Состояния | Сниппет |
|---|---|---|---|---|
| 1 | Banner-тикер (top) | `.banner.v2`, `.banner_text`, `.banner_text-link` | hover link opacity .75 | `banner-ticker.html` |
| 2 | Nav / header | `.nav_fixed`, `.nav_component`, `.nav_container-v2`, `.nav_menu-link`, `.nav_big-button`, `.hamburger_12_wrap` | link hover (border+bg), burger hover/open, dropdown | `nav-header.html` |
| 3 | Dropdown-меню | `.nav_menu-dropdown-toggle-v2`, `.dropdown_link` | hover bg lumen-dark, текст → fathom, сдвиг padding | `dropdown-menu.html` |
| 4 | Hero | `.section_hero`, `h1` + `.text-color-black20`, `.button`, SVG textPath-marquee, Lottie | — | `hero-heading.html` |
| 5 | Buttons | `.button` + `.is-small/.is-large/.is-secondary/.is-dark/.is-yellow/.is-text/.is-transparent/.is-icon/.loading` | hover `scale(.98)`, transition transform .2s | `buttons.html` |
| 6 | Chips / pills | `.home_integrations_chip` (outline-pill), `.home_features_grid-2-chip` (fathom/white 4px) | — | `chips.html` |
| 7 | Tab-пиллы use-cases | `.use-cases_tab-link`, `.use-cases_fs-tablink` | active: bg dawn + `rotate(-4deg)`; hover: margin/transform .3s | `tab-pills.html` |
| 8 | Use-case card | `.use-cases_card` (fathom, radius 2rem) | hover: стрелка `translate(10px,-10px)` .3s | `use-case-card.html` |
| 9 | Feature-карточки | `.features_grid-card` (dictionary / snippets / languages / tone) | — | `feature-cards.html` |
| 10 | Faster-сравнение | `.faster_grid`, `.faster_grid-left/right`, SVG-marquee | бесконечный marquee | `faster-marquee.html` |
| 11 | Logo wall | `.clients_cms-wrapper`, `.clients_logo-image` | marquee 60s linear | `logo-marquee.html` |
| 12 | Testimonial-карточки | `.testi_card` (square 26rem / landscape 46rem), `.testi_card-bg-color`, `.testi_card-stats-grid` | цветные подложки | `testimonial-cards.html` |
| 13 | CTA «Start flowing» | `.section_startflowing`, `.cta_bg`, `.cta_content` | — | `cta-banner.html` |
| 14 | Ask-AI блок | `.ask-ai_component` (рамка 4px top+right) | кнопки-ссылки | `ask-ai.html` |
| 15 | Footer | `.section_footer`, `.footer_flex-links`, `.footer_link-block`, `.footer_social-link` | link hover → fathom; иконка-стрелка slide-in 300ms | `footer.html` |
| 16 | Forms / inputs | `.form_input` (underline), `.form_checkbox`, `.form_message-*` | focus border-bottom 2px vast; error → pulse | `form-inputs.html` |
| 17 | Promo-див | `.promo-div` (fathom pill) | — | в `chips.html` |
| 18 | Hamburger | `.hamburger_12_wrap` | hover: линии 85/65/100%; open: X через rotate 45 | `nav-header.html` |

## Описания ключевых компонентов

### Button (`.button`)
База: `border: 2px solid #1a1a1a; background: var(--background-color--background-secondary)
(#f0d7ff); color: #1a1a1a; border-radius: .5rem; padding: 1rem 1.5rem; font-weight: 600;
line-height: 1; transition: transform .2s, color .3s`. Hover: `transform: scale(.98)`
(«нажатие внутрь», цвет не меняется). Варианты:
- `.is-small` — padding `.6rem .75rem`, font-size `.875rem`;
- `.is-large` — padding `1rem 2rem`;
- `.is-secondary` — фон lumen (#ffffeb); на тёмном: border lumen, bg fathom, text lumen;
- `.is-dark` — bg vast, text lumen;
- `.is-yellow` — bg glow (#ffa946);
- `.is-text` — без фона/рамки, padding-y `.5rem`;
- `.is-secondary.is-transparent` — прозрачный, border/text lumen (на тёмных CTA);
- `.is-icon` — flex с gap `.5rem`; `.loading` — спиннер фоном (rolling svg 32px);
- `.button-error` — `opacity: .5; pointer-events: none`.

### Nav
Фиксирован сверху (`.nav_fixed` z 999), «пилюля» `.nav_container-v2`:
`border: 2px solid #e4e4d0; background: #ffffeb; border-radius: .6rem;
grid-template-columns: .45fr 1fr 1fr` (logo / menu / CTA). Ссылки
`.nav_menu-link`: radius `1rem`, padding `.875rem`, weight 600,
hover → `border-color: #1a1a1a; background: #fffdf9` (transition border-color .3s,
color .3s). CTA `.nav_big-button` = `.button.is-small` (padding `.5rem 1.25rem`).
На ≤991px — burger + выезжающее меню (border-bottom 2px lumen-dark у пунктов).

### Hero
H1 7.5rem EB Garamond, «Don’t type, » — `#8a8a80`, «just speak» — `#1a1a1a`.
Под ним `.button` «Download for free» и подпись `.text-size-small.text-color-black70`.
Ниже — две SVG-кривые с бегущим текстом диктовки (сырой/чистый) и Lottie-анимация
по центру. Кривая чистого текста: `stroke #1A1A1A; stroke-width 30`, текст белый 600.

### Use-case card
`background: #034f46; color: #ffffeb; border-radius: 2rem; padding: 2rem;
min-height: 13rem; flex column; justify-content: space-between`. Внутри:
заголовок «Flow for X» + стрелка ↗ (hover: `translate(10px,-10px)`, .3s),
абзац, автор с круглым фото 3rem. Сетка 2×2, gap `.25rem`.

### Testimonial card
`.testi_card`: radius `3rem`, padding `1rem`, высота `28.75rem`, `overflow: clip`.
Квадратная — `26rem`, landscape — `46.25rem` (grid `1.1fr 1fr`). Подложки
`.testi_card-bg-color`: glow / dawn / lumen / lumen-dark / `#34d399` / flare /
fathom (тёмно-зелёная даёт светлый текст). Цитата — EB Garamond h4/h3,
ls −.03em, lh .95. Стат-вариант: фото + оверлей `linear-gradient(#fff0,#000000b3)`,
цифры EB Garamond h3, сетка 2×2.

### Ask-AI
`.ask-ai_component`: `border-top: 4px solid #1a1a1a; border-right: 4px solid #1a1a1a`
(уголок), заголовок Figtree h4 uppercase 700, кнопки «Ask ChatGPT / Ask Claude /
Ask Perplexity» — `.button`, справа снизу декоративная графика.

### Footer
3 колонки ссылок (Company / Product / Resources), заголовки uppercase `.875rem`
ls `.08em` color `#1a1a1a80`. Ссылки weight 600, hover → `#034f46`, у внешних —
стрелка slide-in (`opacity 0→1`, `translateX(-10px→0)`, 300ms). Ниже — огромный
wordmark + Lottie, копирайт `© Wispr Flow <year> · Terms · Privacy · Data Controls`,
соц-иконки 1.5rem (hover → fathom).

### Forms
`.form_input`: прозрачный фон, `border-bottom: 2px solid #1a1a1a` (остальные
стороны — `#1a1a1a4d`), min-height `2.25rem`; focus — border-bottom 2px solid vast;
placeholder `#1a1a1a80`; error — border/color `#7f1c34`. Textarea min-height 8rem.
Checkbox `.875rem`, radius `.125rem`. Сообщения: success bg `#cef5ca`/text `#114e0b`,
error bg `#f8e4e4`/text `#7f1c34`.


---

> **Дисклеймер / Disclaimer**
>
> Все материалы в данном репозитории созданы с использованием нейросетей (AI) исключительно в целях **тестирования интерфейсов**, изучения дизайн-паттернов и повторения отдельных элементов для **личных, некоммерческих, законных целей**.
>
> Содержимое **не противоречит законодательству Российской Федерации** и иных применимых юрисдикций. Автор публикует все материалы в открытом доступе для использования в **персональных проектах** (собственных сайтах, портфолио, учебных целях).
>
> Автор **не несёт никакой ответственности** за использование материалов третьими лицами. Все торговые марки, логотипы и дизайн-системы принадлежат их правообладателям.
