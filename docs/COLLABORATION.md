# COLLABORATION: two developers, one week, GitHub

This file defines who builds what for the two people writing code. `PLAN.md` holds the priorities, gates and daily goals.
Call the two developers **A** and **B**.

## 1. Why this setup

With two people and seven days, the main risks are (1) waiting on each other, (2) merge conflicts, and (3) AI-generated code that breaks the other person's work.
So the setup has three ideas:

1. **Contracts first.** The domain interfaces (`OcrService`, `ReceiptParser`, `ReceiptRepository`) and entities are merged on Day 1. After that, A and B work in different folders against the same contracts, using fakes until the real parts exist.
2. **Folder ownership.** Each file has one owner. You can read everything, but you change only your own folders without asking.
3. **Short-lived branches, small pull requests, and CI.** Every change goes through a pull request. CI runs `flutter analyze` and `flutter test`, so Gemini's mistakes are caught before they reach `main`.

*Why pull requests even for two people:* the reviewer is forced to read the code, so both of you can explain every file in the demo. That is part of the grade, not overhead.

## 2. Work split

The scope is the core app plus eleven extra features (`docs/PRD.md` section 12). Features are built in priority order behind flags (`docs/PLAN.md` gates), so both developers always have a "next smaller thing" and `main` stays demo-ready.

### Ownership

| Owner | Folders and files |
|---|---|
| **A: app and AI engineer** | `lib/domain/**`, `lib/data/ocr/**`, `lib/data/parsing/**` (including items extractors), `lib/data/capture/**`, `lib/core/masking.dart`, `result.dart`, `env.dart`, `lib/application/scan_controller.dart`, `test/domain/**`, `test/parsing/**`, `test/fixtures/**`, `tool/**`, `eval/**` |
| **B: UI and data engineer** | `lib/presentation/**`, `lib/data/db/**`, `lib/data/settings/**`, `lib/data/export/**`, `lib/data/backup/**`, `lib/data/security/**`, `lib/application/receipts_controller.dart`, `stats_controller.dart`, `settings_controller.dart`, `lib/l10n/**`, `test/data/**`, `assets/**` |
| **Shared (small PRs, tell the other person first)** | `pubspec.yaml`, `lib/core/providers.dart`, `lib/core/feature_flags.dart`, `lib/main.dart`, `lib/app.dart`, `docs/**`, `.github/**`, `GEMINI.md` |

`lib/domain/logic/**` (merchant normalizer, duplicate detector, category suggester, insights engine, top merchants) belongs to A.

### Feature ownership

| Feature | Owner | Notes |
|---|---|---|
| F1 Add manually | B | UI route plus Review form |
| F2 Search and filter | B | Repository query plus home UI |
| F3 Top merchants | B (UI) with A's `top_merchants.dart` | A provides the pure function on Day 4 |
| F4 Duplicate warning | A (logic) and B (dialog) | A first, then B |
| F5 Learn from corrections | A | `MerchantRules` table is created by B on Day 2 |
| F6 Spending insights | A (engine) and B (cards) | |
| F7 PDF export | B | Needs the embedded Korean TTF font |
| F8 Edge detection | A | Evaluation numbers are A's |
| F9 Line items | A (extractors, evaluation) and B (items editor UI) | Largest feature |
| F10 Backup and restore | B | Needs the explicit database path |
| F11 App lock | B | Test on both platforms the same day |

### Day by day

| Day | A | B |
|---|---|---|
| **1** | Project skeleton and packages, `feature_flags.dart`, **domain entities, interfaces, fakes**, `MlKitOcrService`, debug OCR screen, test on Android **and** iOS, check for a cross-platform scanner package. Merge the skeleton PR first (target: within 2 hours) | Before the skeleton exists: GitHub repo, branch protection, CI, issues, fonts (Pretendard for the UI, a static Korean TTF for the PDF), ARB skeletons. After it merges: theme tokens, `AuroraBackground`, `GlassPanel`, `FrostedTile`, `PerforatedSlip` |
| **2** | `Money`, extractors, `RuleBasedParser` with tests; start collecting and labeling receipts | Drift schema with **all four tables**, `PRAGMA foreign_keys`, explicit DB path, repositories (search, month receipts, duplicates, items, merchant rules) with tests |
| **3** | `ScanController`, image storage, permissions | Review form, manual entry route (F1), save. **Gate 1 at the end of the day** |
| **4** | `normalizeMerchant`, `DuplicateDetector`, `CategorySuggester` and learning (F4, F5 logic) with tests; `top_merchants.dart` | Home (slip, list, empty state, scan sheet), detail, delete with undo, processing dialog, search and filter (F2), duplicate dialog |
| **5** | Masking, `LlmParser`, `CompositeParser`, evaluation run, start `RuleItemsExtractor` behind its flag | Stats (donut, bars, top merchants), Settings, both ARB files. **Gate 2 at the end of the day** |
| **6** | `InsightsEngine`, edge detection (F8) and its evaluation, line items (F9) extractors and evaluation | Insight cards, PDF export (F7), items editor UI, then backup and restore (F10), then app lock (F11), dark mode and accessibility pass |
| **7** | **Freeze in the morning.** Final evaluation tables, PPT sections on architecture, AI and evaluation | Final device tests, README, screenshots, demo video, PPT sections on features and process. **Both:** PRD acceptance checklist, clean-clone test, tag `v1.0` |

If one of you finishes early, take the next smallest unfinished feature from the other person's list **after asking them**, in your own branch.

**Collecting and labeling about 30 receipts** (and item labels for about 10 of them) is real work (see `PLAN.md`). If a third teammate does it, they own `eval/labels/` and device testing, and they get listed for exactly that. A third teammate who writes code can take a self-contained feature (PDF export or app lock) on its own branch; that is the cleanest handoff. If nobody else does it, A and B each photograph and label 15 receipts on Days 2 to 4.

### Handoffs (the only places where you depend on each other)

| From -> To | What | When |
|---|---|---|
| A -> B | Domain interfaces, entities, fakes (PR #1) | Day 1 |
| B -> A | Drift schema and repositories | Day 2 end |
| A -> B | `ScanController` and `ScanState` API | Day 3 |
| A -> B | `normalizeMerchant`, `DuplicateDetector`, `CategorySuggester`, `top_merchants.dart` | Day 4 |
| A -> B | `InsightsEngine`, items extractors (Items editor needs the `ReceiptItem` entity from Day 1) | Day 5 to 6 |
| B -> A | ARB keys for scan and error messages: A lists the keys in the PR description, B adds them (or A adds them and keeps the file sorted) | as needed |

If a handoff is late, the other person keeps working against the fake. That is why the fakes exist.

## 3. GitHub setup (B does this on Day 1, 20 minutes)

1. Create a **private** repository, add the other person as a collaborator (Settings -> Collaborators).
2. Initialize with a Flutter `.gitignore`. Make sure it contains: `.env`, `*.g.dart`, `/build/`, `.dart_tool/`, `eval/ocr_private/`.
3. Commit `.env.example` (never `.env`). If a real key is ever committed, **revoke it in AI Studio immediately** and create a new one; deleting the commit is not enough because Git history keeps it.
4. Branch protection for `main` (Settings -> Branches -> Add rule):
   - Require a pull request before merging, with **1 approval**
   - Require the status check **CI / test** to pass
   - Do not allow force pushes
5. Add `.github/workflows/ci.yml` and `.github/pull_request_template.md` (provided).
6. Create a GitHub **Project** board (Backlog, In progress, In review, Done) and one **Issue** per Gemini prompt in `PLAN.md`. Assign each issue to A or B. Issues are free and give you a progress view for the PPT.

## 4. Daily workflow (the loop)

```bash
# 1. Start of day: sync main
git switch main
git pull

# 2. One branch per task (one issue = one branch = one PR)
git switch -c feat/a-rule-parser

# 3. Work with Gemini on THIS task only, then verify locally
dart run build_runner build --delete-conflicting-outputs   # if Drift or generated code changed
flutter analyze
flutter test

# 4. Commit small and often (Conventional Commits)
git add -A
git commit -m "feat(parser): detect total from Korean keywords"

# 5. Stay up to date, at least once a day and always before opening a PR
git fetch origin
git rebase origin/main        # or: git merge origin/main (if rebase confuses you)

# 6. Push and open a pull request
git push -u origin feat/a-rule-parser
```

Then on GitHub: open the PR, fill the template, link the issue (`Closes #12`), and ask the other person to review.

### Branch names

`feat/a-<thing>`, `feat/b-<thing>`, `fix/<thing>`, `docs/<thing>`. Example: `feat/b-review-screen`.

### Rules

1. **Never commit directly to `main`.** `main` must always build and run.
2. **Small PRs**, ideally under about 300 changed lines. Big Gemini outputs get split into several commits or PRs.
3. **Review within a few hours.** Do not let PRs sit overnight on this schedule. The reviewer runs the branch, not just reads it, when the PR touches UI.
4. **Squash and merge**, then delete the branch. It keeps `main` history readable (one commit per task).
5. **Merge early.** A half-finished feature can be merged if it is hidden or harmless (for example, a screen that is not linked yet). Long-lived branches are what cause painful conflicts.
6. Fix CI failures before asking for review.
7. Do **not** merge your own PR without the other person's approval, except the Day 1 skeleton if the other person is unavailable (tell them).

### Daily rhythm

- **10-minute sync at the start of the day:** what I finish today, what I need from you, anything blocked.
- **Before you stop for the day:** everything you started is either merged or a **draft PR**, so the other person can see it.
- **Day 3 end and Day 5 end:** integration check, both on `main`, run the full flow on a real phone together.

## 5. Avoiding merge conflicts (where they will happen)

| Hotspot | Prevention |
|---|---|
| `pubspec.yaml` | All packages are added in the Day 1 skeleton PR. A later new package: announce it, add it in a tiny PR, merge it the same hour |
| `core/providers.dart` | Each person adds their providers in their own clearly commented block. Merge small and often |
| ARB files (`app_en.arb`, `app_ko.arb`) | Keep keys **sorted alphabetically**, so two people adding different keys do not touch the same lines. B owns the files; A requests keys |
| Generated files (`*.g.dart`) | Not committed, so they cannot conflict. CI and each developer run `build_runner`. If any generated file does conflict, do not hand-edit it: take either version and re-run the generator |
| `docs/PLAN.md` "Current day" line | Only B edits it, each morning |
| `lib/core/feature_flags.dart` | One flag per line. Flip a flag to `true` only in the PR that finishes and verifies that feature, so two people rarely touch the same line |

Resolving a conflict, step by step:
1. `git status` shows the conflicted files.
2. Open each file, look for `<<<<<<<`, `=======`, `>>>>>>>`, keep the correct combination of both sides, and remove the markers.
3. `git add <file>` then `git rebase --continue` (or `git commit` if you merged).
4. Run `flutter analyze` and `flutter test` again before pushing.
5. If you are lost: `git rebase --abort` (or `git merge --abort`) returns you to the state before and you can ask the other person to sit with you.

## 6. Working with Gemini as a team

- `GEMINI.md` and the `docs/` files are the shared brain. If Gemini behaves badly, fix the document (small PR), not just the prompt.
- **One prompt = one task = one branch.** Do not ask Gemini to build several features in one session on one branch.
- **Read the diff before committing** (`git diff`). If you cannot explain a change, ask Gemini to explain it, or reject it.
- If Gemini edits files you do not own, **undo those changes** (`git restore <file>`) and tell the owner what you need instead.
- Never paste the real API key into a prompt or a file. If Gemini asks for it, use `.env`.
- Record Gemini mistakes you fixed in a short `docs/AI_LOG.md` (prompt, problem, fix). It becomes honest "challenges and lessons learned" content for the PPT.

## 7. Pull request review checklist

The reviewer checks:
- [ ] Does it build and run? (CI is green; UI changes run on a device or emulator)
- [ ] Does it match `ARCHITECTURE.md` (no business logic in widgets, no ML Kit types in the parser)?
- [ ] No hardcoded strings or colors, both languages updated
- [ ] No secrets, no `print` debugging, no leftover TODO without an issue
- [ ] Tests added or updated for logic changes
- [ ] The author can explain the main design choices in one minute

## 8. Release and submission (Day 7)

1. Final PR: README with setup steps (`flutter pub get`, `cp .env.example .env`, `dart run build_runner build`, `flutter run`), screenshots, evaluation table, limitations.
2. Merge, then `git tag v1.0 && git push origin v1.0`.
3. On GitHub create a **Release** from the tag and attach the Android APK if the course allows it (`flutter build apk --release`).
4. Do a clean-clone test: clone the repo into a new folder on one laptop and follow the README exactly. If it fails there, it will fail for the grader.
