# COLLABORATION: two developers, one week, GitHub

This file defines who builds what for the two people writing code. `PLAN.md` holds the priorities, gates and daily goals.
Call the two developers **A** and **B**.

## 1. Why this setup

With two people and seven days, the main risks are (1) waiting on each other, (2) merge conflicts, and (3) AI-generated code that breaks the other person's work.
So the setup has three ideas:

1. **Contracts first.** The domain interfaces (`OcrService`, `ReceiptParser`, `ReceiptRepository`, `AssistantService`, `TipGenerator`, `NotificationService`, `TipRepository`) and entities are merged on Day 1. After that, A and B work in different folders against the same contracts, using fakes until the real parts exist.
2. **Folder ownership.** Each file has one owner. You can read everything, but you change only your own folders without asking.
3. **Short-lived branches, small pull requests, and CI.** Every change goes through a pull request. CI runs `flutter analyze` and `flutter test`, so Gemini's mistakes are caught before they reach `main`.

## 2. Work split

### Ownership

| Owner | Folders and files |
|---|---|
| **A: app and AI engineer** | `lib/domain/**`, `lib/data/ocr/**`, `lib/data/parsing/**`, `lib/data/capture/**`, `lib/data/assistant/**`, `lib/core/masking.dart`, `result.dart`, `env.dart`, `lib/application/scan_controller.dart`, `assistant_controller.dart`, `test/domain/**`, `test/parsing/**`, `test/fixtures/**`, `tool/**`, `eval/**` |
| **B: UI and data engineer** | `lib/presentation/**`, `lib/data/db/**`, `lib/data/settings/**`, `lib/data/export/**`, `lib/data/backup/**`, `lib/data/security/**`, `lib/data/notifications/**`, `lib/application/receipts_controller.dart`, `stats_controller.dart`, `settings_controller.dart`, `tips_controller.dart`, `lib/l10n/**`, `test/data/**`, `assets/**` |
| **Shared (small PRs, tell the other person first)** | `pubspec.yaml`, `lib/core/providers.dart`, `lib/core/feature_flags.dart`, `lib/main.dart`, `lib/app.dart`, `docs/**`, `.github/**`, `GEMINI.md` |

`lib/domain/logic/**` (`merchant_normalizer.dart`, `duplicate_detector.dart`, `category_suggester.dart`, `insights_engine.dart`, `top_merchants.dart`, `assistant_context_builder.dart`, `tip_rules.dart`, `tip_planner.dart`) belongs to A.

### Feature ownership

| Feature | Owner | Build Timeline & Order | Notes |
|---|---|---|---|
| F1 Add manually | B | Day 3 | UI route plus Review form |
| F2 Search and filter | B | Day 4 | Repository query plus home UI |
| F3 Top merchants | B (UI) with A's `top_merchants.dart` | Day 4/5 | A provides pure function |
| F4 Duplicate warning | A (logic) and B (dialog) | Day 4 | A first, then B |
| F5 Learn from corrections | A | Day 4 | `MerchantRules` table created by B |
| F6 Spending insights | A (engine) and B (cards) | Day 6 | |
| F7 PDF export | B | Day 6 | Embedded Korean TTF font |
| F8 Edge detection | A | Day 6 (P3) | Evaluation numbers are A's |
| F9 Line items | A (extractors, eval) and B (items editor) | Day 6 (P3) | |
| F10 Backup and restore | B | Day 6 (P3) | Needs explicit database path |
| F11 App lock | B | Day 6 (P3) | Test on both platforms |
| F12 AI Assistant | A (context builder, service, eval) and B (AssistantScreen UI) | Day 6/7 (Lowest P3, after F11) | Built ONLY after Gate 2 passes |
| F13 Tip notifications | A (tip rules, planner, AI tips) and B (notification service, DB table, settings) | Day 6/7 (Lowest P3, after F12) | Cut first if time is short |

### Handoffs

| From -> To | What | When |
|---|---|---|
| A -> B | Domain interfaces, entities, fakes (`FakeAssistantService`, `FakeNotificationService` under `lib/data/fakes/`) | Day 1 / Task 1 |
| A -> B | `AssistantContextBuilder` and `TipRules` | Day 6 / Task 2 & 6 |
| B -> A | `AssistantTips` table (`schemaVersion 1`) and `TipRepository` | Day 2 / Task 5 |

## 3. GitHub setup & Workflow

- Always work in dedicated branches (`feat/a-assistant-service`, `feat/b-assistant-ui`).
- Run `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`, `flutter analyze`, and `flutter test` before opening pull requests.
