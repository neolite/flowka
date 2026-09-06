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

# Wispr Flow — layout

> Источник: https://wisprflow.ai/?ref=producthunt · 2026-07-29

## Структура главной страницы (сверху вниз)

| # | Секция | Класс | Паттерн |
|---|---|---|---|
| 1 | Banner-тикер | `.banner.v2` (на главной скрыт `.hide`) | full-width полоса fathom/glow, бегущая строка + ссылка справа |
| 2 | Nav (sticky) | `.nav_fixed` → `.nav_component` → `.nav_container-v2` | пилюля 64rem, grid `.45fr 1fr 1fr` |
| 3 | Hero | `.section_hero` + `.hero_animation-wrapper-v2` | центр. колонка (container-medium 62rem) + две SVG-кривые во всю ширину |
| 4 | Integrations | `.section_integrations-clients` → `.section_app-integrations` | тёмная (fathom) «плита» radius 5rem; grid `1fr 1.3fr` |
| 5 | Clients logo wall | `.section_home-clients` → `.marquee_wrapper` | 4 бегущих ряда логотипов (logoTicker1 60s) |
| 6 | Faster (4x) | `.ribbon_wrapper` → `.section_faster` → `.faster_grid` | grid `18.75rem 1fr`: «Keyboard 45 wpm» / «Flow 220 wpm» |
| 7 | Use cases | `.section_use-cases` | табы-пиллы слева + контент справа (50/50), ниже grid 2×2 карточек |
| 8 | Features ×3 | `.section_features` (3 шт.) | grid `1.5fr 1fr` / `1fr 1.75fr`: текст + «живая» карточка |
| 9 | Testimonials | `.section_testimonials` | заголовок + Splide auto-scroll лента карточек; ниже — стат-карточки |
| 10 | CTA | `.section_startflowing` | тёмно-зелёная плита radius 5rem (снизу), центр. колонка 40rem |
| 11 | Ask AI | `.section_ask-ai` → `.ask-ai_component` | уголок-рамка 4px top+right, кнопки «Ask ChatGPT/Claude/Perplexity» |
| 12 | Footer | `.section_footer` | 3 колонки ссылок → гигантский wordmark → копирайт+соцсети |
| 13 | Mobile bottom bar | `.nav_bottom` (скрыт на десктопе) | fixed снизу, `translateY(100%)` → показывается |

## Контейнеры и поля

```
.padding-global  — padding-inline: 2.5rem (≤991px: 1.25rem)
.container-small  48rem · .container-medium 62rem · .container-large 77.5rem (._1200px → 75rem)
```

Вертикальный ритм — spacer-утилиты: `.spacer-xsmall .5rem` · `.spacer-small 1rem`
· `.spacer-medium 1.5rem` · `.spacer-large 3rem` · `.spacer-xlarge 4rem`
· `.spacer-huge 6rem` · `.spacer-xhuge 8rem` · `.spacer-xxhuge 10rem`.
Секции: `.padding-section-medium 6rem` / `large 8rem` / `xlarge 10rem` top+bottom.

## Sticky-элементы

- `.nav_fixed` — `position: fixed; inset: 0 0 auto; z-index: 999`; внутри
  `.nav_spacer` (высота 4.5rem → 3.5/2.6rem на брейкпоинтах) резервирует место.
- `.nav_bottom` — `position: fixed; inset: auto 0 0; z-index: 99999` (mobile CTA).

## Сетки (grid-схемы)

### Integrations (`.integrations_grid._2nd-col-wider`)
```
+-------------------+-------------------------+
| 1fr               | 1.3fr                   |   gap 4rem
| центр. текст      | видео/демо «Watch in    |
| + platform chips  | action» (embedly)       |
+-------------------+-------------------------+
```

### Faster (`.faster_grid`)
```
+--------------+----------------------------------------+
| 18.75rem     | 1fr                                    |  gap 0, align-items:center
| Keyboard     | Flow · 220 wpm                         |
| 45 wpm       | (fathom, фото-фон, белый marquee)      |
| серый        |                                        |
| marquee      | padding-bottom: 14rem (вынос marquee)  |
+--------------+----------------------------------------+
левая: border 4px #e4e4d0, radius 2.5rem
```

### Use cases (`.use-cases_tab`)
```
desktop:  50% - 52px  |  50% - 52px   (gap 6.5rem)
          таб-пиллы   |  активный кейс: заголовок, текст,
          (wrap, 9шт) |  кнопки + фото справа (abs., rotate 28deg)
cards:    .use-cases_grid — 2 колонки, gap .25rem
mobile:   всё в одну колонку, таб-меню max-width 41rem, margin-bottom 4rem
```

### Features (3 варианта)
```
A) .features_grid-top      1.5fr | 1fr      gap 8rem, text-center
B) .features_grid-bottom   1fr   | 1.75fr   gap 8rem (текст | дашборд-мокап)
C) variant-блок: radius 2rem, bg dawn или fathom, padding 4rem, display:block
Карточки-ячейки (.features_grid-card): radius 2.5rem, padding 3–4rem,
подложки dawn / fathom / glow; «is-tone» — height calc(100% - 80px).
```

### Testimonials
```
Лента: Splide auto-scroll, карточки фикс. ширины в ряд:
  square 26rem · landscape 46.25rem (grid 1.1fr 1fr) · is-bigger 51.25rem
  высота 28.75rem (is-bigger 31.875rem), radius 3rem, padding 1rem
Стат-ряд (.testi_bento-grid): grid 1fr .5fr 1fr, gap 1.5rem (tablet 1fr 1fr, mobile 1fr)
```

### Footer
```
.footer_flex-links: grid 1fr 1fr 1fr, gap 16px, padding-top 8rem, mb 6.65rem
.footer_logo:       grid auto 1fr, gap 8.75rem (wordmark | lottie 21.5rem)
.footer_copyright:  flex space-between (копирайт+legal | соцсети)
```

## Bento-схема (features-блок «AI Auto Edits», desktop)

```
+-------------------------------+-------------------+
| 1.5fr текст                   | 1fr               |
| eyebrow + H2 «AI Auto Edits»  | карточка-мокап    |
| абзац + кнопки                | (dictionary/      |
|                               |  snippets чипы)   |
+-------------------------------+-------------------+
+-------------------+-------------------------------+
| 1fr текст         | 1.75fr                        |
| H2 + абзац        | дашборд-скрин (.features_     |
| + platform chips  | grid-bottom-dashboard, 85%,   |
|                   | abs, top 10%) + мобильный     |
|                   | мокап (40%, abs, bottom -6rem)|
+-------------------+-------------------------------+
```

## Breakpoints-поведение

- **≤1281px**: banner компактнее, hero-анимация `margin-top:-23vw`.
- **≤991px** (tablet): nav → burger + полноэкранное меню (`.nav_menu-wrapper`
  получает border 2px lumen-dark, radius снизу, max-height 85dvh);
  `.nav_big-button` скрыт, показывается `.nav_mobile-cta`; grids → 1 колонка;
  faster-marquee кегль 2.3rem.
- **≤767px** (mobile landscape): h1 → 6rem; testi-карточки 20rem в колонку;
  footer 2 колонки; hero-кнопки stretch.
- **≤479px** (mobile): кнопка nav `.875rem` padding `.875rem .75rem`;
  копирайт в колонку; marquee-кегль 3.4rem (SVG масштабируется).


---

> **Дисклеймер / Disclaimer**
>
> Все материалы в данном репозитории созданы с использованием нейросетей (AI) исключительно в целях **тестирования интерфейсов**, изучения дизайн-паттернов и повторения отдельных элементов для **личных, некоммерческих, законных целей**.
>
> Содержимое **не противоречит законодательству Российской Федерации** и иных применимых юрисдикций. Автор публикует все материалы в открытом доступе для использования в **персональных проектах** (собственных сайтах, портфолио, учебных целях).
>
> Автор **не несёт никакой ответственности** за использование материалов третьими лицами. Все торговые марки, логотипы и дизайн-системы принадлежат их правообладателям.
