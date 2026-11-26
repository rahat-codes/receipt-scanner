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
- Budgets, reminders, bank integrations
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
| Privacy | Images never leave the device. Only masked OCR text may be sent, and only if the fallback is on. |
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
- With the fallback off, no data leaves the device.
- With the fallback on, only OCR text with long digit sequences masked is sent to the Gemini API when the rule-based parser is unsure.
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

### 12.2 User stories

| ID | As a user I want to... | So that... |
|---|---|---|
| US-11 | add a receipt without a photo | I can record purchases I have no paper for |
| US-12 | search and filter my receipts | I can find a purchase quickly |
| US-13 | see where I spend the most | I know my regular merchants |
| US-14 | be warned about duplicates | I do not count a purchase twice |
| US-15 | have the app remember my category choices | I stop fixing the same merchant again |
| US-16 | read a short summary of my month | I understand changes without reading charts |
| US-17 | export a monthly PDF and share it | I can keep or send a record |
| US-18 | scan with auto-crop | the receipt is read more accurately |
| US-19 | see the items on a receipt | I know what I bought |
| US-20 | back up and restore my data | I do not lose records when I change phones |
| US-21 | lock the app | others who use my phone cannot see my spending |

### 12.3 Functional requirements

- FR-18 (F1): The scan sheet has an "Enter manually" action that opens the Review form empty, with `parser_source = manual` and today's date.
- FR-19 (F2): The home screen has a search field and filter chips (category, date range). Search matches merchant and item names (case-insensitive). Results update as the user types (debounced). A "Clear filters" action is visible when any filter is active.
- FR-20 (F3): Stats shows the top 5 merchants for the selected month by total, with visit count. Merchants are grouped by normalized name (branch suffixes removed, see ARCHITECTURE 12.3).
- FR-21 (F4): Before saving a new receipt, if another receipt has the same currency, the same total and the same calendar day, and a similar merchant, show a dialog with "View existing", "Save anyway" and "Discard". Editing an existing receipt never triggers the warning against itself.
- FR-22 (F5): On save, if the chosen category differs from the suggested one, store or update the rule for the normalized merchant. New drafts use the rule first, then keyword defaults. The review form shows a small "Suggested from your past choices" note when a rule was used.
- FR-23 (F6): Stats shows up to 3 insight cards, produced by deterministic rules (ARCHITECTURE 12.5), localized, and hidden when there is not enough data.
- FR-24 (F7): Stats has a share action that builds a PDF for the selected month (summary, category table, receipts table, optional photos), embeds a font that renders Korean, and opens the system share sheet. A warning explains that the file contains personal data.
- FR-25 (F8): When enabled, "Scan receipt" opens a document scanner that returns a cropped, straightened image, which feeds the normal OCR pipeline. If the scanner is unavailable or cancelled, offer the normal camera.
- FR-26 (F9): The pipeline also extracts line items (rules first, Gemini fallback under the same toggle and masking rules). The Review form has an optional, editable "Items" section. Items are stored with the receipt and shown in the detail screen and the PDF.
- FR-27 (F10): Settings can create a backup file (database snapshot, images, manifest) and share it, and can restore from a chosen backup file after a clear confirmation. Before restoring, the app saves an automatic safety copy of the current data.
- FR-28 (F11): Settings has an "App lock" switch. When on, the app requires device authentication (biometrics or device passcode) at launch and after being in the background for more than 30 seconds, and hides its content in the app switcher. The switch is disabled with an explanation if the device has no screen lock.

### 12.4 Additional non-functional requirements and metrics

| Area | Requirement or target |
|---|---|
| Flags | Every P1, P2 and P3 feature is behind a feature flag and off until verified on a device |
| Duplicate warning | In a manual test of 10 pairs (5 true duplicates, 5 near misses), at least 4 true duplicates warn and at most 1 near miss warns |
| Learn from corrections | After one correction, the next draft for that merchant uses the learned category (unit-tested) |
| Edge detection | Report field accuracy with and without the scanner on the same set of at least 15 receipts photographed both ways. Keep the feature on only if accuracy does not get worse |
| Line items | Report item-level precision and recall on at least 10 labeled receipts. Keep the feature on only if recall is at least 50%, otherwise label it "beta" or leave it off |
| PDF | Korean and English text render correctly (visual check on both platforms); file opens in a standard viewer |
| Backup | Round trip test: back up, delete all receipts, restore, and the receipt count, totals and images match |
| App lock | Locks on launch and after 30 s in background; works with biometrics and with the device passcode |

### 12.5 Additional acceptance criteria

8. Enter a receipt manually and save it.
9. Type part of a merchant name: the list filters; add a category chip: it narrows further.
10. Stats show top merchants and up to three insights.
11. Save the same receipt twice: the second time shows the duplicate dialog.
12. Change a category for a merchant, scan another receipt from that merchant, and see the learned category suggested.
13. Export a PDF with Korean text and open it in the system share sheet.
14. Scan with auto-crop (if its flag is on) and compare the result with the normal scan.
15. Open a receipt with items, edit an item, save.
16. Back up, wipe data, restore, and verify counts.
17. Turn on the app lock, background the app for over 30 seconds, and see it ask for authentication.

### 12.6 Additional risks

| Risk | Mitigation |
|---|---|
| Scope is much larger than the time available | Priorities, three gates, feature flags; unfinished features are reported as future work |
| Line items on Korean receipts vary widely | Rule-based parsing with a sum check, Gemini fallback, and a recall threshold for keeping the feature on |
| No cross-platform scanner package works | Drop F8 and say so; it must not block anything else |
| Restore corrupts data | Safety copy before restore, manifest and schema version checks, round trip test |
| PDF shows empty boxes for Korean | Embed a TTF font with Korean glyphs; visual check on both platforms |
| App lock setup differs per platform | Test on Android and iOS the same day it is built |
