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

# Wispr Flow — cheatsheet (одностраничная выжимка)

> Источник: https://wisprflow.ai/?ref=producthunt · сводка по 00–05 md + css/tokens.css + css/components.css · 2026-07-29

## Продукт и вайб (две строки)
AI voice-to-text диктовка «Flow»: превращает сбивчивую речь в чистый текст в любом приложении, обещание — **4x faster than typing** (220 wpm голосом против 45 wpm на клавиатуре). Платформы Mac / Windows / iPhone / Android.
Вайб — тёплый «аналоговый» light-theme: кремово-лимонный фон, глубокий тёмно-бирюзовый вместо чёрного, лиловый акцент; крупные serif-заголовки с экстремально плотным трекингом; «бумажно-наклейчатая» глубина через твёрдые тени и 2px-обводки (никакого glass/blur).

**Тема: светлая** (тёмные секции строятся на fathom `#034f46` и vast `#1a1a1a`).

## Топ-10 цветов (имя · HEX · роль)
1. `lumen` `#ffffeb` — главный фон (тёплый ivory)
2. `vast` `#1a1a1a` — текст, бордеры, тёмные панели
3. `fathom` `#034f46` — тёмно-бирюзовый: тёмные секции/карточки
4. `dawn` `#f0d7ff` — лиловый: кнопки, активные табы
5. `glow` `#ffa946` — оранжево-жёлтый CTA
6. `flare` `#ff6c4c` — коралловый (ошибки/акценты)
7. `signal` `#ffbcf2` — розовый (подложки отзывов)
8. `pulse` `#7f1c34` — бордо (error-red-dark, текст ошибок)
9. `lumen-dark` `#e4e4d0` — тёмный lumen: бордеры панелей, hover-фон
10. `paper` `#fffdf9` — hover нав-ссылок (+ `faded #8a8a80` — «выцветшая» часть hero)

Семантика: `--background-color--background-primary` = lumen; `--secondary` = dawn; `--tertiary` = vast; `--text-primary` = vast; `--text-secondary` = lumen; `--border-primary` = `#1a1a1a4d` (vast 30%); `--border-secondary` = vast; focus-state = `#2d62ff`.

## Топ-5 градиентов (дословно из кода)
1. dawn-вейл: `linear-gradient(#fff0, #f0d7ffbf)`
2. фейд краёв лент: `linear-gradient(180deg, #fff0, var(--background-color--background-primary) 54%)`
3. оверлей стат-карточек: `linear-gradient(#fff0, #000000b3)`
4. фиолетовый акцент (фото-плейсхолдеры): `linear-gradient(#be9de9, #a75eff)`
5. двойной radial-glow: `radial-gradient(circle at 100% 100%, #dd23bb40, #0000 40%), radial-gradient(circle at 0 100%, #2d62ff4d, #0000 60%)`
   (CTA-плита реконструирована как `radial-gradient(120% 90% at 50% 0%, #0a6b5f, #034f46 55%, #02332d)` — производная от fathom).

## Шрифтовой стек
- **display** — `"EB Garamond"` (в оригинале `"Eb garamond"`, веса 400 + 400 italic) → заголовки h1–h6, цитаты, стат-цифры. Fallback `Georgia, serif`.
- **body / UI** — `Figtree` (400/500/600/700) → параграфы, кнопки, нав, чипы, eyebrow. Fallback `Arial, sans-serif`.
- **mono** — `Monaspace Neon` 300 (в оригинале); публичный аналог **`IBM Plex Mono`** → wpm-метрики, snippet-код, dev-bar.
- Подключение: оригинал — `@font-face` с Webflow CDN (Google Fonts не используется); в demo/testsite EB Garamond + Figtree взяты через Google Fonts, mono заменён на IBM Plex Mono.
- Глобально: `-webkit-font-smoothing: antialiased; text-rendering: optimizeLegibility`.

## 5 главных стилей шкалы (size / line-height / letter-spacing)
- **h1** — `7.5rem` (120px) / `.85` / `-.05em` (моб. `h1-small` = `6rem`, lh `.95`)
- **h2** — `4rem` (64px) / `.95` / `-.03em` (есть `h2-big` = `4.6875rem`)
- **h3** — `3rem` (48px) / `1.1` / —
- **h4** — `2rem` (32px) / `1.3` / `-.03em`
- **body medium** (базовый `p`) — `1.125rem` (18px), `font-weight: 500`
  (доп.: lead/large `1.25rem`; small `.875rem`; eyebrow Figtree 500 `.875rem` ls `.08em`; цитаты EB Garamond italic lh `.95` ls `-.03em`).

## Easing-кривые и типовые duration
- **default ease** (токен `--wf-ease`): `cubic-bezier(.25, .1, .25, 1)`.
- **scroll-reveal / pane / accordion** (CSS-эквивалент GSAP ScrollTrigger): `cubic-bezier(.22, .61, .36, 1)`, `~.6–.8s` (reveal `.7s`, pane `.45s`, accordion `.35s`).
- **easeOutCubic** для count-up: `1 - (1-p)^3`, `1200ms`.
- Тактильные hover/press: кнопка `transform .2s` → `scale(.98)`; nav-link `border-color .3s, color .3s, background-color .3s`; dropdown-toggle `background-color .2s`; dropdown_link `background-color .2s` + сдвиг `padding-left .2s`; tab-pill `margin .3s, transform .3s`; use-case стрелка `transform .3s`; footer-иконка `all 300ms`; banner-link `opacity .3s`; nav-линии `opacity .2s`; nav-spacer `height .2s`; nav-pill `border-radius .2s, border-color .2s`; blog-underline `text-decoration-color .25s ease`.
- **Marquee / бесконечные ленты**: `logoTicker1 60s linear infinite` (логотипы); `bannerTicker 18s linear infinite` (тикер); `testiScroll 55s linear infinite` (отзывы, pause on hover); SMIL `<animate>` hero `35s`, faster keyboard `100s` / flow `45s` (linear, infinite).
- **Спиннер** `.button.loading`: `spin .7s linear infinite` (`@keyframes spin { to { transform: rotate(360deg) } }`).
- **Плавающие тосты / footer-orb**: `toastFloat 5–7s ease-in-out alternate`.
- **Появление hero-тостов**: `cta-verb-test-fallback-show 0s linear 2.5s forwards` (дословный keyframe оригинала).
- Focus-ring: `outline .125rem solid #4d65ff; outline-offset .125rem`.

## Радиусы
Кнопка `.5rem` · nav-pill `.6rem` · nav-link `1rem` · promo `10px` · checkbox `.125rem` · avatar `50%` · cta_dot `100rem` · chip-pill `62–62.5rem` (full pill).
Секционные токены: `--tiny 2rem` (use-case card, testi inner) · `--small 2.5rem` (faster-панели, feature grid-card) · `--regular 3rem` (testi_card) · `--large 5rem` (integrations-плита, CTA).

## Тени (box-shadow, дословно)
- Твёрдая «наклейка»: `2px 2px 0 0 #1a1a1a` и `3px 3px #000` (главный приём глубины).
- Лиловое свечение dawn: `0 61px 24px #f0d7ff08, 0 34px 21px #f0d7ff1a, 0 15px 15px #f0d7ff2b, 0 4px 8px #f0d7ff33`.
- Мягкие: `0 4px 16px #00000040` · `0 4px 20px #0000001a`.
- Маркерный хайлайт текста: `inset 0 -25px 0 0 var(--base-color--dawn)`.
- (Glow/tilt/border-gradient эффектов **нет** — сайт сознательно плоский.)

## Контейнеры и поля
`container-small 48rem` · `container-medium 62rem` · `container-large 77.5rem` (вариант `._1200px → 75rem`) · `nav_component 64rem` · `padding-global 2.5rem` (≤991px → `1.25rem`).
Вертикальный ритм — spacer-утилиты `xsmall .5 → small 1 → medium 1.5 → large 3 → xlarge 4 → huge 6 → xhuge 8 → xxhuge 10 rem`; секции `padding-section medium 6 / large 8 / xlarge 10 rem`.

## 5 ключевых паттернов («как узнать этот сайт»)
1. **SVG text-path «речевой поток»** в hero: две изогнутые кривые с бегущим текстом диктовки — сырой (weight 400, opacity .4, с «umm…», повторами слов) → чистый (weight 600, белый на жирной тёмной кривой `stroke #1A1A1A stroke-width 30`); `<animate>` по `x`, infinite. Метафора продукта.
2. **H1 с «выцветшей» половиной**: `Don’t type, ` в `#8a8a80` + `just speak` полным `#1a1a1a`; EB Garamond 7.5rem, ls `-.05em`, lh `.85`.
3. **Пиллы-табы use-cases** с `rotate(-4deg)` в активном состоянии и «прыгающим» `margin-top` на hover; активная пилла — фон dawn.
4. **Сравнение скоростей**: панель «Keyboard · 45 wpm» (серый прямой marquee, светлая рамка 4px) против «Flow · 220 wpm» (белый marquee на тёмной fathom-панели).
5. **Плоская глубина**: никаких blur/glass — вся объёмность через 2px твёрдые обводки vast, тени `2px 2px 0 0 #1a1a1a` / `3px 3px #000`, крупные радиусы секций до 5rem и чередование светлых/тёмных «плит» (lumen ↔ fathom). Плюс фирменный ask-AI-уголок (рамка 4px сверху+справа) и «липкое» нажатие кнопок `scale(.98)`.

## Мини-гайд «воспроизвести стиль за 5 минут»
1. **Подключи** `css/tokens.css` (все переменные + алиасы `--wf-*`) и `css/components.css` (готовые `.btn`, `.chip-pill`, `.tab-pill`, `.card-usecase`, `.testi-card`, `.faster-grid`, `.ask-ai`, `.footer-*`, `.marquee-*`, `.banner`, `.nav-*`, `.form-input`). Шрифты — Google Fonts: `EB Garamond:ital@0;1` + `Figtree:wght@400;500;600;700` (+ `IBM Plex Mono` для mono).
2. **База**: `body { background: lumen #ffffeb; color: vast #1a1a1a; font: Figtree; }`; все заголовки — `EB Garamond 400`, плотный трекинг (`-.03…-.05em`), `line-height .85–.95`.
3. **Кнопки**: `border: 2px solid vast; border-radius: .5rem; font-weight: 600; transition: transform .2s; :hover { transform: scale(.98) }`; варианты фона — dawn (default), lumen (secondary), vast (dark), glow (yellow), прозрачный (text/transparent).
4. **Секции**: чередуй светлый lumen и тёмные «плиты» fathom с `border-radius: 5rem`; обводки 2px vast, твёрдые тени `2px 2px 0 0 #1a1a1a`; контейнеры 48/62/77.5rem + поля 2.5rem.
5. **Включи движение**: добавь `@keyframes logoTicker1` (60s) и `bannerTicker` (18s) для лент; `spin` для loading-кнопок; scroll-reveal через IntersectionObserver (`opacity 0→1`, `translateY(24px)→0`, `.7s cubic-bezier(.22,.61,.36,1)`); SVG `<textPath>` + `<animate>` для hero/faster-потоков; `rotate(-4deg)` на активном tab-pill; count-up на стат-цифрах. Обязательно `@media (prefers-reduced-motion: reduce)` — гасить анимации. Респонсив-брейкпоинты: `991px` (burger + стек grids), `767px` (h1→6rem, testi→колонка), `479px` (marquee-кегль растёт, nav-кнопка компактнее).


---

> **Дисклеймер / Disclaimer**
>
> Все материалы в данном репозитории созданы с использованием нейросетей (AI) исключительно в целях **тестирования интерфейсов**, изучения дизайн-паттернов и повторения отдельных элементов для **личных, некоммерческих, законных целей**.
>
> Содержимое **не противоречит законодательству Российской Федерации** и иных применимых юрисдикций. Автор публикует все материалы в открытом доступе для использования в **персональных проектах** (собственных сайтах, портфолио, учебных целях).
>
> Автор **не несёт никакой ответственности** за использование материалов третьими лицами. Все торговые марки, логотипы и дизайн-системы принадлежат их правообладателям.
