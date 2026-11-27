# PLAN: 7 days, full scope with gates

Current day: **Day 1** (update this line each morning; Gemini reads it)

The scope is the core app (P0) plus all extended features (v2 and v3: see `docs/PRD.md` sections 12 and 13). That is more work than two people can normally finish in a week, so the plan is built to **degrade gracefully**: the core is protected, features are built in priority order behind flags, and three gates decide what continues.

## 1. Priorities

| Priority | Features | Rule |
|---|---|---|
| **P0 core** | Scan -> review -> save -> list, stats (donut, bars), settings, Korean and English UI, parser tests, evaluation | Never cut |
| **P1** | F1 Add manually, F2 Search and filter, F3 Top merchants, F4 Duplicate warning | Small, build first |
| **P2** | F5 Learn from corrections, F6 Spending insights, F7 PDF export and share | Build after P1 |
| **P3** | F8 Edge detection, F9 Line items, F10 Backup and restore, F11 App lock, **F12 AI Assistant (`aiAssistant`)**, **F13 Tip Notifications (`tipNotifications`)** | Risky, gated, lowest priority |

## 2. Gates

| Gate | When | Condition to continue | If it fails |
|---|---|---|---|
| **Gate 1** | End of Day 3 | Scan -> review -> save works on a real phone (both platforms checked at least once) | Stop all feature work. Fix the core before anything else |
| **Gate 2** | End of Day 5 | P0 and P1 finished; first evaluation numbers exist | Do not start new P2 or P3 features (including F12 and F13). Finish only what is already in progress |
| **Gate 3 (freeze)** | Morning of Day 7 | Nothing new after this | Unfinished features stay behind their flag (off) and go on the "future work" slide |

**Strict Gate Check Rule for F12 & F13:** F12 and F13 are lowest-priority P3 features. On Day 1/2, Gate 2 has NOT passed yet. Therefore, update documentation ONLY in STEP 1. Implementation (STEP 2) occurs ONLY on Day 6/7 after Gate 2 passes and F11 is built, or after the user explicitly writes `"override gate"` or `"start STEP 2"`.

A feature flag is set to `true` only when it meets the Definition of done in `GEMINI.md` **and** has been tested on a real device.

## 3. Daily plan

| Day | Goals | Done when |
|---|---|---|
| **1** | Skeleton, packages, `feature_flags.dart`, domain contracts and fakes, theme tokens, camera and gallery capture, ML Kit OCR on a real photo on **Android and iOS**, GitHub, CI, branch protection. Check whether a cross-platform document-scanner package exists (for F8) | OCR text of a real receipt shows on both platforms; PR #1 merged |
| **2** | `Money`, extractors, `RuleBasedParser` with tests. Drift schema with **all five tables** at `schemaVersion 1`, repository (including search, month receipts, duplicates, items, tips), tests. Start collecting receipts | Parser tests pass on at least 10 snippets; repository tests pass |
| **3** | `ScanController`, image storage, permissions. Review form with amber hints and validation, manual entry route (F1), save to DB. **Gate 1** | Scan -> edit -> save -> row in DB on a real phone |
| **4** | Home (slip, list, empty state, scan sheet), detail, delete with undo, processing dialog. Search and filter (F2). `normalizeMerchant`, duplicate detector (F4), category suggester and learning (F5) with tests | Core loop complete; search works; duplicate dialog works |
| **5** | Stats (donut, bars), top merchants (F3), Settings, ARB strings in both languages. Masking, `LlmParser`, `CompositeParser`. Start `RuleItemsExtractor` behind its flag. **Gate 2** | P0 and P1 complete; evaluation of rules vs composite runs |
| **6** | Insights engine (F6), PDF export (F7), then P3 in this order if the gates allow: edge detection (F8), line items (F9), backup and restore (F10), app lock (F11), **AI assistant (F12)**, **tip notifications (F13)**. Dark mode and accessibility pass | Each finished feature verified on a device before its flag goes on |
| **7** | **Freeze in the morning.** Fix bugs, final device tests on both platforms, README, demo video, PPT, clean-clone test, tag `v1.0` | PRD acceptance checklist passes for every feature whose flag is on |

## 4. Cut order (when behind)

Drop in this order, first item first:
1. F13 Tip notifications
2. F12 AI Assistant
3. F11 App lock
4. F10 Backup and restore
5. F9 Line items
6. F8 Edge detection
7. F7 PDF export
8. F6 Insights
9. F5 Learn from corrections

**Never cut:** the core loop, Korean and English strings, the evaluation numbers, parser tests, honest reporting.

## 5. Gemini prompts for v3 Tasks (STEP 2 prompts)

- **T1**: "Implement feature flags (`aiAssistant`, `tipNotifications`), domain entities (`AssistantTip`), domain interfaces (`AssistantService`, `TipGenerator`, `NotificationService`, `TipRepository`), and fakes (`FakeAssistantService`, `FakeNotificationService` under `lib/data/fakes/`) in `core/providers.dart`."
- **T2**: "Implement `AssistantContextBuilder` in `domain/logic/` with comprehensive table-driven unit tests verifying aggregate JSON generation (no merchants, items, or raw OCR)."
- **T3**: "Implement `GeminiAssistantService` in `data/assistant/` with system prompt in `assistant_prompt.dart`, 15s timeout from `.env`, offline/error fallback to deterministic insights, and unit tests using mocktail."
- **T4**: "Implement `AssistantScreen` and `AssistantController` with Chat tab, 3 suggestion chips, `FrostedTile` bubbles, input bar, first-use consent dialog (disclosing Google AI free tier terms `https://ai.google.dev/terms`), and clear chat action."
- **T5**: "Update `AppDatabase` at `schemaVersion 1` with `AssistantTips` table. Implement `DriftTipRepository` with 50-row retention cleanup and repository tests."
- **T6**: "Implement `TipRules` in `domain/logic/` and evergreen localized tip library with unit tests."
- **T7**: "Implement `LocalNotificationService`, `TipPlanner`, and `TipScheduler` with 12h throttling, preferred time clamping (08:00–21:00), 3-day data freshness limit (evergreen tips beyond 3 days), lock-screen privacy rules, and settings controls."
- **T8**: "Implement `GeminiTipGenerator` in `data/assistant/` with aggregate JSON input and Dart output validation (title <= 40, body <= 140, forbidden word filter)."
- **T9**: "Create `eval/assistant/questions.json` (15 questions), `tool/assistant_eval.dart`, and `tool/eval_assistant.py` to evaluate accuracy, hallucinations, language match, and latency."
- **T10**: "Fill ARB keys for English and Korean, perform Android/iOS platform setup, run accessibility check, and perform final documentation sync."

## 6. Evaluation deliverables (for the PPT)

- Core table: rules only, LLM only, composite, with accuracy for merchant, date and total
- Fallback trigger rate and median processing time
- Assistant evaluation: accuracy of answers against precomputed data, hallucinated numbers count, language match %, median response latency
- Feature status table: on, beta or future work

## 7. PPT outline (I will generate the deck when the app and numbers exist)

1. Title and team (roles as in `docs/COLLABORATION.md`)
2. Problem and target users
3. Solution and demo screenshots
4. Architecture: layers, pipeline diagram, feature flags
5. Key design decisions and trade-offs (rules first, on-device OCR, integer money, merchant normalization, aggregate JSON for assistant)
6. AI engineering: parser, confidence score, Gemini fallback, line items, learning from corrections, conversational assistant, tip generator
7. Evaluation results (the tables)
8. Extended features: what works, with screenshots (search, insights, PDF, backup, lock, assistant chat, tip notifications)
9. Privacy and limitations (including honest limits: lock is not encryption, client-side API key, Google AI free tier privacy terms `https://ai.google.dev/terms`)
10. Process: GitHub workflow, how AI-generated code was verified, gates and what we cut
11. Future work and Q&A
