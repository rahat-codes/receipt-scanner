# PLAN: 7 days, full scope with gates

Current day: **Day 1** (update this line each morning; Gemini reads it)

The scope is the core app (P0) plus all eleven extra features (see `docs/PRD.md` section 12). That is more work than two people can normally finish in a week, so the plan is built to **degrade gracefully**: the core is protected, features are built in priority order behind flags, and three gates decide what continues.

## 1. Priorities

| Priority | Features | Rule |
|---|---|---|
| **P0 core** | Scan -> review -> save -> list, stats (donut, bars), settings, Korean and English UI, parser tests, evaluation | Never cut |
| **P1** | F1 Add manually, F2 Search and filter, F3 Top merchants, F4 Duplicate warning | Small, build first |
| **P2** | F5 Learn from corrections, F6 Spending insights, F7 PDF export and share | Build after P1 |
| **P3** | F8 Edge detection, F9 Line items, F10 Backup and restore, F11 App lock | Risky, gated, may stay off |

## 2. Gates

| Gate | When | Condition to continue | If it fails |
|---|---|---|---|
| **Gate 1** | End of Day 3 | Scan -> review -> save works on a real phone (both platforms checked at least once) | Stop all feature work. Fix the core before anything else |
| **Gate 2** | End of Day 5 | P0 and P1 finished; first evaluation numbers exist | Do not start new P2 or P3 features. Finish only what is already in progress |
| **Gate 3 (freeze)** | Morning of Day 7 | Nothing new after this | Unfinished features stay behind their flag (off) and go on the "future work" slide |

A feature flag is set to `true` only when it meets the Definition of done in `GEMINI.md` **and** has been tested on a real device. Report honestly in the PPT which features are on and which are future work. Presenting a working core plus a few solid features, with a clear and honest list of the rest, scores better than a long list of broken ones.

## 3. Daily plan

| Day | Goals | Done when |
|---|---|---|
| **1** | Skeleton, packages, `feature_flags.dart`, domain contracts and fakes, theme tokens, camera and gallery capture, ML Kit OCR on a real photo on **Android and iOS**, GitHub, CI, branch protection. Check whether a cross-platform document-scanner package exists (for F8) | OCR text of a real receipt shows on both platforms; PR #1 merged |
| **2** | `Money`, extractors, `RuleBasedParser` with tests. Drift schema with **all four tables**, repository (including search, month receipts, duplicates, items), tests. Start collecting receipts | Parser tests pass on at least 10 snippets; repository tests pass |
| **3** | `ScanController`, image storage, permissions. Review form with amber hints and validation, manual entry route (F1), save to DB. **Gate 1** | Scan -> edit -> save -> row in DB on a real phone |
| **4** | Home (slip, list, empty state, scan sheet), detail, delete with undo, processing dialog. Search and filter (F2). `normalizeMerchant`, duplicate detector (F4), category suggester and learning (F5) with tests | Core loop complete; search works; duplicate dialog works |
| **5** | Stats (donut, bars), top merchants (F3), Settings, ARB strings in both languages. Masking, `LlmParser`, `CompositeParser`. Start `RuleItemsExtractor` behind its flag. **Gate 2** | P0 and P1 complete; evaluation of rules vs composite runs |
| **6** | Insights engine (F6), PDF export (F7), then P3 in this order if the gates allow: edge detection (F8) with before/after evaluation, line items (F9) with evaluation, backup and restore (F10), app lock (F11). Dark mode and accessibility pass | Each finished feature verified on a device before its flag goes on |
| **7** | **Freeze in the morning.** Fix bugs, final device tests on both platforms, README, demo video, PPT, clean-clone test, tag `v1.0` | PRD acceptance checklist passes for every feature whose flag is on |

If Day 6 is on fire, work from the top of this order and stop where the time runs out. Do not start F10 (restore can destroy data) unless there are at least six hours left to test it.

## 4. Cut order (when behind)

Drop in this order, first item first:
1. F11 App lock
2. F10 Backup and restore
3. F9 Line items
4. F8 Edge detection
5. F7 PDF export
6. F6 Insights
7. F5 Learn from corrections

**Never cut:** the core loop, Korean and English strings, the evaluation numbers, parser tests, honest reporting.

## 5. Gemini prompts (one task per prompt)

Start every session with:
> Read GEMINI.md and docs/PRD.md, docs/ARCHITECTURE.md, docs/SCHEMA.md, docs/DESIGN.md, docs/PLAN.md. We are on Day N. Do only the task below. First tell me in 3-5 lines which files you will create or change.

**Day 1**
1. "Create the Flutter project structure from ARCHITECTURE.md section 4 and section 12.1 with empty placeholder files only where needed. Add the packages from GEMINI.md with `flutter pub add`. Set up `analysis_options.yaml`, `.gitignore` (including `.env`), `.env.example`, `flutter_dotenv` loading in `main.dart`, and `lib/core/feature_flags.dart` exactly as in ARCHITECTURE.md section 12.2 with every flag false."
2. "Create `lib/presentation/theme/` with `AppColors`, `GlassTheme` (ThemeExtension), light and dark `ThemeData`, `AuroraBackground`, `GlassPanel`, `FrostedTile`, `PerforatedSlip` exactly as in DESIGN.md section 2."
3. "Create the domain entities and interfaces from ARCHITECTURE.md sections 5 and 12.1, `Money`, `Result`/`AppFailure`, and fakes (`FakeOcrService`, `FakeReceiptParser`, `InMemoryReceiptRepository`) wired in `core/providers.dart`. Add `Money` tests."
4. "Implement `OcrService` and `MlKitOcrService` using the Korean script recognizer. Build a temporary debug screen: pick an image, run OCR, show the text. Explain the platform setup I must do for Android and iOS."

**Day 2**
5. "Implement `TotalExtractor` per ARCHITECTURE.md 6.1 with table-driven tests (SUBTOTAL vs TOTAL, `\` read instead of `₩`, a keyword on one line with the amount on the next, Korean `합계`)."
6. "Implement `DateExtractor`, `MerchantExtractor`, and `RuleBasedParser` with the confidence score table, with tests."
7. "Implement `app_database.dart` exactly as in SCHEMA.md including `ReceiptItems`, `MerchantRules`, the indexes, `PRAGMA foreign_keys = ON`, and the explicit file path. Run build_runner. Implement `DriftReceiptRepository` and `DriftMerchantRuleRepository` per SCHEMA.md section 7 and 8, with repository tests on an in-memory database."

**Day 3**
8. "Implement `ScanController` (idle, reading, parsing, ready, failed), image copy into app storage, and permission handling."
9. "Implement the Review screen per DESIGN.md 3.3 (amber hints, validation) and the 'Enter manually' route (F1) per DESIGN.md 8.1, behind `FeatureFlags.manualEntry`. Save through the repository."

**Day 4**
10. "Implement the Receipts home screen per DESIGN.md 3.1, the detail screen, delete with undo, the processing dialog, and the scan sheet."
11. "Implement search and filter (F2) per DESIGN.md 8.2 and SCHEMA.md 8.3, behind its flag, with repository tests."
12. "Implement `normalizeMerchant` per ARCHITECTURE.md 12.3 with table-driven tests, then `DuplicateDetector` and the duplicate dialog (F4), then `CategorySuggester` and learning (F5), each behind its flag, with tests."

**Day 5**
13. "Implement the Stats screen per DESIGN.md 3.5 and top merchants (F3) per ARCHITECTURE.md 12.4, using `fl_chart`."
14. "Implement Settings per DESIGN.md 3.6, persist with `shared_preferences`, and fill both ARB files from the copy tables in DESIGN.md sections 4 and 8.10. Replace every hardcoded string."
15. "Implement `core/masking.dart` with tests, then `LlmParser` with the Gemini REST API via `http`, reading key, model and timeout from `.env`, validating the JSON in Dart. Never log the key."
16. "Implement `CompositeParser` and wire it in `providers.dart`. Test with mocktail: LLM only when confidence is low and the toggle is on; failure keeps the rule result."
17. "Write a test that runs `RuleBasedParser` over `test/fixtures/ocr/*.json` and writes `predictions/*.json`."

**Day 6** (only what gates allow, in this order)
18. "Implement `InsightsEngine` per ARCHITECTURE.md 12.5 with tests, then the insight cards (F6)."
19. "Implement `PdfReportExporter` per ARCHITECTURE.md 12.6 with an embedded Korean-capable static TTF font, the PDF sheet per DESIGN.md 8.7, and sharing (F7)."
20. "Add the document-scanner package after checking it supports Android and iOS. Implement `ReceiptCapture`, `SystemCameraCapture`, `DocumentScannerCapture` and the provider per ARCHITECTURE.md 12.7 (F8). Fall back to the system camera on any failure."
21. "Implement `RuleItemsExtractor` per ARCHITECTURE.md 12.10 with tests, then `LlmItemsExtractor`, `CompositeItemsExtractor`, the Items editor per DESIGN.md 8.4, and storage via `replaceItems` (F9)."
22. "Implement `ZipBackupService` per ARCHITECTURE.md 12.8 with VACUUM INTO, manifest, validation, safety copy and rollback, plus a round-trip test (F10)."
23. "Implement `AppLockService` and the lock gate and privacy shield per ARCHITECTURE.md 12.9 and DESIGN.md 8.9 (F11). Tell me the exact Android and iOS setup steps."

**Day 7**
24. "Review the whole project against the PRD acceptance checklist (including section 12.5) and the DESIGN acceptance checklists. List every gap. Do not fix anything yet."
25. "Fix the gaps listed, one at a time, running analyze and tests after each."

**After every prompt** run `flutter analyze` and `flutter test`, read the diff, and ask Gemini to explain anything you cannot explain yourself. If the output ignores GEMINI.md, say so and ask it to redo the step.

## 6. Evaluation deliverables (for the PPT)

- Core table: rules only, LLM only, composite, with accuracy for merchant, date and total
- Fallback trigger rate and median processing time
- Edge detection on/off comparison (if F8 is on, or the reason it was dropped)
- Line items: precision and recall on at least 10 receipts (if F9 is on)
- Top 3 failure types with example receipts (redact personal details) and what we changed
- Privacy summary: what stays on the device, what is sent, what is masked, what the app lock does and does not protect
- Feature status table: on, beta or future work

## 7. PPT outline (I will generate the deck when the app and numbers exist)

1. Title and team (roles as in `docs/COLLABORATION.md`)
2. Problem and target users
3. Solution and demo screenshots
4. Architecture: layers, pipeline diagram, feature flags
5. Key design decisions and trade-offs (rules first, on-device OCR, integer money, merchant normalization)
6. AI engineering: parser, confidence score, Gemini fallback, line items, learning from corrections
7. Evaluation results (the tables)
8. Extended features: what works, with screenshots (search, insights, PDF, backup, lock)
9. Privacy and limitations (including honest limits: lock is not encryption, client-side API key)
10. Process: GitHub workflow, how AI-generated code was verified, gates and what we cut
11. Future work and Q&A

Collect by Day 7: 6 to 8 screenshots (home, review with amber hints, items editor, stats in light and dark, settings), the evaluation tables, the architecture diagram, the feature status table, and the final team roles.

## 8. Risks to watch daily

- iOS build or OCR not working -> catch on Day 1
- No cross-platform scanner package -> drop F8 on Day 1, do not wait
- Parser accuracy stuck below target -> improve with the fixtures loop, not by guessing
- Gemini produces code that violates the architecture -> stop, restate `GEMINI.md`, redo the task
- Scope creep beyond the 11 features -> check the PRD non-goals
- Restore (F10) corrupting data -> only enable after the round-trip test passes
