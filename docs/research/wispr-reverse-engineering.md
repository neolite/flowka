# Wispr Flow — reverse engineering продуктовой и технической механики

Дата исследования: **2026-09-06**. Все URL проверены в этот день.

## 0. Методология и важное предупреждение про локальный архив

Работал по трём группам источников:

1. **Локальный архив** `docs/research/_wispr-site/` — но с оговоркой: это **не** оригинальная выкачка wisprflow.ai. Каждый файл архива содержит дисклеймер «Design Specimen Archive, vol. 03», прямо говорящий, что это воссоздание сайта генеративными моделями «в образовательных целях» и что архив «не претендует на полноту, точность или актуальность извлечённых данных» (например: `docs/research/_wispr-site/astro/src/content/blog/ai-auto-edits.md`, строки 3–54). Числовые данные архива расходятся с живым сайтом (30+ языков против 100+; macOS 13+ против macOS 12+; «словарь на 50 слов в free» против реального словаря без такой формулировки). Поэтому архив используется только как **вторичный/корроборующий** источник и всегда помечается как «локальный архив».
2. **Живой сайт** wisprflow.ai (главная, /pricing).
3. **Официальный Help Center** docs.wisprflow.ai — самый ценный источник: документация поддержки описывает механику продукта прямым текстом.

Приложение не установлено, бинарник не анализировался. Технические детали внутренней реализации (CGEventTap, процессы и т.п.) взяты из публичного стороннего форензик-расследования и помечены как сторонние.

Контекст компании: на главной висит баннер «Wispr raises $81M to build the Voice OS» (https://wisprflow.ai/). По security FAQ: «Wispr AI, Inc. is a privately held Delaware C-corporation, founded in 2023» (https://docs.wisprflow.ai/articles/3467817258-security-and-compliance-faq).

Обозначения: **[ЦИТАТА]** — прямая цитата с указанием источника; **[ДОГАДКА]** — моя интерпретация, не подтверждённая источником; «не нашёл» — данных нет.

---

## 1. Как устроен ввод

### Режим по умолчанию: push-to-talk (удержание)

**[ЦИТАТА]** Help Center, «What is Flow?» (https://docs.wisprflow.ai/articles/2772472373-what-is-flow):

> «On Mac and Windows, hold the hotkey to dictate and release to stop and paste; double-press for hands-free mode.»

> «On Mac, press fn; on Windows, press Ctrl + Win together. Hold to dictate, release to stop; double-tap the same keys for hands-free mode. All shortcuts are customizable in Settings.»

Дефолтные биндинги (сводно, Help Center):

| Действие | Mac (с Apple fn) | Mac (без fn) | Windows |
|---|---|---|---|
| Push-to-talk | `Fn` (удерживать) | `Ctrl+Opt` | `Ctrl+Win` (у части пользователей «стоковый» дефолт `Ctrl+Shift` или `Ctrl+Alt`) |
| Hands-free | `Fn+Space` | `Ctrl+Opt+Space` | `Ctrl+Win+Space` |
| Command Mode | `Fn+Ctrl` | `Cmd+Ctrl+Opt` | `Ctrl+Win+Alt` |
| Cancel | `Esc` | `Esc` | `Esc` |
| Paste Last Transcript | `Cmd+Ctrl+V` | — | `Shift+Alt+Z` |
| Copy Last Transcript | `Cmd+Ctrl+C` | — | — |
| Open Scratchpad | `Opt+S` | — | `Win+Alt+S` |

Источники: https://docs.wisprflow.ai/articles/2612050838-supported-unsupported-keyboard-hotkey-shortcuts, https://docs.wisprflow.ai/articles/5096240724-navigating-the-wispr-flow-app-desktop-ios-and-android, https://docs.wisprflow.ai/articles/6391241694-use-flow-hands-free.

Ограничения биндингов: до 4 биндингов на действие, до 3 клавиш, обязателен модификатор (или кнопка мыши — Middle Click, Mouse 4–10 поддерживаются как самостоятельный шорткат); ~60 зарезервированных системных комбинаций (Cmd+C/Cmd+V и т.п.) запрещены (https://docs.wisprflow.ai/articles/4816967992-how-to-use-command-mode, .../2612050838).

Мобильные платформы: **[ЦИТАТА]** «On iOS, tap the mic button on the Flow keyboard (no hands-free mode). On Android, tap or hold the floating bubble» (What is Flow). На Android удержание баббла = push-to-talk, тап = hands-free; «After a successful dictation, a copy button appears next to the bubble».

### Что происходит при отпускании клавиши

**[ЦИТАТА]** What is Flow:

> «Fast transcription: Releasing the hotkey pastes the transcribed text into your active app.»

> «Does Flow show my words on screen while I'm talking? **No.** Flow captures audio while you hold the hotkey, then transcribes and pastes the finished text on release. That full-context approach lets Flow clean up filler words, punctuation, and self-corrections.»

То есть: во время удержания — только запись звука (волновая форма в Flow Bar), распознавание и «очистка» запускаются **по отпусканию**, готовый текст вставляется paste-механизмом. Текст НЕ появляется постепенно во время речи.

Лимиты сессии: **[ЦИТАТА]** «Maximum recording length is about 6 minutes on desktop and 5 minutes on iOS» (What is Flow). В hands-free режиме «Continuous dictation stops automatically after an extended session, with a warning shortly before it ends» (https://docs.wisprflow.ai/articles/7336156466-use-flow-with-remote-desktops-citrix-rdp-vdi).

Отмена: `Esc` (или Backspace в Command Mode). Двойное нажатие PTT-хоткея во время удержания «локирует» сессию в hands-free: **[ЦИТАТА]** «While dictating with push-to-talk, double-tap your push-to-talk shortcut to lock the session into hands-free» (https://docs.wisprflow.ai/articles/6391241694-use-flow-hands-free).

Прочее: Flow Bar на десктопе по умолчанию скрыт на новых установках; «Mute Music While Dictating: Default off on Mac, on on Windows» (What is Flow).

### Расхождение с локальным архивом

Локальный архив утверждает противоположное: «The pipeline runs while you talk, not after» и «Flow edits continuously, so the words you see stay clean while you keep talking» (`docs/research/_wispr-site/astro/src/content/blog/ai-auto-edits.md`). Живая документация это опровергает: текст не показывается во время речи, всё происходит on release. Маркетинговая фраза на живом сайте «Flow edits as you speak» — фрейминг, а не описание механики. **[ДОГАДКА]** «editing as you speak» в маркетинге означает, что очистка невидима пользователю и не требует его действий, а не то, что она буквально стримится в поле ввода.

---

## 2. Где происходит распознавание: локально или на сервере

**Ответ: только на сервере.** Прямые цитаты:

**[ЦИТАТА]** Help Center, What is Flow, FAQ:

> «Can I use Flow offline? **No.** Flow requires an internet connection for voice transcription.»

**[ЦИТАТА]** Security and compliance FAQ (https://docs.wisprflow.ai/articles/3467817258-security-and-compliance-faq):

> «Is Wispr Flow run from your own data center, the cloud, or deployed on-premise? **Wispr Flow is multi-tenant SaaS hosted entirely with a major US cloud provider. There is no on-premise version.**»

> «All customer data is processed and stored in the United States regardless of user location.»

> «Wispr Flow is not end-to-end encrypted in the strict cryptographic sense. The service is encrypted in transit (TLS 1.2+) and at rest, but **audio must be decrypted to produce a transcription**, so true E2E encryption is not possible.»

**[ЦИТАТА]** Главная (https://wisprflow.ai/):

> «Your voice stays yours. Your data is never sold. You choose whether data is used to help improve Flow. SOC 2 Type II, HIPAA and ISO 27001 certified.»

**[ЦИТАТА]** Research-пост о языках (https://wisprflow.ai/research/supporting-languages) — подтверждает серверный мульти-движковый ASR:

> «Flow dynamically selects the most accurate ASR (Automatic Speech Recognition) engine for each language, cutting transcription error rates by more than half in internal testing.»

### Обучение на данных (нюанс, важный для privacy)

**[ЦИТАТА]** Security FAQ:

> «Privacy Mode off (standard mode): **audio and transcription data may be used to evaluate, train, and improve Wispr's models. This is the default for trial and standard accounts.**»

> «Zero Data Retention (ZDR) is shorthand for Privacy Mode on plus Dictation cloud storage off: no training and no server-side storage of dictation data.»

То есть фраза локального архива «Audio is processed to produce your text and is not used to train models» (`docs/research/_wispr-site/astro/src/pages/features.astro`, строки 113–116) **не соответствует** текущей реальности: по умолчанию (Privacy Mode off) данные МОГУТ использоваться для обучения; отказ — через настройку. Enterprise и подписавшие HIPAA BAA — Privacy Mode принудительно включён.

Сторонние данные о субпроцессорах (не из официального DPA, который под NDA): «Subprocessors include Baseten, OpenAI, Anthropic, Cerebras, and AWS. There is no on-device mode at any tier» — обзор spokenly.app (https://spokenly.app/blog/wispr-flow-review). **[ДОГАДКА]** состав субпроцессоров правдоподобен (Baseten упоминается и как хостинг ASR-моделей в AWS us-east-1), но официально подтверждается только через DPA/Trust Center.

### Расхождение по сертификации

Главная сайта заявляет «SOC 2 Type II, HIPAA and ISO 27001 certified», но security FAQ (обновлён за ~2 дня до 2026-09-06) уточняет: предыдущие SOC 2 Type II и ISO 27001 были **аннулированы в марте 2026** из-за «platform integrity concerns at the original auditor» (аудитор Delve/Accorp фигурировал в скандале с фейковыми аудитами); новый SOC 2 **Type I** получен в апреле 2026 от A-LIGN, Type II — «observation period underway; report not yet issued», ISO 27001 Stage 2 в процессе. Бейдж на главной, по-видимому, опережает фактическое состояние аудитов.

---

## 3. Задержка

**Официальной цифры в миллисекундах на сайте/в документации — не нашёл.** Есть только относительное заявление компании, переданное прессой:

**[ЦИТАТА]** TechAmerica.ai о запуске Android (2026-02-24, https://techamerica.ai/wispr-flow-launches-an-android-app-for-ai-powered-dictation):

> «Alongside the Android launch, the company also announced an infrastructure rewrite that it says makes dictation **30% faster than before**.»

Сторонние замеры (не официальные, приводить как ориентиры):

- Обзор mrktcorrect (2026-05, https://mrktcorrect.com/blog/wispr-flow-review): «The whole cycle for a one-sentence message takes **under two seconds**. For a 200-word prompt, it takes about as long as you take to say it, **plus another second of processing**».
- Обзор spokenly.app: «End-to-end latency is **reported at under 700 ms at p99 by Baseten**, the model-hosting infrastructure Wispr uses on AWS us-east-1. In practice, the cloud round-trip feels closer to **1 to 2 seconds** for most users».
- Обзор belreos.com (2026-08, https://belreos.com/blog/wispr-flow-review-2026): «the cloud round-trip adds **one to two seconds** of latency, which is fine for dictating paragraphs but noticeable if you want word-by-word feedback».
- Обзор aireviewzones.com утверждает «The system targets a processing delay of less than 700 milliseconds» — источник цифры не указан, **[ДОГАДКА]** это перефраз того же репорта Baseten.
- Негативный случай: китайский пользователь сообщает «Sometimes the recognition is very slow, taking over ten seconds» (https://jimmysong.io/blog/uninstalling-wisperflow/).

Скоростные маркетинговые цифры: «4x faster than typing», демо «Keyboard 45 wpm / Flow 220 wpm» (https://wisprflow.ai/). Реальные пользовательские цифры: 154 wpm в среднем у автора mrktcorrect (по встроенной статистике); ~102 эффективных wpm у автора Reddit-треда r/Productivitycafe (цит. по https://instantowl.com/blog/wispr-flow).

---

## 4. Что делает «AI cleanup»

### Официальные формулировки

**[ЦИТАТА]** Главная (https://wisprflow.ai/), блок «How it works»:

> «Flow edits as you speak. Text that reads like you wrote it, not like you spoke it. **Flow automatically removes filler words, adds punctuation, and formats your writing.**»

В демо на главной подсвечиваются конкретные классы правок: «Cleaning up… **Filler identified / Correction identified / Repetition identified**».

**[ЦИТАТА]** Главная, FAQ (сравнение со встроенной диктовкой):

> «**Catches your corrections.** Say "let's meet at 5... actually 6pm" and built-in dictation writes all of it. Flow gives you "Let's meet at 6pm."»

> «**Formats as you speak.** Numbered lists, paragraphs, structured emails. Built-in dictation gives you a wall of text; Flow gives you something ready to send.»

> «**Gets uncommon names and terms right.** Flow uses your personal dictionary and context to nail names, acronyms, and jargon.»

### Пример «до/после» с живой главной (реплика ~120 слов)

До (сырая речь):

> «Umm, hope your week has started well…I was talking to Cheyene earlier but reception was really bad and I think their going to handle the first part of the project, but I'm not totally sure. Also, I told the team the the new timeline should be ready by Friday, although it's probably going to slip. There's been a lot of back and forth and honestly the the whole thing's been kind of chaotic, like nobody really knows what's going on so can you check in with them…»

После (Flow):

> «Hope your week is off to a good start. I was talking to Cheyene earlier, but the reception was really bad. I think they're going to handle the first part of the project, but I'm not totally sure. I also told the team the new timeline should be ready by Friday — although it might slip. There's been a lot of back and forth, and honestly, the whole thing has been a bit chaotic. It feels like nobody really knows what's going on. Can you check in with them and see if the notes from yesterday's meeting were sent out, or if they're still waiting? I think Cheyene mentioned it, but didn't confirm — and now I'm a little lost!»

(Тот же пример продублирован в локальном архиве: `docs/research/_wispr-site/astro/src/components/HeroSpeech.astro`.)

Второй пример с главной: «Hey so um can you actually wait can you tell the team that the the launch is gonna slip I think to like not Friday the following Monday…» → «Can you let the team know the launch is slipping to Monday? We're still waiting on legal to sign off on the new terms page. We'll have a firm timeline by end of day Thursday.»

### Классы правок по документации

Help Center «Smart Formatting & Backtrack» (https://docs.wisprflow.ai/articles/5373093536-how-do-i-use-smart-formatting-and-backtrack):

- **Backtrack** — удаление слов-паразитов, ложных стартов и самоисправлений: **[ЦИТАТА]** «Use a trigger word like "actually" or "scratch that," or simply restate what you meant — Flow uses your full dictation as context to decide what to change». «Phrases like "I actually enjoyed the movie" are preserved when the surrounding context doesn't suggest a correction».
- **Контекстное форматирование**: продолжение с середины предложения — строчная буква в начале + недостающие пробелы; в мессенджерах срезается точка в конце (стиль зависит от Writing Style: Formal сохраняет точки, Casual/Very casual — срезает; полный список мессенджеров: Messages, WhatsApp, Slack, Discord, Telegram, Signal, Teams, WeChat, Line, Lark, Google Chat, Beeper, Texts).
- **Структурное форматирование**: списки, письма, «press enter» (команда, только десктоп), File Tagging, пунктуация.
- **Стили/тон**: «Make Flow sound like you — Flow adapts to how you write in different apps. Set a different style for messages, work chats, emails, and more» (главная). Стили: Formal / Casual / Very casual.

В Help Center также есть статья «How to Use Auto Cleanup (Beta)» (ссылка в related-статьях Command Mode) — гранулярные настройки очистки выкатываются; полного текста не снимал.

Локальный архив (помечаю как вторичный источник, т.к. это воссоздание) описывает пайплайн пятью шагами: filler removal → false-start merging → repetition collapse → punctuation from prosody → formatting on command (`docs/research/_wispr-site/astro/src/content/blog/ai-auto-edits.md`, строки 81–91). Это согласуется с классами правок из живой документации и демо («Filler/Correction/Repetition identified»).

**[ДОГАДКА]** Судя по классам правок и формулировке «Flow uses your full dictation as context», очистка — это LLM-постобработка полного транскрипта (а не правило-based фильтр), что объясняет и удалённые самопоправки, и ошибки «переписывания» (жалобы в п.11).

Встроенная статистика считает правки: «Corrections by Flow: Transcription corrections Flow made automatically — filler words like "um" and "like" — plus dictionary and snippet substitutions» (https://docs.wisprflow.ai/articles/8760230576-your-usage-tab-track-your-dictation-stats-in-wispr-flow).

---

## 5. Context awareness (активное приложение + содержимое экрана)

Это официально задокументированная фича, включённая по умолчанию.

**[ЦИТАТА]** Help Center, «Context Awareness» (https://docs.wisprflow.ai/articles/4678293671-feature-context-awareness):

> «**Context Awareness reads your active app and adapts transcription accuracy, style, and formatting automatically** — so emails sound like emails and Slack messages sound like Slack messages. **It's on by default.**»

> «Flow reads **a limited amount of text near your cursor** and identifies your active app, sorting it into one of four categories: Email, Work messaging, Personal messaging, and Other. **Per-dictation context — captured text, extracted names, and counts — is cleared as soon as the dictation ends.**»

Детали из той же статьи:

- В браузерах определяется конкретный сайт (Slack в Chrome = Work messaging, Gmail в Chrome = Email); продукты Google распознаются по отдельности; системные процессы и сам Flow исключаются.
- **Точность через экран**: «Flow uses **names and context visible on screen (such as email recipients)** to recognize proper nouns and preserve capitalization».
- **Стиль под категорию приложения**: применяются Style Personalization-настройки, заданные при онбординге.
- Умное форматирование в Notion и AI-чатах (игнор плейсхолдеров «Reply to Claude…»).
- Платформы: Mac (full), Windows (partial), Android (rolling out), iOS (limited). Выключается в Settings → Data & Privacy.
- На Android фича работает через Accessibility Service, отключена в банковских приложениях.

**[ЦИТАТА]** Privacy Policy (https://wisprflow.ai/privacy-policy):

> «If you enable the optional Context Awareness feature, we may collect **limited, relevant content from the specific app in use (such as the text on the screen)** to enhance the accuracy of Wispr Flow's Outputs.»

**[ЦИТАТА]** Security FAQ (ответ на «Does Wispr capture screenshots?»):

> «Captured screen context is **not retained** by Wispr when Privacy Mode is on / Dictation cloud storage is off.»
> «Note: With Dictation cloud storage on and Privacy Mode off, **screen-context fields may be persisted alongside the transcript**.»

**[ЦИТАТА]** What's new (https://wisprflow.ai/whats-new), про Android:

> «Flow on Android now **reads the surrounding text in your input field before transcribing**. That means it can continue your sentences naturally, match the tone of what you've already typed, and avoid repeating words.»

Разрешения: на macOS для контекстных фич запрашивается Screen Capture (в рантайме, не при онбординге): «Screen Capture permission (used for context-aware features) is requested at runtime when needed» (https://docs.wisprflow.ai/articles/9363440133-deploy-wispr-flow-via-mdm). В remote-сессиях контекстное форматирование не работает: «Flow can't read the surrounding text in a remote window» (https://docs.wisprflow.ai/articles/7336156466).

### Скандал вокруг фичи

Стороннее форензик-расследование (https://www.wensenwu.com/thoughts/wispr-flow-investigation, обсуждалось на HN: https://news.ycombinator.com/item?id=47781148) утверждает, что клиент «silently captures every URL you visit, reads your screen content, stores hundreds of megabytes of audio, and uploads data hourly». По данным обзоров (modelpiper.com, metawhisp.com), в мае 2026 Reddit-пользователь опубликовал сетевые трейсы загрузок скриншотов на сторонние AI-серверы; аккаунт забанили, CTO Sahaj Garg публично извинился за бан; архитектуру не меняли. Обзор belreos.com резюмирует по документации Wispr: контекст, отправляемый с запросом, «can include the app you are using, textbox contents before and after your cursor, on-screen text, variable and file names in coding apps, a screenshot, and conversation history», если не включён Privacy Mode. Эти утверждения — сторонние; официальная документация формулирует мягче («limited, relevant text content»).

---

## 6. Personal dictionary / custom vocabulary

**[ЦИТАТА]** Главная (https://wisprflow.ai/):

> «**Flow learns your vocabulary.** Flow learns your unique words and names **automatically, or lets you add them yourself**. From client names to company jargon, it gets the details right.»

На главной показан UI: «Add a new word / Add to vocabulary / Correct a misspelling / Share with team». То есть три пути: ручное добавление, авто-обучение, и исправление опечатки (misheard-слова).

Механика и лимиты (Help Center):

- **[ЦИТАТА]** «Vocabulary adaptation: Flow learns your words, names, and technical terms over time for more accurate transcription» (What is Flow).
- Лимиты: **[ЦИТАТА]** «custom dictionary entries 30 characters; snippet triggers 60 characters; snippet expansions 4,000 characters» (Security FAQ). И: «Dictionary entries are limited to 30 characters, with **at most 200 words synced at a time**» (What is Flow). Внимание: статья «Transcription suddenly got worse» (https://docs.wisprflow.ai/articles/6901148133) говорит «each dictionary word and snippet trigger can be up to 60 characters» на Mac/Windows — в документации есть расхождение 30 vs 60 символов.
- Командная шера: **[ЦИТАТА]** «Team-shared snippets and dictionary entries are available on Team, Business, and Enterprise plans. Sharing is org/home-team wide» (Security FAQ).
- Имена собственные дополнительно ловятся через Context Awareness: «Flow uses names and context visible on screen (such as email recipients) to recognize proper nouns and preserve capitalization» (см. п.5).
- Статистика: словарные фиксы считаются отдельно в Usage-табе («dictionary fixes»); у автора mrktcorrect — «446 dictionary fixes on my account in 90 days».
- Импорт: «Bulk Import: Import dictionary and snippets from JSON via Settings → Experimental (paid plans)» (What is Flow).
- Ограничения платформ: на Android (beta) словарь недоступен; «on Android, replacement text for dictionary words is not editable — add or edit it on Mac, Windows, or iOS».

**[ДОГАДКА]** «Correct a mispelling» + подсчёт «dictionary fixes» означают, что ручная правка транскрипта записывается как пара «неправильно → правильно» и подмешивается в последующие распознавания (так это описано и в локальном архиве: «Correct once, remembered forever», `docs/research/_wispr-site/astro/src/pages/features.astro`; прямого официального описания механики обучения — не нашёл).

**[ДОГАДКА]** Обучение словарю «голосом» (без мыши) — в реальной документации прямого утверждения не нашёл; в локальном архиве это есть («Teaching the dictionary by voice», `blog/voice-is-an-accessibility-feature.md`), но архив ненадёжен.

---

## 7. Многоязычность и code-switching

**[ЦИТАТА]** Главная, FAQ:

> «Yes, Flow supports **100+ languages**. For the best accuracy, **select the specific language you're speaking at that moment rather than relying on auto-detect**. If you switch between languages during the day, the language picker lives right in the Flow bar, so changing is one click away.»

Точное число по документации: «Flow supports **104–105** dictation languages, 12 of them 'confident': English, Spanish, Portuguese, French, **Russian**, German, Italian, Dutch, Japanese, Turkish, Polish, and Catalan» (https://docs.wisprflow.ai/articles/5096240724-navigating-the-wispr-flow-app-desktop-ios-and-android).

Уровни качества (https://docs.wisprflow.ai/articles/4048537120-what-to-expect-from-flow-accuracy-and-known-limitations):

- «Dedicated formatting» (списки, письма, типографика): English, French, German, Hindi, Italian, Portuguese, Spanish, Thai, Japanese, Korean. Остальные — «general-purpose formatting and remain less reliable than English». **Русского в списке dedicated formatting нет.**
- «Highest transcription confidence»: включает русский (см. выше).
- **[ЦИТАТА]** «Non-English transcription is not yet as accurate as English.»

### Code-switching: что заявлено и что нет

**[ЦИТАТА]** «Use Flow with multiple languages» (https://docs.wisprflow.ai/articles/3191899797-use-flow-with-multiple-languages):

> «**Detection happens per session: Flow picks a language at the start of each session, not per word. If you switch languages mid-sentence, Flow transcribes the entire segment in one language.**»

> «**Flow does not support rapid language switching within a single sentence.** English paired with Spanish, French, or German performs better than English paired with Chinese or Japanese.»

> «Flow works best when you speak **primarily in one language with occasional words from another**, rather than alternating sentence by sentence.»

> «**Avoid Auto-detect if you code-switch frequently.** Manually selecting 2–3 languages gives better results than letting Flow guess from 100+.»

Особый режим Hinglish: **[ЦИТАТА]** «With Hinglish selected, Hindi speech is romanized into Hinglish and English speech is formatted as normal English» — единственный официально «смешанный» язык.

Research-пост (https://wisprflow.ai/research/supporting-languages) подтверждает работу над code-mixing: «Ongoing code-mixing experiments: For Hinglish speakers, Flow now outputs romanized Hindi ("tum kya kar rahe ho") correctly without switching scripts». Там же: «accent confidence scoring» — сравнение нескольких гипотез транскрипта против акцентов.

**Про русский с английскими терминами (конкретный вопрос):** прямого утверждения не нашёл. Из общих правил следует: русский — в списке confident, поэтому «русский + редкие английские термины» попадает в официально поддерживаемый сценарий «primarily in one language with occasional words from another». **[ДОГАДКА]** слепое смешение «предложение русское → предложение английское» в одной диктовке будет транскрибировано одним языком (per-session detection).

Забавное противоречие: маркетинговое демо на главной показывает ВНУТРИ предложения переключение (англ. фраза с вставкой испанского «How le gustaría configke to set up the file»), а документация прямо говорит, что мид-сентенс переключение не поддерживается. 

Мутуально исключающие варианты: English American↔British, Hindi↔Hinglish, Chinese Simplified↔Traditional, German↔Swiss German.

---

## 8. Команды голосом (Command Mode, Backtrack, форматирование)

### Command Mode (Pro, десктоп)

**[ЦИТАТА]** What is Flow, FAQ:

> «Command Mode is a **Pro feature on desktop** that lets you **control text editing and web search by voice**. The shortcut is **Fn+Ctrl on Mac and Ctrl+Win+Alt on Windows**; enable it in Settings → Experimental. Voice triggers such as **"hey flow" and "search Google for" are English-only**. Command-mode text editing is not available on iOS.»

**[ЦИТАТА]** «How to use Command Mode» (https://docs.wisprflow.ai/articles/4816967992-how-to-use-command-mode):

> «Hold a shortcut, say the command, release — and Flow executes it without touching the keyboard. Requires a paid plan.»
> «Speak your command while holding the shortcut. **Release the shortcut to run it.** Press ESC or Backspace at any time to cancel. Releasing almost immediately dismisses the session instead.»
> «Double-press the shortcut quickly to lock Command Mode hands-free… triple-press quickly to dismiss.»

На free-плане хоткей Command Mode «does nothing». Комбинировать можно с редактированием текста (выделить/заменить/переместиться) и веб-поиском.

### Голосовые команды внутри диктовки (без отдельного режима)

**[ЦИТАТА]** Smart Formatting (https://docs.wisprflow.ai/articles/5373093536):

- **Backtrack**: триггерные слова «actually», «scratch that» или простое переформулирование — Flow убирает предыдущий фрагмент.
- **Форматирование по команде**: списки, письма, «**press enter**» (только десктоп, подавляется в Command Mode), File Tagging.
- Уведомления при первом использовании фич (Lists, Emails, File Tagging, Backtrack, Punctuation).

### Vibe Coding (для IDE)

**[ЦИТАТА]** What is Flow: «Vibe Coding IDE settings: **Code-symbol recognition in VS Code, Cursor, and Windsurf; @file tagging in Cursor and Windsurf**».

### Что из «AI commands» не подтвердилось

Локальный архив показывает команды-фразы «make it shorter», «translate to French», «turn this into an email», «make this more professional» (`docs/research/_wispr-site/astro/src/pages/features.astro`, строки 36–41; блог `flow-for-developers.md`: «turn this into bullets», «rewrite as a question»). В живой документации **такого списка команд не нашёл** — там фигурируют Command Mode, Backtrack, форматные команды (списки/письма/press enter) и «hey flow». **[ДОГАДКА]** архив сгенерировал правдоподобные, но не проверяемые примеры; реальный список команд, вероятно, живёт внутри продукта/ченджлогов, а не в публичных доках.

---

## 9. Вставка текста в активное поле: clipboard vs keystroke injection

### Официальная механика

**[ЦИТАТА]** Help Center, «Use Flow with remote desktops» (https://docs.wisprflow.ai/articles/7336156466-use-flow-with-remote-desktops-citrix-rdp-vdi) — самая откровенная официальная формулировка:

> «Flow runs on your local computer and uses your local microphone and **clipboard**. When you dictate, Flow transcribes locally, **copies the text to your local clipboard, then presses the standard paste shortcut (Cmd+V on Mac, Ctrl+V on Windows)**. The remote desktop receives the paste only if clipboard sharing is enabled. **Flow does not detect remote desktop clients or apply client-specific handling — it pastes the same way into every application.**»

Итого: вставка = «положить в системный буфер обмена + синтезировать нажатие Cmd+V/Ctrl+V». Для перехвата хоткея и синтеза нажатий нужны системные разрешения: на macOS — Accessibility («Only Flow needs Microphone and Accessibility permissions», https://docs.wisprflow.ai/articles/6478598909-using-flow-with-linux-wsl-and-terminal-applications) + Screen Capture для контекстных фич; на Windows при вставке в привилегированные окна — запуск Flow «as administrator».

Сторонний разбор (GitHub-проект портирования на Linux, https://github.com/wispr-flow-linux/wispr-flow-linux) подтверждает архитектуру: «Wispr Flow's **keystroke injection** uses an in-process /dev/uinput virtual keyboard», «**clipboard-based paste**», плюс чтение выделенного текста через accessibility-шину (AT-SPI). Форензик-расследование wensenwu.com (macOS) описывает: «a `keyboard-listener` binary and a `text-injector` binary, both with system-wide keyboard access via macOS Accessibility permissions», активный **CGEventTap** (фильтрующий, может подавлять события, возвращая NULL), буферизация клавиатурных событий `_keyEventBuffer`, и «**Clipboard interception and restoration** (`DelayedClipboardProvider`)» — т.е. буфер обмена сохраняется и восстанавливается вокруг вставки. Это сторонние данные, но они объясняют официальную механику «clipboard + paste».

### Документированные проблемы совместимости

- **Remote desktop / VDI** (официально): «On macOS, dictating into a remote-desktop / VDI client (Microsoft Windows App / RDP, VNC, Amazon WorkSpaces, macOS Screen Sharing, Splashtop, TeamViewer, and others) **may insert a stray character instead of your text**. Your transcript isn't lost — it's on your clipboard» (7336156466). Citrix: вставка требует включённого clipboard redirection политикой IT. Если удалённый клиент запущен с правами администратора — Flow не может вставить («Update admin settings to paste!»). Внутри remote-сессий не работает контекстное форматирование.
- **macOS Secure Keyboard Entry** (официально, https://docs.wisprflow.ai/articles/8841649969): «If fn+space or Escape suddenly stop working while hold-to-talk still works, another app on your Mac is holding Secure Event Input». Частые виновники: 1Password (фокус в поле пароля), Terminal/iTerm2 с включённым Secure Keyboard Entry. Примечательно: «macOS keeps delivering modifier-key events, so holding Fn still works, but blocks regular key presses — so Space (hands-free) and Escape (cancel) stop responding».
- **WSL / Linux VM / SSH** (официально): «Direct paste is not supported in WSL terminals, Linux VMs, or remote SSH sessions; use Paste last transcript there» (6478598909).
- **Терминалы с Kitty keyboard protocol**: GitHub-issue (https://github.com/earendil-works/pi/issues/8778): вставка Wispr Flow «does nothing» в редактор pi в интегрированном терминале VS Code на Windows при активном Kitty-протоколе; «Wispr Flow's synthetic input (simulated Ctrl+V paste of the transcript, injected via synthetic key events) never reaches pi's editor». Там же ссылка на аналогичный класс проблемы с Claude Code (anthropics/claude-code#38620).
- **Windows (Electon-сборка)**: по Reddit-репортам (цит. по spokenly.app, getvoibe.com): ~800 MB RAM и ~8% CPU в простое; «freezing target applications like VS Code and Notepad++»; приложение добавляет себя в автозагрузку при каждом запуске.
- **Android**: баббл не появляется в полях пароля, числовых полях и «a range of banking and financial apps»; при неудачной вставке — «the bubble offers a **paste-from-clipboard fallback**» (What is Flow).
- **Залипание хоткея / конфликты**: Reddit r/WisprFlow «How i fixed wispr flow from freezing randomly»: fn «умирает» из-за цепочки Karabiner → macOS Globe-handler (`AppleFnUsageType`) → CGEventTap, который «macOS will silently disable… if its callback takes longer than ~300ms to respond». Форензик wensenwu описывает баг залипшего модификатора в `curKeysDown`, из-за которого «every single spacebar press was interpreted as the dictation shortcut and suppressed — 145 spacebar presses in 10 minutes».
- **iOS**: диктовка требует переключения на клавиатуру Flow (лишний тап); по App Store-отзывам — крэши, «external keyboard conflicts on iPad» (цит. по instantowl.com).

**[ДОГАДКА]** «Stray character» в macOS RDP-клиентах — это, вероятно, артефакт того, что синтетическое событие вставки интерпретируется клиентом как одиночный кейстрок (клиент не ждёт paste-события от нативного моста буферов); прямого объяснения в доках нет, Wispr просто описывает симптом и воркэраунд.

---

## 10. Ценообразование и лимиты бесплатного тарифа

По живой странице https://wisprflow.ai/pricing (снята 2026-09-06):

| План | Цена | Ключевое |
|---|---|---|
| Free | $0 | Диктовка во всех приложениях, 100+ языков, словарь, Notetaker (Mac), SOC 2/ISO, HIPAA-ready (BAA), опциональный отказ от обучения |
| Pro | **$15/user/mo** помесячно или **$12/user/mo** при годовой оплате ($144/год) | Безлимитная диктовка, advanced AI-модели, ранний доступ, приоритетная поддержка, команды (общий словарь/сниппеты, биллинг, админка) |
| Growth/Enterprise | **от $18/user/mo** годовых ($23 помесячно) | SSO/SAML, SCIM, принудительный HIPAA, политика обучения на уровне орг., audit logs, network controls, CSM, оплата инвойсом/PO |

**Лимиты Free (словы/неделя):**

**[ЦИТАТА]** Главная, FAQ: «Flow's is free, with no trial countdown or credit card required, for **2,000 words per week**. If you want unlimited dictation, upgrade to Flow Pro.»

**[ЦИТАТА]** What is Flow: «Word limits: **Desktop Basic is capped weekly** (the cap is shown in Settings → Plans; **resets Sunday 12 a.m. PT**). **iOS Basic has a 1,000-word/week soft limit and a 1,500-word/week hard cap**, with upsell modals at each threshold. **Pro, Student, Trial, Team, and Enterprise plans have unlimited words.**» Плюс из Security FAQ: «**Free-plan word limits are enforced client-side only**» (т.е. лимит считается на клиенте). Android — безлимит (на странице сравнения помечено как limited time: «Unlimited on Android»).

**Триал:** «New desktop sign-ups get a **free trial with unlimited words, no credit card required**. Trial users can add up to 7 days via the "100 Words a Day Challenge" (dictate 100+ words per day). Referred users get a free month of Pro» (What is Flow). Длительность триала Pro — 14 дней (по обзорам instantowl.com; в самой справочной статье число дней не названо).

**Скидки:** «Students and educators with an education email get 50% off Flow Pro. We also offer discounted Flow Pro to nonprofit organizations» (pricing FAQ). На странице есть ROI-калькулятор («$12/mo против посчитанной экономии часов»).

Notetaker (отдельный продукт в бандле): free включает недельный лимит митингов; «Quick recordings under five minutes don't count toward your limit»; Pro — «more meetings kept for longer».

**Расхождение с локальным архивом:** архив показывает Free с «Personal dictionary (50 words)» и Pro за $12/mo с «14-day trial» (`docs/research/_wispr-site/astro/src/pages/pricing.astro`). Реальность: словарь есть и в Free (без явного лимита слов в описании тарифа; техлимиты — 30 символов на запись, ≤200 слов синхронизации), Pro $15/mo ($12 годовых). Архиву доверять по цифрам нельзя.

---

## 11. Известные жалобы и слабые места

Источники: Reddit (r/macapps, r/ProductivityApps, r/WisprFlow, r/Productivitycafe), Hacker News, Trustpilot (через обзорные агрегаторы), Medium, MPU Talk, сторонние обзоры. Все пункты — сторонние свидетельства; официальные подтверждения помечены.

**Рейтинг-разрыв (самый цитируемый сигнал):** Wispr Flow — 4.8/5 на iOS App Store (~8.5–10 тыс. оценок) и 4.5/5 на G2 (малая выборка), но **2.7/5 на Trustpilot** (spokenly.app, toolsexplained.com, getvoibe.com).

1. **«Работает в триале, деградирует после оплаты»** — самый частый органический паттерн жалоб на Trustpilot: «users reporting that Wispr Flow 'works 60% of the time' after the free trial ends, with accuracy and consistency dropping» (getvoibe.com; Medium-статья «The Wispr Flow Trust Gap», февраль 2026). Обзоры связывают это с cloud-only архитектурой: серверные изменения/инциденты пользователь контролировать не может. Официальных подтверждений нет.
2. **Privacy / скриншоты** — вирусные треды 2025–2026: приложение отправляет скриншоты активного окна и контекст на серверы (включая сторонние AI) — подтверждено частично самой документацией (см. п.5), но подано пользователями как недораскрытое. Пик: бан Reddit-пользователя, поднявшего тему, и публичное извинение CTO Sahaj Garg (modelpiper.com, metawhisp.com, HN 47781148). Отдельный шлейф: форензик wensenwu.com утверждает, что приложение перехватывает всю клавиатуру через активный CGEventTap, трекает URL, хранит сотни МБ аудио локально (flow.sqlite ~694 MB), не использует App Sandbox и отключает Hardened Runtime — «the opposite of SOC 2 security controls». Сторонние утверждения, Wispr публично не комментировала их целиком.
3. **Аудиторский скандал** — предыдущий аудитор SOC 2 (Delve/Accorp) уличён в фейковых аудитах; Wispr аннулировала свои SOC 2 Type II и ISO 27001 в марте 2026 и переходит на A-LIGN (Type I получен, Type II на наблюдении). HN-тред: «the fact they used Delve for SOC2 compliance gives me major pause» (https://news.ycombinator.com/item?id=47667811). Официально подтверждено security FAQ (см. п.2).
4. **Windows-версия (Electron)** — ~800 MB RAM и ~8% CPU в простое; фризы целевых приложений (VS Code, Notepad++); самовосстановление в автозагрузке (Reddit, цит. по spokenly/getvoibe). Mac-версия считается нативной и «лучше себя ведёт».
5. **Цена и модель оплаты** — $15/mo ($144/год) без lifetime-опции против Superwhisper $8.49/mo или lifetime $249.99 (по metawhisp, в 2026 lifetime вырос до $849), VoiceInk $29, MacWhisper $59. Жалобы: «subscription-only pricing with no lifetime option — $144/year minimum» (getvoibe).
6. **Лимиты Free** — 2,000 слов/неделю на десктопе «runs out quickly for daily use» (instantowl, Reddit r/Productivitycafe).
7. **AI переписывает слова** — «Wispr Flow will replace some [of] my words» (MPU Talk, talk.macpowerusers.com); «AI cleanup sometimes rewrites what you said instead of transcribing it» (spokenly). Это оборотная сторона cleanup-пайплайна.
8. **Галлюцинации и качество не-английских языков** — китайский пользователь: «Hallucinated content appears repeatedly, several times a day… Sometimes the recognition is very slow, taking over ten seconds» (jimmysong.io). Официально: «Non-English transcription is not yet as accurate as English» (help center). Трилингвальный пользователь: немецкая фраза транскрибирована в противоположную по смыслу (instantowl).
9. **Надёжность хоткея** — «умирающий» fn (Karabiner, macOS Globe-обработчик, отключение CGEventTap macOS при медленном колбеке, Reddit r/WisprFlow); залипший Right Option, подавляющий пробел (wensenwu).
10. **Совместимость вставки** — remote desktop/Citrix (официально, см. п.9), Secure Keyboard Entry (1Password, Terminal — официально), WSL/SSH (официально), Kitty-протокол в терминалах (GitHub issue), банковские приложения на Android (официально).
11. **Cloud-only, нет офлайна** — «unusable on flights, in remote locations…» (weesperneonflow.ai и др.); официальное подтверждение: «Flow requires an internet connection».
12. **Мелочи, которые бесят**: AirPods/Bluetooth ухудшают точность (официально: «We recommend against AirPods and other Bluetooth earbuds for dictation»); установка >500 MB (системное требование — 500 MB свободного места; jimmysong: «takes up over 500 MB of disk space»); реферальные награды «not honored» (getvoibe/Medium); iOS требует переключения клавиатуры на каждую сессию; «приватность» API-экспорта свернули («API-based export is no longer available; the API has been sunsetted» — Security FAQ).

---

## Приложение A. Сводная таблица механики (коротко)

- Хоткей: **удержание Fn (Mac) / Ctrl+Win (Windows)**; отпускание → ASR в облаке → cleanup → вставка через clipboard+Cmd/Ctrl+V. Текст во время речи не показывается. Лимит записи ~6 мин (десктоп).
- Распознавание: **только облако** (multi-tenant SaaS, US), выбора «локально» нет ни на одном тарифе.
- Очистка: fillers, повторы, ложные старты, самоисправления («actually», «scratch that»), пунктуация, списки/письма, стиль под категорию приложения, срез точек в мессенджерах.
- Контекст: читает приложение + текст у курсора (+ имена с экрана); включён по умолчанию; вычищается после диктовки; может персиститься при выключенном Privacy Mode.
- Словарь: авто-обучение + ручное добавление + «correct a misspelling»; ≤30 символов на запись, ≤200 слов синхронно; шера в командах.
- Языки: 100+ (104–105), 12 «confident» (вкл. русский); определение per-session; мид-сентенс переключение НЕ поддерживается; Hinglish — особый режим.
- Команды: Command Mode (Pro, десктоп, Fn+Ctrl / Ctrl+Win+Alt, release-to-run, «hey flow», «search Google for»); Backtrack; форматные команды.
- Вставка: буфер обмена + синтетический Cmd/Ctrl+V, одинаково во все приложения; Accessibility-разрешения; известные несовместимости — RDP/Citrix, Secure Keyboard Entry, WSL, Kitty-протокол.
- Цена: Free (2,000 слов/нед. десктоп; 1,000/нед. iOS) / Pro $15-mo·$12-год / Enterprise от $18-год.

## Приложение B. Локальные файлы, использованные как источник

- `docs/research/_wispr-site/astro/src/pages/index.astro` — FAQ, фичи, цифры (вторично)
- `docs/research/_wispr-site/astro/src/pages/features.astro` — cleanup-пример, privacy-формулировка (вторично)
- `docs/research/_wispr-site/astro/src/pages/pricing.astro` — тарифы архива (вторично; расходится с реальностью)
- `docs/research/_wispr-site/astro/src/pages/download.astro` — платформы, шаги онбординга (вторично)
- `docs/research/_wispr-site/astro/src/components/HeroSpeech.astro` — пример до/после (совпадает с живым сайтом)
- `docs/research/_wispr-site/astro/src/content/blog/*.md` — 4 поста: auto-edits, developers, accessibility, why-voice (вторично; посты датированы 2026 с вымышленными, судя по всему, авторами)

## Приложение C. Основные веб-источники

- Живой сайт: https://wisprflow.ai/ , https://wisprflow.ai/pricing , https://wisprflow.ai/privacy-policy , https://wisprflow.ai/whats-new , https://wisprflow.ai/research/supporting-languages
- Help Center: статьи 2772472373 (What is Flow), 2612050838 (Shortcuts), 6391241694 (Hands-free), 4816967992 (Command Mode), 5373093536 (Smart Formatting & Backtrack), 4678293671 (Context Awareness), 3191899797 (Multiple languages), 4048537120 (Accuracy & limitations), 5899191431 / 3490087531 (wrong language), 7336156466 (Remote desktops), 8841649969 (Secure Keyboard Entry), 6478598909 (Linux/WSL/terminal), 5096240724 (Navigating the app), 8760230576 (Usage tab), 6901148133 (Transcription got worse), 3467817258 (Security FAQ), 9363440133 (MDM)
- Сторонние расследования/обзоры: wensenwu.com/thoughts/wispr-flow-investigation (+ HN 47781148), modelpiper.com, metawhisp.com (screenshot-capture), belreos.com, spokenly.app, getvoibe.com, instantowl.com (x2), mrktcorrect.com, toolsexplained.com, weesperneonflow.ai, jimmysong.io, techamerica.ai, aloa.co, thepell.com, 345tool.com, beebom.com, aireviewzones.com
- Сообщества: Reddit r/WisprFlow (freezing fix), r/macapps, r/ProductivityApps, r/Productivitycafe (цит. по обзорам), talk.macpowerusers.com, GitHub: earendil-works/pi#8778, anthropics/claude-code#38620, wispr-flow-linux
