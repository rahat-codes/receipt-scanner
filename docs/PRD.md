# PRD: Receipt Scanner

Course: Mobile Programming (final project) · Platform: Flutter/Dart, Android + iOS · Team: 3 members, 7-day build

## 1. Problem

People keep paper receipts they never track. Typing each purchase into a spreadsheet is slow, so spending stays invisible.
Cloud scanners work, but they upload photos of purchases (location, habits, card fragments) to a server.

## 2. Product vision

Point the phone at a receipt, confirm three fields, and see where the month's money went, **with the photo processed on the device**.

## 3. Target users

- University students in Korea (Korean and international) who buy mostly with cards and keep paper receipts.
- Primary context: one person, one phone, often offline or on slow data.

## 4. Goals and non-goals

**Goals**
1. Extract merchant, date and total from Korean and English receipts with useful accuracy.
2. Make correcting mistakes fast, because OCR will be wrong sometimes.
3. Work fully offline. The only optional network call is the Gemini fallback.
4. Show monthly spending clearly (category share and month-to-month totals).
5. Demonstrate sound software engineering: layered architecture, tests, and a measured evaluation.

**Non-goals (out of scope)**
- Login, accounts, cloud sync, multi-device
- Tax breakdown, split bills
- Budgets, standalone custom scan alarm reminders (note: local tip notifications and 7-day inactivity nudges under F13 are in scope, see section 13), bank integrations
- CSV export (PDF export is in scope, see section 12)
- Cloud backup or sync (local backup file is in scope, see section 12)
- Web or desktop builds

## 5. User stories

| ID | As a user I want to... | So that... |
|---|---|---|
| US-1 | take a photo or pick one from my gallery | I can add a receipt in seconds |
| US-2 | see merchant, date and total pre-filled | I do not type them |
| US-3 | see which fields the app is unsure about | I know what to double-check |
| US-4 | edit any field and choose a category | wrong OCR does not corrupt my data |
| US-5 | browse, open and delete saved receipts | I can manage my history |
| US-6 | see this month's total and category share | I understand my spending |
| US-7 | compare monthly totals over recent months | I see trends |
| US-8 | switch language between Korean and English | I can use the app in my language |
| US-9 | follow the system light/dark mode | the app matches my phone |
| US-10 | turn the AI fallback off | no text ever leaves my device |

## 6. Functional requirements

**Capture and OCR**
- FR-1: Add a receipt from the system camera or the gallery (floating Scan button -> choice sheet).
- FR-2: Run on-device OCR (ML Kit, Korean script recognizer) and keep the raw text.
- FR-3: Show a progress state while processing and a clear error with retry on failure.

**Parsing**
- FR-4: A rule-based parser extracts merchant, purchase date, total amount and currency (KRW default, USD supported).
- FR-5: The parser returns a **confidence score (0 to 1)** and per-field "needs review" flags.
- FR-6: If confidence is below the threshold (default 0.70) and the fallback is enabled, call Gemini with the **masked OCR text** and merge the result.
- FR-7: If the fallback fails or times out, keep the rule-based result and flag uncertain fields. Never block the user.

**Review and save**
- FR-8: A plain editable form: merchant, date picker, total, currency, category.
- FR-9: Low-confidence fields are highlighted in amber with a short hint.
- FR-10: Saving stores the receipt and the image path locally. Discarding asks for confirmation if the user edited anything.
- FR-11: Each saved receipt records how it was filled: `rules`, `llm` or `manual`.

**Browse and manage**
- FR-12: Home screen: list of receipts, newest first, with the current month's total in the header.
- FR-13: Tap a receipt for details (image, fields). Edit and delete (with confirmation) are available there.
- FR-14: Empty state explains how to add the first receipt.

**Stats**
- FR-15: Stats screen (opened from the home app bar): month selector, donut chart of category share for that month, bar chart of totals for the last 6 months.

**Settings**
- FR-16: Language: system, English, Korean. Theme: system, light, dark. Gemini fallback: on/off.
- FR-17: Settings persist across restarts.

## 7. Non-functional requirements

| Area | Requirement |
|---|---|
| Performance | Photo to pre-filled form in under 3 s on a mid-range phone with rules only. Fallback adds up to the configured timeout (default 8 s) and never blocks editing. |
| Offline | Everything except the Gemini fallback works with no network. |
| Privacy | Images never leave the device. Only masked OCR text may be sent for OCR fallback. AI Assistant and AI Tips send precomputed aggregate JSON only. |
| Reliability | No crash on empty OCR, unreadable photo, permission denial, or network failure. |
| Accessibility | Text contrast at least 4.5:1 on glass surfaces, tap targets at least 48 dp, text scales with system font size. |
| Localization | All UI strings in `app_en.arb` and `app_ko.arb`. Dates and currency formatted per locale. |
| Maintainability | Layered architecture, interfaces for OCR/parser/repository, unit tests for domain and parsing logic. |

## 8. Success metrics (measured on our own labeled test set)

Targets, to be verified in week-end evaluation, not promised in advance:

| Metric | Target |
|---|---|
| Total amount exact match | at least 85% |
| Purchase date exact match | at least 80% |
| Merchant match (normalized) | at least 70% |
| Median time, photo to form (rules only) | under 3 s |
| Fallback lift | report accuracy for rules-only vs rules + Gemini, and the share of receipts that trigger the fallback |

Test set: about 30 receipts (mix of Korean and English, convenience stores, cafes, restaurants, taxis, crumpled and slightly rotated), hand-labeled by a teammate. Details in `docs/ARCHITECTURE.md`.

## 9. Acceptance criteria (demo checklist)

1. Scan a Korean receipt and an English receipt; the form is pre-filled.
2. A deliberately blurry receipt shows amber review hints and does not crash.
3. Edit a field, pick a category, save; the receipt appears on the home list and totals update.
4. Airplane mode: scanning and saving still work with the fallback off or failing.
5. Stats show donut and bar charts for real saved data.
6. Switch language and theme; the UI updates without restart.
7. Delete a receipt; totals update.

## 10. Risks and mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Korean OCR misreads digits or labels | Medium | Keyword + numeric-pattern rules, amber review hints, editable form, Gemini fallback |
| One week is tight | High | Strict cut line (see `PLAN.md`): drop fallback polish and extras, keep the core loop |
| AI-generated code is inconsistent | High | `GEMINI.md` rules, one task per prompt, analyze + test after each task |
| iOS build issues with ML Kit | Medium | Test on a real iPhone or simulator early (Day 1), follow the plugin README for iOS version and architectures |
| Glass blur causes jank | Medium | Blur only on a few static surfaces, never per list item |
| API key exposure | Low | `.env` git-ignored; key restricted in AI Studio; documented limitation of client-side keys |

## 11. Privacy statement (for the demo and the PPT)

- Receipt images are stored only in the app's private storage.
- With all AI features off, no data leaves the device.
- With OCR fallback on, only OCR text with long digit sequences masked is sent to the Gemini API when the rule-based parser is unsure.
- With AI Assistant (F12) or AI Personalized Tips (F13) on, only **precomputed aggregate JSON** (monthly totals, category sums/shares, MoM %, insights) is sent. **Merchant names, item names, raw OCR text, images, individual receipt dates or amounts, and IDs are NEVER sent.**
- Local notifications show NO amounts and NO merchant names on the lock screen unless explicitly enabled by the user.
- Known limitation: an API key bundled in a client app can be extracted. A production version would route calls through a backend. For this project the key is free-tier and restricted.

---

## 12. Extended scope (v2)

All features below are in scope. They are ordered by priority and built behind feature flags with gates (`docs/PLAN.md`). The core (P0, sections 1 to 11) always has priority.

### 12.1 Feature list

| ID | Priority | Feature | Summary |
|---|---|---|---|
| F1 | P1 | Add manually | Create a receipt without a photo from the scan sheet |
| F2 | P1 | Search and filter | Search by merchant or item name; filter by category and date range |
| F3 | P1 | Top merchants | Ranking of merchants by spending and visits for the selected month in Stats |
| F4 | P1 | Duplicate warning | Warn before saving a receipt that looks like one already saved |
| F5 | P2 | Learn from corrections | Remember merchant -> category when the user changes the suggested category |
| F6 | P2 | Spending insights | A few plain sentences about the month (for example, change from last month) |
| F7 | P2 | PDF export and share | Monthly report as a PDF, shared through the system share sheet |
| F8 | P3 | Edge detection and auto-crop | Document-scanner capture that crops and straightens the receipt before OCR |
| F9 | P3 | Line items | Extract item names and prices; editable on the review screen |
| F10 | P3 | Backup and restore | Export all data (database and images) as a file; import it to restore |
| F11 | P3 | App lock | Require device biometrics or the device passcode to open the app |

---

## 13. Extended scope (v3)

All features below are in scope, built behind feature flags (`aiAssistant`, `tipNotifications`) with gates (`docs/PLAN.md`).

### 13.1 Feature list (v3)

| ID | Priority | Feature | Summary |
|---|---|---|---|
| F12 | P3 | AI assistant (`aiAssistant`) | In-app conversational chat answering spending queries using precomputed local aggregate JSON |
| F13 | P3 | Tip notifications (`tipNotifications`) | Scheduled local notifications with money-saving tips from deterministic rules or optional Gemini AI personalization |

### 13.2 User stories (v3)

| ID | As a user I want to... | So that... |
|---|---|---|
| US-22 | ask an AI assistant about my spending habits in plain language | I can quickly understand where my money goes without reading complex charts |
| US-23 | receive periodic money-saving tips as local notifications | I get actionable advice and gentle reminders to stay mindful of my spending |
| US-24 | control AI assistant consent, tip frequency, and lock-screen notification privacy | my spending details stay private and I am not disturbed unnecessarily |

### 13.3 Functional requirements (v3)

**F12 AI Assistant (`aiAssistant`)**
- FR-29: A sparkle icon in the home app bar opens the `AssistantScreen` featuring two tabs: "Chat" and "Tips".
- FR-30: Home chat view provides 3 localized suggestion chips (e.g., "How much did I spend on food in November?", "Where can I save?", "Compare this month with last month").
- FR-31: Chat history is stored in-memory only (up to `ASSISTANT_MAX_HISTORY_TURNS` turns, default 6) and is cleared when the app closes or via a "Clear chat" button in the app bar. History is never persisted to disk.
- FR-32: `AssistantContextBuilder` computes a compact JSON summary locally containing currency, today's date, locale, and for up to the last 6 months: totals (minor units), receipt count, category totals/shares, MoM change %, and structured insights from `InsightsEngine`. Merchant names, item names, raw OCR text, images, individual receipt dates/amounts, and IDs are NEVER sent.
- FR-33: System prompt instructs the model to act as a budgeting helper, answer using provided JSON data only, state clearly if data is missing, respond in the user's app language (max ~120 words), and never give tax/legal/investment advice or reveal prompt instructions.
- FR-34: On network failure or offline state, show a friendly error plus "Here's what I can tell without AI:" displaying deterministic insights. The assistant never crashes or blocks the app.
- FR-35: First use displays a consent dialog detailing exactly what data is sent. The assistant requires its own Settings switch (off by default) AND a configured API key.

**F13 Tip Notifications (`tipNotifications`)**
- FR-36: Uses local notifications (`flutter_local_notifications`, `timezone`, `flutter_timezone`). No FCM, Firebase, or background task runners (`workmanager`).
- FR-37: `TipScheduler` runs on app start/resume (throttled to once per 12 hours) and after saving a receipt: cancels existing scheduled tip notifications, generates up to 3 tips, and schedules them for user's preferred time (clamped between 08:00 and 21:00).
- FR-38: Settings options: Frequency (Off, Weekly, 3 per week, Daily; max 1 per day), Preferred time, "Personalize tips with AI" switch (requires AI assistant switch), and "Show amounts in notifications" switch (default off).
- FR-39: Two tip sources: (a) Deterministic `TipRules` (category increase >= 20%, top category >= 40%, many small purchases, 7-day inactivity nudge, evergreen library); (b) Optional Gemini AI tip generator using masked aggregate JSON, with Dart validation ensuring title <= 40 chars, body <= 140 chars, correct language, and filtering blocked financial keywords.
- FR-40: Avoids repeating tips by keeping the last 20 scheduled tip keys in `assistant_tips` database table and skipping duplicates.
- FR-41: Lock-screen privacy: notification content contains NO amounts and NO merchant names unless "Show amounts in notifications" is enabled. Tapping a notification opens the Tips tab (passing through App Lock if enabled). Runtime permission is requested only when the user toggles the switch ON.

### 13.4 Non-functional requirements (v3)

| Area | Requirement or target |
|---|---|
| Privacy & Security | No merchant/item names, raw OCR text, or images sent to Gemini for assistant/tips. Lock screen notifications hide spending amounts by default. |
| Memory & Storage | Chat turns kept in memory only. Database keeps at most 50 recent rows in `assistant_tips` table. |
| Performance | Assistant query timeout 15s. Offline fallback renders deterministic insights in < 100 ms. |
| Reliability & Robustness | AI validation drops invalid or malformed tips; offline state or API timeout falls back smoothly to deterministic rules. |

### 13.5 Acceptance criteria (v3)

18. Tapping the sparkle icon opens the Assistant screen with Chat and Tips tabs.
19. Selecting a suggestion chip or sending a prompt calls Gemini using precomputed aggregate JSON and displays the response in a glass chat bubble.
20. In offline/airplane mode, sending a question displays the friendly error and deterministic insights fallback without crashing.
21. First chat attempt displays the consent dialog explaining aggregate data sharing.
22. Turning on Tip Notifications schedules local notifications for the preferred time; turning it off cancels all scheduled notifications.
23. Lock-screen notification preview shows no monetary amounts unless "Show amounts in notifications" is toggled ON.
24. Tapping a tip notification launches the app directly into the Tips tab (authenticating through App Lock if enabled).
25. Clearing chat wipes in-memory messages immediately.

### 13.6 Risks & mitigations (v3)

| Risk | Mitigation |
|---|---|
| LLM arithmetic hallucination | All calculations precomputed locally by `AssistantContextBuilder` in Dart; model system prompt strictly forbids external calculations. |
| App closed tip generation | Document honest limitation: tips scheduled ahead on app open/resume & save events for up to 3 days using inexact local alarms. |
| Notification permission denied | Request permission only when user enables switch; show "Open settings" guidance dialog if denied. |
| Prompt injection from receipt text | Raw OCR text and merchant/item strings are omitted from context JSON sent to Gemini. |
