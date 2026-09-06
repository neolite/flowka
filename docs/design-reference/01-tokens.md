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

# Wispr Flow — дизайн-токены

> Источник: https://wisprflow.ai/?ref=producthunt · CSS: cdn.prod.website-files.com/.../flowsite-dev.webflow.shared.b45cb3c42.min.css · 2026-07-29

Все переменные ниже — дословно из `:root` оригинала (Webflow-имена сохранены;
в `css/tokens.css` даны дополнительно короткие алиасы `--wf-*`).

## 1. Базовая палитра (base colors)

| Переменная | Значение | Роль |
|---|---|---|
| `--base-color--lumen` | `#ffffeb` | Главный фон (тёплый ivory) |
| `--base-color--lumen-dark` | `#e4e4d0` | Тёмный lumen: бордеры панелей, hover-фон |
| `--base-color--vast` | `#1a1a1a` | Текст, бордеры, тёмные панели |
| `--base-color--dawn` | `#f0d7ff` | Лиловый: кнопки, активные табы |
| `--base-color--fathom` | `#034f46` | Тёмно-бирюзовый: тёмные секции/карточки |
| `--base-color--glow` | `#ffa946` | Оранжево-жёлтый CTA |
| `--base-color--flare` | `#ff6c4c` | Коралловый (ошибки, акценты) |
| `--base-color--signal` | `#ffbcf2` | Розовый (подложки отзывов) |
| `--base-color--pulse` | `#7f1c34` | Бордо (error-red-dark, текст ошибок) |
| `--base-color--white` | `#fff` | Белый |
| `--base-color-neutral--black` | `#000` | |
| `--base-color-neutral--white` | `#fff` | |
| `--base-color-neutral--neutral-lightest` | `#eee` | |
| `--base-color-neutral--neutral-lighter` | `#ccc` | |
| `--base-color-neutral--neutral-light` | `#aaa` | |
| `--base-color-neutral--neutral` | `#666` | |
| `--base-color-neutral--neutral-dark` | `#444` | |
| `--base-color-neutral--neutral-darker` | `#222` | |
| `--base-color-neutral--neutral-darkest` | `#111` | |

Дополнительные «поверхностные» цвета из компонентов:
`#fffdf9` (hover нав-ссылок), `#8a8a80` (text-color-black20 — «выцветший» текст hero),
`#8d8d83` (marquee «клавиатурный» текст), `#f1f1e1` (hero_select_inner),
`#e8ad5f` (hero_select_send_wrap), `#34d399` (testi is-green), `#c8c8c8` (nav button open).

## 2. Семантические цвета

| Переменная | Значение |
|---|---|
| `--background-color--background-primary` | `var(--base-color--lumen)` = #ffffeb |
| `--background-color--background-secondary` | `var(--base-color--dawn)` = #f0d7ff |
| `--background-color--background-tertiary` | `var(--base-color--vast)` = #1a1a1a |
| `--background-color--background-alternate` | `var(--base-color--white)` = #fff |
| `--background-color--background-success` | `#cef5ca` |
| `--background-color--background-warning` | `#fcf8d8` |
| `--background-color--background-error` | `#f8e4e4` |
| `--text-color--text-primary` | `var(--base-color--vast)` = #1a1a1a |
| `--text-color--text-secondary` | `var(--base-color--lumen)` = #ffffeb (текст на тёмном) |
| `--text-color--text-tertiary` | `var(--base-color--dawn)` = #f0d7ff |
| `--text-color--text-alternate` | `#fff` |
| `--text-color--text-success` | `#114e0b` |
| `--text-color--text-warning` | `#5e5515` |
| `--text-color--text-error` | `var(--base-color--pulse)` = #7f1c34 |
| `--base-color-system--success-green` / `-dark` | `#cef5ca` / `#114e0b` |
| `--base-color-system--warning-yellow` / `-dark` | `#fcf8d8` / `#5e5515` |
| `--base-color-system--error-red` / `-dark` | `#f8e4e4` / `#7f1c34` |
| `--base-color-system--focus-state` | `#2d62ff` |
| `--border-color--border-primary` | `#1a1a1a4d` (vast 30%) |
| `--border-color--border-secondary` | `var(--base-color--vast)` = #1a1a1a |
| `--border-color--border-alternate` | `#222` |
| `--link-color--link-primary` | `var(--base-color--dawn)` = #f0d7ff |
| `--link-color--link-secondary` | `var(--base-color--vast)` = #1a1a1a |
| `--link-color--link-alternate` | `#fff` |

## 3. Альфа-шкала (прозрачности двух чернил)

Dark (на базе #1a1a1a): `--alpha--dark--2 #1a1a1a05`, `--alpha--dark--5-2 #1a1a1a0d`,
`--alpha--dark--5-3 #1a1a1a0d`, `--alpha--dark--10 #1a1a1a1a`, `--alpha--dark--15 #1a1a1a26`,
`--alpha--dark--30 #1a1a1a4d`, `--alpha--dark--50 #1a1a1a80`, `--alpha--dark--70 #1a1a1ab3`,
`--alpha--dark--90 #1a1a1a`.

Light (на базе #ffffeb): `--alpha--light--2 #ffffeb05`, `--alpha--light--5-2/5-3 #ffffeb0d`,
`--alpha--light--10 #ffffeb1a`, `--alpha--light--15 #ffffeb26`, `--alpha--light--30 #ffffeb4d`,
`--alpha--light--50 #ffffeb80`, `--alpha--light--70 #ffffebb3`, `--alpha--light--90 #ffffebe6`.

## 4. Типографика (размерные токены)

| Переменная | Значение |
|---|---|
| `--_text-collection---font--body-font` | `Figtree, Arial, sans-serif` |
| `--_text-collection---font--primary-font` | `"Eb garamond", Arial, sans-serif` |
| `--_text-collection---heading--h1` | `7.5rem` (120px) |
| `--_text-collection---heading--h1-small` | `6rem` (96px) |
| `--_text-collection---heading--h2` | `4rem` (64px) |
| `--_text-collection---heading--h2-big` | `4.6875rem` (75px) |
| `--_text-collection---heading--h3` | `3rem` (48px) |
| `--_text-collection---heading--h4` | `2rem` (32px) |
| `--_text-collection---heading--h5` | `1.25rem` (20px) |
| `--_text-collection---heading--h6` | `1rem` (16px) |
| `--_text-collection---body--xlarge` | `1.5rem` (24px) |
| `--_text-collection---body--large-medium` | `1.375rem` (22px) |
| `--_text-collection---body--large` | `1.25rem` (20px) |
| `--_text-collection---body--medium` | `1.125rem` (18px) |
| `--_text-collection---body--regular` | `1rem` (16px) |
| `--_text-collection---body--small` | `.875rem` (14px) |
| `--_text-collection---body--xsmall` | `.8125rem` (13px) |

## 5. Spacing

| Переменная | Значение |
|---|---|
| `--_spacing---spacers--medium` | `1.5rem` |
| `--_spacing---spacers--large` | `3rem` |
| `--_spacing---spacers--xx-huge` | `10rem` |
| `--_spacing---padding--xx-huge` | `14rem` |
| `--_spacing---section-paddings--medium` | `6rem` |
| `--_spacing---section-paddings--large` | `8rem` |
| `--_spacing---section-paddings--x-large` | `10rem` |

Фактическая шкала spacer-утилит: xsmall `.5rem` → small `1rem` → medium `1.5rem`
→ large `3rem` → xlarge `4rem` → huge `6rem` → xhuge `8rem` → xxhuge `10rem`.
Padding-утилиты: small `1rem`, medium `2rem`, large `3rem`, xlarge `4rem`, xxlarge `5rem`.
Паттерн: базовый шаг 0.5rem, основные узлы 1 / 1.5 / 2 / 3 / 4 / 5 / 6 / 8 / 10 rem.

## 6. Радиусы

| Переменная | Значение | Где |
|---|---|---|
| `--_spacing---section-radius--x-tiny` | `1rem` | |
| `--_spacing---section-radius--tiny` | `2rem` | use-cases card, testi inner, twitter-card |
| `--_spacing---section-radius--small` | `2.5rem` | faster-панели, features grid-card |
| `--_spacing---section-radius--regular` | `3rem` | testi_card |
| `--_spacing---section-radius--medium` | `4rem` | |
| `--_spacing---section-radius--large` | `5rem` | section_integrations-clients, CTA |

Прочие радиусы компонентов: кнопки `.5rem`; nav-контейнер `.6rem`; nav-link `1rem`;
chip-пилла `62rem`/`62.5rem` (full pill); promo-div `10px`; form_container `24px`
(моб. `12px`); checkbox `.125rem`; avatar `50%`; cta_dot `100rem`.

## 7. Тени (box-shadow, дословно)

```css
/* «лиловое свечение» dawn (hero/панели) */
box-shadow: 0 61px 24px #f0d7ff08, 0 34px 21px #f0d7ff1a, 0 15px 15px #f0d7ff2b, 0 4px 8px #f0d7ff33;
/* твёрдые «наклейчатые» */
box-shadow: 2px 2px 0 0 var(--base-color--vast);            /* = 2px 2px 0 0 #1a1a1a */
box-shadow: 3px 3px #000;
box-shadow: 0 2px 0 0 var(--background-color--background-tertiary);
/* мягкие */
box-shadow: 0 4px 16px #00000040;
box-shadow: 0 4px 20px #0000001a;
box-shadow: 1px 1px 3px #0000001a;
box-shadow: 0 0 0 1px #0000001a, 0 1px 3px #0000001a;
box-shadow: 1.1px 1.1px 1.1px #0000004d;
box-shadow: 3px 2px 2px #0006;  box-shadow: 3px 3px 2px #0006;
box-shadow: 0 2px #8c8c82;
/* focus */
box-shadow: 0 0 .25rem 0 #3898ec;  box-shadow: 0 0 3px 1px #3898ec;
/* inset */
box-shadow: inset 0 -25px 0 0 var(--base-color--dawn);   /* «маркерный» хайлайт */
box-shadow: inset 0 -2px 4px #d7cfec80;
```

## 8. Градиенты (дословно)

```css
linear-gradient(#fff0, #2d40ea1a)
linear-gradient(#000, #232222)
linear-gradient(180deg, #fff0, var(--background-color--background-primary) 54%)
linear-gradient(#0003, #0003)
linear-gradient(270deg, #fff0, #000 94%)
linear-gradient(180deg, #fff0, #ffffffbf 28%, #ffffffb3 50%, var(--background-color--background-primary))
linear-gradient(#fff0, #f0d7ffbf)                       /* dawn-вейл */
linear-gradient(270deg, var(--base-color--lumen-dark), #e4e4d000)
radial-gradient(circle at 100% 100%, #dd23bb40, #0000 40%),
radial-gradient(circle at 0 100%, #2d62ff4d, #0000 60%)
linear-gradient(#f8f4eb, #f1e4cd)
linear-gradient(#fff0, #000)
linear-gradient(90deg, #0000, var(--base-color--lumen))
linear-gradient(270deg, #000, #fff0)
linear-gradient(270deg, var(--base-color--lumen), #fff0)
linear-gradient(#fff0, #000000b3)                       /* оверлей стат-карточек */
linear-gradient(#be9de9, #a75eff)                       /* фиолетовый акцент */
linear-gradient(270deg, #fff0, var(--base-color--lumen))
linear-gradient(270deg, #e4e4d000, var(--base-color--lumen-dark))
linear-gradient(270deg, #000 6%, #fff0)
linear-gradient(270deg, #fff0, #000)
```

## 9. Breakpoints и контейнеры

Webflow-брейкпоинты: `max-width: 991px` (tablet), `767px` (mobile landscape),
`479px` (mobile). Кастомные из inline-CSS: `992px+` (desktop-меню), `1024px`,
`1085px`, `1150px`, `1199px`, `1281px`.

| Контейнер | max-width |
|---|---|
| `.container-small` | `48rem` (768px) |
| `.container-medium` | `62rem` (992px) |
| `.container-large` | `77.5rem` (1240px); вариант `._1200px` → `75rem` |
| `.padding-global` | горизонтальные поля `2.5rem` (≤991px → `1.25rem`) |
| `.nav_component` | `max-width: 64rem`, `margin-top: 1rem` |

## 10. Z-index

`nav_fixed 999` · `nav_component / banner / form_wrap / ask-ai-графика 9999`
· `nav_bottom 99999` · `usercentrics-cmp-ui 99` · `testi/hero слои 0–11`
· dropdown-стрелка `3`.

## 11. Бордеры

Базовая обводка — **2px solid**: `--border-color--border-secondary` (#1a1a1a) у
кнопок/чипов/нав-контейнера; `--border-color--border-primary` (#1a1a1a4d) —
подчёркивание инпутов; `--base-color--lumen-dark` (#e4e4d0) — рамка nav-меню и
faster_grid-left (там 4px). Ask-AI: 4px solid vast сверху и справа.
features_grid-2-chip: 4px solid #fff (на fathom) / 3px solid lumen (v2/v3).


---

> **Дисклеймер / Disclaimer**
>
> Все материалы в данном репозитории созданы с использованием нейросетей (AI) исключительно в целях **тестирования интерфейсов**, изучения дизайн-паттернов и повторения отдельных элементов для **личных, некоммерческих, законных целей**.
>
> Содержимое **не противоречит законодательству Российской Федерации** и иных применимых юрисдикций. Автор публикует все материалы в открытом доступе для использования в **персональных проектах** (собственных сайтах, портфолио, учебных целях).
>
> Автор **не несёт никакой ответственности** за использование материалов третьими лицами. Все торговые марки, логотипы и дизайн-системы принадлежат их правообладателям.
