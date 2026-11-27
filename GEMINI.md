# GEMINI.md: Project context for the AI coding agent

You are helping two students build **Receipt Scanner**, a Flutter final project for a Mobile Programming course.
The students must be able to **explain every file in a live demo**, so clarity beats cleverness.

Read these before writing any code, in this order:
1. `docs/PRD.md` - what we are building and what is out of scope
2. `docs/ARCHITECTURE.md` - layers, folders, data flow, interfaces
3. `docs/SCHEMA.md` - the database
4. `docs/DESIGN.md` - the UI spec (glassmorphism, tokens, screens)
5. `docs/PLAN.md` - the 7-day plan and which day we are on

If a request conflicts with these docs, **stop and ask** instead of silently changing the design.

---

## 1. Product in one paragraph

An offline-first Flutter app (Android + iOS). The user photographs a receipt (Korean or English), on-device ML Kit OCR reads it,
a rule-based parser extracts **merchant, date, total**, and a Gemini API call is used **only as a fallback** when parser confidence is low.
The user reviews and corrects the result in a plain form, saves it to a local Drift/SQLite database, and sees spending by category and by month.
No login. No server. Data stays on the device. All database tables (`Categories`, `Receipts`, `ReceiptItems`, `MerchantRules`, `AssistantTips`) are created at **schemaVersion 1**.

**Extended scope (v2 & v3):** manual entry, search and filter, top merchants, duplicate warning, learning from the user's category corrections, spending insights, PDF export and share, edge detection and auto-crop, line-item extraction, backup and restore, app lock, **v3 AI assistant chat (F12)**, and **v3 tip notifications (F13)**. Priorities, gates and feature flags are in section 9 and in `docs/PRD.md` sections 12 and 13.

## 2. Locked tech stack (do not add packages without asking)

| Purpose | Package |
|---|---|
| State management | `flutter_riverpod` |
| Local database | `drift`, `drift_flutter`, `sqlite3_flutter_libs`; dev: `drift_dev`, `build_runner` (schemaVersion 1) |
| OCR | `google_mlkit_text_recognition` (use the **Korean** script recognizer, it also reads Latin text) |
| Image input | `image_picker` (system camera and gallery) |
| Charts | `fl_chart` |
| Localization | `flutter_localizations`, `intl` (ARB files, `flutter gen-l10n`) |
| Settings storage | `shared_preferences` (language, theme, fallback toggle, assistant & tips toggles) |
| Env config | `flutter_dotenv` |
| HTTP for Gemini | `http` (call the Gemini REST API directly; do not use deprecated SDKs) |
| Paths | `path_provider`, `path` |
| Tests | `flutter_test`, `mocktail` |
| PDF export | `pdf` (embed a Korean-capable TTF font, see `docs/ARCHITECTURE.md` section 12) |
| Sharing files | `share_plus` |
| Backup zip and restore picker | `archive`, `file_picker` |
| App lock | `local_auth` (check the current API in its README) |
| Edge detection and auto-crop | a document-scanner package that supports **both** Android and iOS. Verify on pub.dev before adding (for example `cunning_document_scanner`). If none works on both platforms, the feature stays off. |
| Local notifications (F13) | `flutter_local_notifications`, `timezone`, `flutter_timezone` |

Rules for dependencies:
- Prefer the latest stable versions on pub.dev. Run `flutter pub add <pkg>` instead of hand-writing versions.
- Everything must work on **both Android and iOS**. No Android-only or iOS-only packages.
- Follow each plugin's README for platform setup (Android minSdk, notification channels, `POST_NOTIFICATIONS` runtime permission, broadcast/alarm receivers per `https://pub.dev/packages/flutter_local_notifications`, core library desugaring in `build.gradle.kts`; iOS `AppDelegate.swift` standard initialization without plugin registrant callback since no background isolates are used).

## 3. Architecture rules (non-negotiable)

Layers, from outside in: `presentation -> application -> domain <- data`.

- **domain/** is pure Dart. No Flutter imports, no packages except `meta`. Holds entities and abstract interfaces.
- **data/** implements the domain interfaces (ML Kit OCR, parsers, Drift repository, Gemini client, local notification service). Fakes live under `lib/data/fakes/`.
- **presentation/** holds screens and widgets. **No business logic in widgets.** Widgets read Riverpod providers and call controller methods.
- Parsers depend on `OcrResult` (plain data), **never on ML Kit types**. This lets us unit-test parsing without a phone.
- Wire dependencies in `lib/core/providers.dart` only. Swapping an implementation must be a one-line change there.

## 4. Coding rules

1. **Money is an `int` in minor units.** Never use `double` for money. KRW has 0 decimal places, USD has 2. Use `Money` helpers in `domain/`.
2. **No hardcoded user-visible strings.** All text goes through `AppLocalizations` (`app_en.arb`, `app_ko.arb`).
3. **No hardcoded colors, radii or text styles in widgets.** Use the theme tokens from `DESIGN.md` in `lib/presentation/theme/`.
4. Null safety everywhere. Prefer `final`, `const` constructors and small files (aim for under 200 lines).
5. Errors are values at layer boundaries: return a `Result<T>` or throw a typed `AppFailure`. Never swallow exceptions silently, and never show raw exception text to users.
6. Every public class and every non-obvious function gets a short doc comment that says **why**, not what.
7. Where you make a design trade-off, add a `// WHY:` comment of one or two lines. The students will read these.
8. Async code: handle loading, error and empty states for every screen.
9. Do not use `BackdropFilter` inside list items (performance). See `DESIGN.md`.
10. Keep `flutter analyze` at **zero warnings** and use the lints in `analysis_options.yaml`.

## 5. Secrets and privacy rules

- Real keys live only in `.env` (git-ignored). `.env.example` is the committed template.
- Never print, log or commit the API key. Add `.env` to `.gitignore` and register it under `flutter: assets:` in `pubspec.yaml` as `flutter_dotenv` requires.
- **OCR Fallback Data**: Only **masked OCR text** (card, phone, and business registration numbers replaced with `*`) may be sent to Gemini for receipt parsing, **never the image**.
- **AI Assistant (F12) & AI Tips (F13) Data**: Gemini receives **only precomputed aggregate JSON** generated locally by `AssistantContextBuilder` (monthly totals, category sums/shares, MoM %, structured insights). **NEVER send merchant names, item names, raw OCR text, images, individual receipt dates or amounts, or IDs.**
- **Google AI Free Tier Terms Disclosure**: Per Gemini API terms of service (`https://ai.google.dev/gemini-api/terms`), on the free tier Google may use submitted content to improve its products and human reviewers may read it. The terms state not to submit personal information to unpaid services. Apps available to users in the EEA, Switzerland, or the UK must use paid services, and users must be 18+. The consent dialog in the app and the PPT outline explicitly state this disclosure, noting that **this demo uses test data only** and that a public release would require migrating to the paid Gemini API tier.
- The Gemini OCR fallback, AI Assistant, and AI Tips are **optional**: they must obey their respective Settings toggles, timeouts from `.env`, and must fail gracefully to local deterministic fallbacks.
- Local notification text contains **NO amounts and NO merchant names** unless the user explicitly enables "Show amounts in notifications" (off by default).

## 6. How to work (workflow)

- Work on **one task at a time**, the one named in the prompt or in the current day of `docs/PLAN.md`.
- Before coding: state in 3-5 lines what you will create or change and which files.
- After coding, always run, and report the results of:
  ```bash
  dart run build_runner build --delete-conflicting-outputs   # only when Drift or generated files changed
  flutter gen-l10n                                          # only when ARB files changed
  flutter analyze
  flutter test
  ```
- Add or update unit tests with each feature (see the testing section of `docs/ARCHITECTURE.md`).
- Finish each task with: **what changed, how to run it, what to verify manually, what is still missing.**
- Use small commits, Conventional Commit style: `feat(parser): detect total from Korean keywords`.
- If something in the docs is ambiguous or wrong, **ask**. Do not invent requirements.

## 7. Do NOT

- Do not add login, cloud sync, Firebase, FCM, or any backend.
- Do not use background task packages like `workmanager`.
- Do not persist chat history (keep in-memory only, cleared on app restart or manual clear action).
- Do not add features outside the list in `docs/PRD.md` sections 12 and 13 (no budgets, no standalone custom scan alarm reminders, no CSV export, no cloud, no login).
- Do not call any network service except the Gemini REST endpoint.
- Do not rewrite working code "to improve it" outside the current task.
- Do not generate large files in one shot. Build step by step so students can follow.
- Do not leave `TODO` or placeholder implementations without listing them in your final report.

## 8. Definition of done (for any task)

- [ ] Builds and runs on Android and iOS (or you list what you could not verify)
- [ ] `flutter analyze` is clean and `flutter test` passes
- [ ] Strings localized in English and Korean
- [ ] Loading, empty and error states handled
- [ ] No secrets, no `print` debugging left
- [ ] Short explanation of the design choices written for the students

---

## 9. Feature priorities, gates and flags (v2 & v3)

The full feature list is in `docs/PRD.md` sections 12 and 13. The core app always comes first.

| Priority | Features |
|---|---|
| **P0 core** | Scan -> review -> save -> list, stats (donut and bars), settings, Korean and English UI |
| **P1** | Add manually, search and filter, top merchants, duplicate warning |
| **P2** | Learn from corrections, spending insights, PDF export and share |
| **P3 (risky)** | Edge detection and auto-crop, line items, backup and restore, app lock, **AI assistant chat (F12)**, **Tip notifications (F13)** |

**Feature flags.** `lib/core/feature_flags.dart` defines one `const bool` per P1, P2 and P3 feature, all `false`. A feature's UI entry points are shown only when its flag is `true`.
*Why:* unfinished or unverified work can be merged into `main` without ever appearing in the demo, so `main` always stays demo-ready. A flag is switched to `true` only when the feature passes the Definition of done **and** has been tested on a real device.

**Gates** (see `docs/PLAN.md`): if the core loop is not working on a real phone at the end of Day 3, stop all feature work. If P0 and P1 are not finished at the end of Day 5, stop starting new P2 or P3 features. F12 and F13 are the lowest priority P3 features (built on Day 6/7 after F11, and cut first if time is short). Work on F12/F13 starts ONLY after Gate 2 passes (or after an explicit "override gate" command).

**Architecture for every new feature:** an interface in `domain/`, an implementation in `data/`, logic in pure Dart where possible, tests for the logic, and strings in both ARB files. See `docs/ARCHITECTURE.md` sections 12 and 13.

**Extra privacy rules for v2 & v3**
- Line-item extraction sends **masked OCR text only** to Gemini, never the image, and only if the Settings toggle is on.
- AI assistant and personalized tips send **precomputed aggregate JSON only** (no merchant/item names or raw OCR), only if their respective toggles are on.
- Google AI terms disclosure (`https://ai.google.dev/gemini-api/terms`): free tier usage by Google for product improvement, human review, no personal info on unpaid services, EEA/UK/Switzerland restriction, 18+ age limit, test data only for demo. Must be disclosed in consent dialog and PPT.
- PDF reports and backup files contain personal spending data. Show a short warning before sharing them. Never upload them anywhere ourselves; sharing happens only through the system share sheet.
- The app lock protects the UI only. It does not encrypt the database. Do not describe it as encryption.
- The database must be opened from an **explicit file path** (`getApplicationDocumentsDirectory()/app.sqlite`) so backup and restore know where it is.
