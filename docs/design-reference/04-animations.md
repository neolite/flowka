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

# Wispr Flow — анимации

> Источник: https://wisprflow.ai/?ref=producthunt · main.css + 20 inline `<style>`-блоков + GSAP-атрибуты в HTML · 2026-07-29

## 1. `@keyframes` — дословно

### logoTicker1 — marquee логотипов клиентов (inline CSS)
```css
.clients_cms-wrapper {
  animation: logoTicker1 60s linear infinite;
}
@keyframes logoTicker1 {
  from { transform: translateX(0%); }
  to   { transform: translateX(-100%); }
}
```
Четыре дублирующих `.clients_cms-wrapper` бегут влево; контент дублируется для бесшовности.

### cta-verb-test-fallback-show — фолбэк A/B-теста hero (inline CSS)
```css
html.cta-verb-test-loading body {
  visibility: hidden;
  animation: cta-verb-test-fallback-show 0s linear 2.5s forwards;
}
@keyframes cta-verb-test-fallback-show {
  to { visibility: visible; }
}
```

### spin — единственный keyframe в main.css
```css
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
```
(спиннер `.button.loading`; сам `.loading` дополнительно показывает rolling-svg фоном).

### bannerTicker — закомментирован в inline CSS (тикер сейчас статичен/JS)
```css
/*
.banner_mega-wrapper { animation: bannerTicker 10s linear infinite; }
@keyframes bannerTicker {
  from { transform: translateX(0%); }
  to   { transform: translateX(-100%); }
}
*/
```

## 2. SVG `<animate>` — речевые потоки (SMIL, не CSS)

Hero, левая кривая (сырой текст, `#marquee-text-hero1`):
```html
<animate id="marquee1-anim" attributeName="x" dur="35s" values="-3300; 0" repeatCount="indefinite"/>
```
Hero, правая кривая (чистый текст, `#marquee-text-hero2`, кривая `stroke:#1A1A1A; stroke-width:30`):
`dur="35s"`, `values="-4500; 0"`, infinite.

Faster-секция, «Keyboard» (`#marquee-text-str`, fill `#8d8d83`):
```html
<animate attributeName="x" dur="100s" values="-4000;0" repeatCount="indefinite"/>
```
Faster-секция, «Flow» (`#marquee-text`, fill `#FFFFEB`): тот же паттерн, быстрее (~45s),
кегли масштабируются по брейкпоинтам `1.375rem → 2.3rem → 3.4rem`.

## 3. Transitions на hover/press (property · duration · easing)

| Элемент | Transition |
|---|---|
| `.button` (все варианты) | `transform .2s, color .3s` (default ease); hover → `scale(.98)` |
| `.nav_menu-link` | `border-color .3s, color .3s`; hover → border #1a1a1a + bg #fffdf9 |
| `.nav_menu-dropdown-toggle` | `background-color .2s`; hover → bg `#e4e4d0` |
| `.nav_menu-dropdown-toggle-v2` | `background-color .2s`; hover → bg `#fffdf9` |
| `.dropdown_link` | `background-color .2s` (+ сдвиг `padding-left .5rem → .75rem`); hover → bg lumen-dark, color fathom |
| `.use-cases_tab-link` | `margin .3s, transform .3s`; active → `rotate(-4deg)` |
| `.use-cases_arrow-icon` | `transform .3s`; hover карточки → `translate(10px, -10px)` |
| `.banner_text-link` | `opacity .3s`; hover → `.75` |
| `.footer_link-block .icon-embed-xxsmall` | `all 300ms`; `opacity 0→1`, `translateX(-10px)→0` |
| `.nav_left-line / .nav_right-line` | `opacity .2s` (появляются при открытом мобильном меню) |
| `.nav_spacer` | `height .2s` |
| `.nav_container-v2` | `border-radius .2s, border-color .2s` |
| `.blog-v2-item h2/h3` | `text-decoration-color .25s ease`; hover → `currentColor` (underline 3px) |
| `*[tabindex]:focus-visible` | outline `0.125rem solid #4d65ff`, offset `0.125rem` |

## 4. Hamburger-анимация (hamburger_12, inline CSS)

Переменные: `--thickness: .125rem; --gap: .375rem; --rotate: 45`.
Hover: линии сжимаются каскадом `85% / 65% / 100%`. Open (`.w--open`):
```css
.w--open .hamburger_12_line { width:100% !important; transform: scaleX(0); }
.w--open .hamburger_12_line:first-child {
  transform: translateY(calc(var(--thickness) + var(--gap))) rotate(calc(var(--rotate) * 3 * 1deg)); } /* 135deg */
.w--open .hamburger_12_line:last-child {
  transform: translateY(calc(var(--thickness) * -1 + var(--gap) * -1)) rotate(calc(var(--rotate) * 1deg)); } /* 45deg */
```

## 5. JS-библиотеки и что они анимируют

- **GSAP 3.15** (`cdn.prod.website-files.com/gsap/3.15.0/`) + **DrawSVGPlugin**
  (рисование `#heading-underline`, stroke-width 8/12) + **MotionPathHelper**.
  Атрибуты `data-gsap-target` в HTML: `dictionary-chip`, `snippet-chip`,
  `languages-flags`, hero-кнопки, marquee-панели — скролл-триггерные reveal
  (fade/move) и «разлёт» чипов по карточкам фич.
- **Lottie** (Webflow-рендер `data-animation-type="lottie"`): hero-анимация
  «Flow header animation_toasts_trimmed v2.lottie» (тосты-уведомления над
  кривыми), footer-анимация (`.footer_lottie`, 21.5rem), faster-секция
  (`.faster_flow-lottie`). Все `data-loop="1" data-autoplay="1"`.
- **Splide 4.1 + AutoScroll 0.5** — лента отзывов `.testimonials_cards-wrap.splide`
  (бесконечный auto-scroll, пауза при hover — стандартное поведение плагина).
- **Swiper 8** — слайдеры на подстраницах (на главной следов нет).
- **Finsweet Attributes** — CMS-фильтры/комбо.

## 6. Hover-эффекты карточек

- **Use-case card**: стрелка ↗ уезжает `translate(10px,-10px)` за `.3s`.
- **Footer link**: стрелка slide-in слева (`opacity 0→1`, `translateX(-10px→0)`, 300ms).
- **Button press**: все кнопки «вдавливаются» `scale(.98)` — единый тактильный паттерн.
- **Tab pill**: активный повёрнут `rotate(-4deg)`, hover приподнимает (margin-top).
- Glow/tilt/border-gradient эффектов **нет** — сайт сознательно «плоский»,
  вся глубина — через твёрдые тени и цветные подложки.

## 7. Движение фона

- Статичных орбов/частиц/шума **нет**.
- «Живой фон» hero = две SVG-кривые с бегущим текстом + Lottie-тосты.
- Faster-панель: фото-фон (`.faster_flow-image`, object-fit cover) + белый
  текстовый marquee поверх.
- CTA «Start flowing»: тёмно-зелёная секция с `.cta_bg` (cover-изображение)
  и декоративными точками `.cta_dot` (lumen, radius 100rem).
- Градиентные вейлы: `linear-gradient(#fff0,#f0d7ffbf)` (dawn),
  `linear-gradient(180deg,#fff0,var(--background-color--background-primary) 54%)`
  — фейды краёв лент.

## 8. Scroll-эффекты

Явного Lenis/Locomotive нет; плавный скролл — нативный. Скролл-ревилы —
GSAP ScrollTrigger-паттерны через `data-gsap-target` (fade-up + масштаб
у hero-кнопок, появление чипов в фичах, draw-SVG подчёркиваний). Точные
duration/easing GSAP-твинов в статике не извлекаются (задаются в
webflow.*.js-бандлах); CSS-эквивалент для реконструкции: `opacity 0→1`,
`translateY(24px)→0`, `~.6–.8s cubic-bezier(.22,.61,.36,1)`.


---

> **Дисклеймер / Disclaimer**
>
> Все материалы в данном репозитории созданы с использованием нейросетей (AI) исключительно в целях **тестирования интерфейсов**, изучения дизайн-паттернов и повторения отдельных элементов для **личных, некоммерческих, законных целей**.
>
> Содержимое **не противоречит законодательству Российской Федерации** и иных применимых юрисдикций. Автор публикует все материалы в открытом доступе для использования в **персональных проектах** (собственных сайтах, портфолио, учебных целях).
>
> Автор **не несёт никакой ответственности** за использование материалов третьими лицами. Все торговые марки, логотипы и дизайн-системы принадлежат их правообладателям.
