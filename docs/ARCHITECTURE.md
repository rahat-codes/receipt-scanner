# ARCHITECTURE

## 1. Principle

**Cheap and deterministic first, expensive and probabilistic only when needed.**
OCR and rule-based parsing run on the device in milliseconds and can be unit-tested. Gemini is called only when the rules are unsure.

*Why:* lower latency, no cost, works offline, and behavior is debuggable. It also gives us a measurable claim for the report and PPT: how much does the fallback improve accuracy, and how often is it needed?

## 2. Pipeline

```
Photo (system camera / gallery)
   -> OcrService            (ML Kit, Korean script recognizer, on-device)
   -> OcrResult             (plain Dart data: full text + lines)
   -> RuleBasedParser       (merchant, date, total, currency, confidence)
   -> confidence >= threshold ?
        yes -> ParsedReceipt
        no  -> (fallback ON) LlmParser via Gemini REST, text only, masked
               merge with rule result; on failure keep rule result
   -> Review form           (user corrects, picks category)
   -> ReceiptRepository     (Drift / SQLite)
   -> Home list + Stats
```

## 3. Layers and dependency direction

```
presentation  ->  application  ->  domain  <-  data
(widgets)        (controllers)     (entities,    (ML Kit, parsers,
                                    interfaces)   Drift, Gemini)
```

- **domain** knows nothing about Flutter, ML Kit, Drift or HTTP.
- **data** implements domain interfaces.
- **application** orchestrates use cases using interfaces only.
- **presentation** renders state and forwards user actions.

*Why:* the OCR engine, the parser and the database can each be replaced or mocked without touching the UI. This is what makes parser accuracy testable on a laptop.

## 4. Folder structure

```
lib/
├── main.dart
├── app.dart                         # MaterialApp, theme, locale
├── core/
│   ├── providers.dart               # ALL dependency wiring lives here
│   ├── result.dart                  # Result<T> / AppFailure
│   ├── env.dart                     # typed access to .env values
│   └── masking.dart                 # mask digits before LLM calls
├── domain/
│   ├── entities/
│   │   ├── receipt.dart             # Receipt
│   │   ├── parsed_receipt.dart      # ParsedReceipt, FieldFlag
│   │   ├── ocr_result.dart          # OcrResult, OcrLine
│   │   ├── category.dart            # Category (key, color)
│   │   └── money.dart               # Money helpers (minor units)
│   └── interfaces/
│       ├── ocr_service.dart         # abstract OcrService
│       ├── receipt_parser.dart      # abstract ReceiptParser
│       └── receipt_repository.dart  # abstract ReceiptRepository
├── data/
│   ├── ocr/
│   │   └── mlkit_ocr_service.dart
│   ├── parsing/
│   │   ├── rule_based_parser.dart
│   │   ├── total_extractor.dart     # keywords + numeric rules
│   │   ├── date_extractor.dart
│   │   ├── merchant_extractor.dart
│   │   ├── llm_parser.dart          # Gemini REST client + JSON validation
│   │   └── composite_parser.dart    # rules first, LLM if low confidence
│   ├── db/
│   │   ├── app_database.dart        # Drift tables + queries
│   │   └── drift_receipt_repository.dart
│   └── settings/
│       └── settings_store.dart      # shared_preferences wrapper
├── application/
│   ├── scan_controller.dart         # image -> OCR -> parse -> draft
│   ├── receipts_controller.dart     # list, save, delete
│   ├── stats_controller.dart        # monthly aggregates
│   └── settings_controller.dart
├── presentation/
│   ├── theme/                       # tokens, light/dark ThemeData, glass widgets
│   ├── screens/
│   │   ├── receipts_screen.dart     # home
│   │   ├── review_screen.dart       # add / edit form
│   │   ├── detail_screen.dart
│   │   ├── stats_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/
├── l10n/
│   ├── app_en.arb
│   └── app_ko.arb
test/
├── domain/                          # Money, masking
├── parsing/                         # extractors, rule parser, composite parser
├── data/                            # repository with in-memory Drift
└── fixtures/ocr/                    # saved OCR outputs + labels (see section 8)
```

## 5. Core interfaces (contract Gemini must follow)

```dart
// domain/entities/ocr_result.dart
class OcrLine {
  final String text;
  final double top;     // normalized 0..1 from top of image; used for merchant detection
  const OcrLine(this.text, this.top);
}

class OcrResult {
  final String fullText;
  final List<OcrLine> lines;
  const OcrResult({required this.fullText, required this.lines});
  bool get isEmpty => fullText.trim().isEmpty;
}

// domain/interfaces/ocr_service.dart
abstract class OcrService {
  Future<OcrResult> read(String imagePath);
}

// domain/entities/parsed_receipt.dart
enum FieldFlag { merchant, date, total, currency }
enum ParseSource { rules, llm, manual }

class ParsedReceipt {
  final String? merchant;
  final DateTime? date;
  final int? totalMinor;                 // integer minor units
  final String currency;                 // 'KRW' | 'USD'
  final double confidence;               // 0..1
  final Set<FieldFlag> needsReview;      // drives amber highlights
  final ParseSource source;
  const ParsedReceipt({
    this.merchant, this.date, this.totalMinor,
    this.currency = 'KRW',
    required this.confidence,
    this.needsReview = const {},
    this.source = ParseSource.rules,
  });
}

// domain/interfaces/receipt_parser.dart
abstract class ReceiptParser {
  Future<ParsedReceipt> parse(OcrResult ocr);
}
```

`RuleBasedParser`, `LlmParser` and `CompositeParser` all implement `ReceiptParser`.
`CompositeParser(rules, llm, threshold, llmEnabled)` calls `rules.parse`, and only calls `llm.parse` when `confidence < threshold` and the fallback is enabled.

## 6. Parsing design

### 6.1 Rule-based parser

**Total** (most important field):
1. Look for lines containing total keywords:
   - Korean: `합계`, `총액`, `총 금액`, `결제금액`, `받을금액`, `청구금액`, `승인금액`, `합 계`
   - English: `TOTAL`, `GRAND TOTAL`, `AMOUNT DUE`, `BALANCE DUE`
2. Ignore lines with exclusion keywords: `부가세`, `과세`, `면세`, `공급가액`, `소계`, `거스름`, `받은금액`, `SUBTOTAL`, `TAX`, `CHANGE`, `CASH`.
3. Extract the number on that line (or the next line if the keyword stands alone). Remove thousands separators (`,`), handle `원`, `₩`, `\` (common OCR for ₩), `$`.
4. If no keyword line works, fall back to the **largest plausible amount** in the bottom half of the receipt.
5. Plausibility: more than 0 and below 100,000,000 KRW (adjust for USD).

**Date**: try these patterns in order, validate the calendar date, reject future dates and years before 2000.
`yyyy-mm-dd`, `yyyy/mm/dd`, `yyyy.mm.dd`, `yy-mm-dd`, `yyyy년 m월 d일`, `mm/dd/yyyy` (English receipts). Optional time is ignored.

**Merchant**: prefer a line labeled `상호`, `가맹점명`, `매장명`, `Store`, `Merchant`. Otherwise use the first line near the top (small `top` value) that is not a phone number, address, date or a pure number. Trim and collapse whitespace.

**Currency**: `₩`, `원`, `KRW` -> KRW. `$`, `USD` -> USD. Default KRW.

**Confidence** (simple, explainable, tunable):

| Signal | Points |
|---|---|
| Total found via a keyword line | 0.45 (0.20 if from the largest-amount fallback) |
| Valid date found | 0.25 |
| Merchant found | 0.20 |
| Total consistent with another number on the receipt (e.g. appears twice) | 0.10 |

Any field missing or weak is added to `needsReview`.

*Why a hand-built score instead of a model:* it can be explained on one slide, tuned from the evaluation results, and each point has a testable meaning.

### 6.2 Gemini fallback (`LlmParser`)

- Endpoint: Gemini REST `generateContent`, called with the `http` package. Key and model name come from `.env`.
- Request: **masked OCR text only**. System instruction: *"Extract merchant, purchase date (ISO 8601), total amount as an integer in the currency's minor unit, and currency code from this receipt text. Reply with JSON only."* Ask for JSON output with a fixed schema.
- Validate the response in Dart: parse JSON, check types, plausibility (same rules as above). Invalid output is treated as failure.
- Timeout from `.env` (default 8 s). Any failure -> return the rule result unchanged.
- **Merge rule:** use an LLM field only where the rules had no value or the field was flagged; never overwrite a keyword-confirmed total.
- Mask with `core/masking.dart`: replace digit runs of 8 or more (cards, phones, business numbers) with `*`. Keep short amounts and dates intact.

*Trade-off to present:* an LLM handles odd layouts but is slower, costs quota, needs a network and is non-deterministic. That is why it sits behind the rules.

### 6.3 Bilingual OCR choice

Use the Korean-script recognizer for all receipts, because it also recognizes Latin text and digits, so one pass covers both languages and keeps latency low. **Verify this on our test set**; if English receipts regress, add a second pass with the Latin recognizer for receipts with no Hangul.

## 7. State management (Riverpod)

- `ocrServiceProvider`, `ruleParserProvider`, `llmParserProvider`, `parserProvider` (composite), `repositoryProvider`, `databaseProvider`, `settingsProvider` - all in `core/providers.dart`.
- Screens watch `AsyncNotifier`/`StreamProvider` state from controllers:
  - `receiptsProvider`: stream of receipts from Drift, so the list updates automatically after saves and deletes.
  - `scanControllerProvider`: states `idle -> reading -> parsing -> (aiAssist) -> ready(draft) | failed(AppFailure)`.
  - `statsProvider(month)`: category sums and last-6-months totals.
- Settings (locale, theme mode, fallback toggle) persist in `shared_preferences` and rebuild `MaterialApp`.

## 8. Testing and evaluation

### 8.1 Unit tests (run on a laptop, no phone needed)

- `Money`: parse and format KRW and USD, no floating point.
- `masking`: card, phone and business numbers masked; amounts and dates preserved.
- Extractors: table-driven tests with Korean and English OCR snippets, including bad cases (OCR `\` for `₩`, split lines, `SUBTOTAL` vs `TOTAL`).
- `CompositeParser` with `mocktail`: LLM called only when below threshold, only when enabled; LLM failure keeps the rule result.
- Repository tests with an in-memory Drift database: insert, update, delete, monthly aggregates.

### 8.2 Evaluation harness

*Why separate OCR from parsing:* ML Kit only runs on a device. If we save OCR output once, we can re-run and improve the parser hundreds of times in seconds with `flutter test`.

1. A teammate photographs about 30 receipts and writes a label file per receipt, `labels/001.json`:
   ```json
   {"merchant": "GS25 대연점", "date": "2026-11-18", "total_minor": 4300, "currency": "KRW"}
   ```
2. A hidden **debug action** (debug builds only) runs OCR on a photo and saves `ocr/001.json` with the `OcrResult` (full text and lines). Copy these into `test/fixtures/ocr/`.
3. A Dart test runs `RuleBasedParser` over every fixture and writes `predictions/001.json`.
4. The Python script below scores predictions against labels. Run it after every parser change and keep the numbers for the PPT.

```python
# tool/eval_report.py  -  usage: python tool/eval_report.py predictions labels
import json, sys
from pathlib import Path

def norm(s):
    return "".join((s or "").lower().split())

def score(pred_dir, label_dir):
    fields = ["merchant", "date", "total_minor"]
    hits = {f: 0 for f in fields}
    n = 0
    for lp in sorted(Path(label_dir).glob("*.json")):
        pp = Path(pred_dir) / lp.name
        if not pp.exists():
            continue
        truth = json.loads(lp.read_text(encoding="utf-8"))
        pred = json.loads(pp.read_text(encoding="utf-8"))
        n += 1
        # merchant: loose match, since OCR often drops branch names
        hits["merchant"] += norm(truth["merchant"]) in norm(pred.get("merchant")) \
            or norm(pred.get("merchant")) in norm(truth["merchant"]) and bool(pred.get("merchant"))
        hits["date"] += truth["date"] == pred.get("date")
        hits["total_minor"] += truth["total_minor"] == pred.get("total_minor")
    print(f"receipts evaluated: {n}")
    for f in fields:
        print(f"{f:12s} {hits[f]}/{n} = {hits[f] / n:.0%}" if n else f)

if __name__ == "__main__":
    score(sys.argv[1], sys.argv[2])
```

5. Report three setups: **rules only**, **LLM only** (saved Gemini outputs), **composite**. Also report the share of receipts where the fallback triggered and the median latency.

### 8.3 Manual device checklist (teammate with the phone)

Camera permission denied; gallery permission denied; blank photo; very blurry photo; airplane mode; fallback toggle off; rotate device; large system font; dark mode; Korean and English UI.

## 9. Error handling

| Failure | Behavior |
|---|---|
| Permission denied | Explain why, offer a button to open system settings |
| OCR returns nothing | "Couldn't read this receipt." Offer retake, or enter manually (empty form) |
| Parser finds nothing | Open the form with empty fields, all flagged |
| Gemini timeout, HTTP error, invalid JSON | Silent fallback to the rule result, fields flagged, small "AI unavailable" note |
| Database error | Snackbar with retry; the draft stays on screen |

## 10. Security and privacy

- Images are copied into app-private storage (`getApplicationDocumentsDirectory()/receipts/`). Delete the file when the receipt is deleted.
- `.env` is git-ignored. `.env.example` is committed.
- Restrict the Gemini key in AI Studio. Known limitation: a key shipped inside a client app can be extracted; a production system would use a backend proxy.
- No analytics, no crash reporting, no third-party SDK except ML Kit.

## 11. Platform notes (follow the plugin READMEs)

- **iOS:** `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in `Info.plist`; set the minimum iOS version required by ML Kit in the Podfile; test on a real device if the simulator architecture is unsupported.
- **Android:** check `minSdkVersion` required by ML Kit; follow the README for the Korean recognizer model dependency.
- Test the full scan flow on both platforms on **Day 1**, not Day 7.

---

## 12. Extended features (v2)

Everything here follows the same rules as the core: interfaces in `domain/`, implementations in `data/`, logic in pure Dart where possible, tests for the logic, strings in both ARB files, and a feature flag.

### 12.1 New interfaces and folders

```
lib/
├── core/
│   └── feature_flags.dart                 # const bool per P1/P2/P3 feature, all false until verified
├── domain/
│   ├── entities/ receipt_item.dart, insight.dart, merchant_total.dart
│   ├── interfaces/
│   │   ├── receipt_capture.dart           # abstract ReceiptCapture {Future<String?> capture();}
│   │   ├── merchant_rule_repository.dart  # see SCHEMA section 7
│   │   ├── items_extractor.dart           # abstract ItemsExtractor
│   │   ├── pdf_exporter.dart
│   │   ├── backup_service.dart
│   │   └── app_lock_service.dart
│   └── logic/                             # pure Dart, unit-tested
│       ├── merchant_normalizer.dart       # normalizeMerchant()
│       ├── category_suggester.dart
│       ├── duplicate_detector.dart
│       ├── insights_engine.dart
│       └── top_merchants.dart
├── data/
│   ├── capture/ system_camera_capture.dart, document_scanner_capture.dart
│   ├── parsing/ rule_items_extractor.dart, llm_items_extractor.dart, composite_items_extractor.dart
│   ├── export/ pdf_report_exporter.dart
│   ├── backup/ zip_backup_service.dart
│   └── security/ local_auth_service.dart
└── presentation/ (new widgets: search_bar, filter_chips, items_editor, insight_card, top_merchants_list, lock_screen)
```

Wire all of them in `core/providers.dart`. Each UI entry point checks its flag.

### 12.2 Feature flags

```dart
// lib/core/feature_flags.dart
class FeatureFlags {
  static const manualEntry = false;       // F1
  static const searchFilter = false;      // F2
  static const topMerchants = false;      // F3
  static const duplicateWarning = false;  // F4
  static const learnCorrections = false;  // F5
  static const insights = false;          // F6
  static const pdfExport = false;         // F7
  static const edgeDetection = false;     // F8
  static const lineItems = false;         // F9
  static const backupRestore = false;     // F10
  static const appLock = false;           // F11
}
```
*Why compile-time constants:* the compiler removes the disabled code paths, tests can cover both states by reading the flag through a provider override, and the demo build is exactly what was verified.

### 12.3 Merchant normalization, learning from corrections, duplicate detection

**Normalization** is the shared foundation for F3, F4 and F5. Pure Dart, heavily unit-tested:

```dart
String normalizeMerchant(String raw) {
  var s = raw.toLowerCase().trim();
  s = s.replaceAll(RegExp(r'\([^)]*\)'), ' ');           // "(주)", "(Daeyeon)"
  s = s.replaceAll(RegExp(r'(주식회사|㈜)'), ' ');
  final tokens = s.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  // WHY: drop a trailing branch token ("대연점", "branch"), but never reduce the name to nothing.
  if (tokens.length > 1 && RegExp(r'(점|지점|매장|branch|store)$').hasMatch(tokens.last)) {
    tokens.removeLast();
  }
  return tokens.join().replaceAll(RegExp(r'[^0-9a-z가-힣]'), '');
}
```
Examples: `"GS25 대연점"` and `"GS25 광안점"` -> `gs25`; `"(주)스타벅스 부산대연점"` -> `스타벅스`.
Known limitation (state it in the report): a branch name glued to the brand with no space (for example `"스타벅스대연점"`) is not split.

**Learn from corrections (F5)**
```
suggest(merchant):
  key = normalizeMerchant(merchant)
  1. rule = merchantRuleRepository.categoryFor(key)   -> use it, mark "learned"
  2. keyword defaults (SCHEMA section 4)              -> use it
  3. 'other'
learn(merchant, chosenCategory, suggestedCategory):
  if key is not empty and chosenCategory != suggestedCategory:
      merchantRuleRepository.upsert(key, chosenCategory)
```
*Why only learn from differences:* accepting a suggestion adds no new information, and storing every receipt would fill the table with defaults.
*Trade-off:* latest choice wins. It is simple to explain and test; majority voting is a possible extension.

**Duplicate detection (F4)**
```
isPossibleDuplicate(candidate, existing):
  same currency AND same totalMinor AND same calendar day      (guaranteed by the SQL in SCHEMA 8.3)
  AND ( keys equal
        OR one key contains the other (length >= 3)
        OR either key is empty )
```
*Why not compare images:* near-duplicate image hashing adds a dependency and tuning. Total, date and merchant catch the real case (scanning the same receipt twice) cheaply, and the user can always choose "Save anyway".

### 12.4 Top merchants (F3)

`getMonthReceipts` returns the month's rows. `top_merchants.dart` groups by `normalizeMerchant`, sums totals, counts visits, uses the most frequent raw name as the display name, sorts by total, and returns the top 5. *Why in Dart:* the normalization lives there and is tested there.

### 12.5 Spending insights (F6)

`insights_engine.dart` is a pure function: `List<Insight> compute(MonthData current, MonthData previous, DateTime today)`. It returns **structured data**, not text, so the UI can localize it with ARB placeholders.

```dart
sealed class Insight {
  const Insight();
}
class MonthChange extends Insight { final int percent; final bool up; ... }
class CategoryChange extends Insight { final String categoryKey; final int percent; final bool up; ... }
class TopCategory extends Insight { final String categoryKey; final int sharePercent; ... }
class FrequentMerchant extends Insight { final String merchant; final int visits; ... }
class BiggestReceipt extends Insight { final String merchant; final int totalMinor; ... }
```

Rules, in priority order (show at most 3, skip rules without enough data):
1. `MonthChange`: previous total > 0 and the change is at least 10%.
2. `CategoryChange`: the category with the largest absolute change, only if this month's total for it is at least 10,000 KRW (1,000 minor units for USD) and the change is at least 20%.
3. `TopCategory`: top category share of at least 40%.
4. `FrequentMerchant`: one merchant with at least 3 visits.
5. `BiggestReceipt`: shown when there is at least one receipt.

**Important correctness rule:** if the selected month is the current month, compare against the previous month's **same day range** (day 1 to today's day), not the whole previous month. Comparing a half month with a full month would always say "spending is down".
Insights are deterministic and fully on-device. No AI summary in this version (privacy and testability).

### 12.6 PDF export (F7)

`PdfExporter.buildMonthlyReport({month, currency, receipts, categoryTotals, includeImages, locale}) -> File` writes to the temp directory, then the UI opens the system share sheet (`share_plus`; check its current API).

- Use `pw.MultiPage` so long lists paginate.
- Content: title and month, total, category table (name, amount, share), receipts table (date, merchant, category, amount), items under a receipt when present, footer with the creation date.
- **Fonts (critical):** the `pdf` package has no Korean glyphs in its built-in fonts, so Korean text shows as empty boxes. Bundle a **static TTF** with Korean coverage (for example Noto Sans KR or a static Pretendard TTF; variable fonts are not supported), load it with `pw.Font.ttf(await rootBundle.load(...))` for regular and bold, and pass both to `pw.ThemeData.withFont`.
- Photos off by default. If on: resize to at most 800 px on the long side, include at most 30, to keep the file small.
- Labels come from the same ARB strings as the UI (pass an `AppLocalizations` into the exporter). Money uses `Money` helpers.
- Test: unit-test the report-building function with a fake receipt list and check that the file exists and is non-empty. Check Korean rendering visually on both platforms.

### 12.7 Edge detection and auto-crop (F8)

`ReceiptCapture.capture()` returns the path of an image or `null` if cancelled. `SystemCameraCapture` wraps `image_picker`; `DocumentScannerCapture` wraps the scanner package, which detects the receipt edges and returns a cropped, perspective-corrected image. `captureProvider` picks the scanner only if `FeatureFlags.edgeDetection` is on **and** the scanner is available; any failure falls back to the system camera.

*Why an interface:* the scan controller does not know which capture method ran, so the OCR pipeline is unchanged and the two methods can be compared on the same set of receipts.

**Evaluation (the reason this feature exists):** photograph the same 15 or more receipts twice, once normally and once through the scanner, run both through the same OCR and parser, and compare field accuracy and processing time. Keep the flag on only if accuracy is not worse. Report the result either way.
**Risk:** a scanner package that works on both Android and iOS may not exist or may not match the current Flutter version. Check on Day 1. If it fails, drop F8; nothing else depends on it.

### 12.8 Backup and restore (F10)

`BackupService.createBackup() -> File` and `restore(File) -> RestoreResult`.

**Create**
1. `VACUUM INTO '<temp>/app.sqlite'` produces a consistent snapshot while the database is open (copying a live database file can capture a half-written state).
2. Zip: `app.sqlite`, the `receipts/` image folder, and `manifest.json` = `{appVersion, schemaVersion, createdAt, receiptCount}` (use the `archive` package).
3. Share through the system share sheet. Show the warning that the file holds all personal data.

**Restore**
1. Pick a file (`file_picker`), unzip into a temp folder.
2. Validate: it contains `app.sqlite` and a readable manifest; `manifest.schemaVersion <= current schemaVersion` (otherwise refuse with the "newer version" message); open the snapshot read-only and run `PRAGMA integrity_check`.
3. Confirmation dialog: "Replace all current data?"
4. Save an automatic **safety backup** of the current data (keep the last two).
5. Close the database, replace `app.sqlite` and the image folder, then reopen by invalidating the database provider, and refresh every provider.
6. On any error after step 4 starts, roll back from the safety backup and show an error.

*Why so many checks:* restore is the one feature that can destroy user data. The safety copy, validation and round-trip test (back up, wipe, restore, compare counts and totals) are the proof it is safe.

### 12.9 App lock (F11)

`AppLockService`: `isSupported()` (device has a screen lock or biometrics), `authenticate(reason)`. Implemented with `local_auth`, allowing the device passcode as a fallback (so no custom PIN code is needed). Check the package's current API and platform setup in its README: iOS needs a Face ID usage description in `Info.plist`; Android's main activity must extend `FlutterFragmentActivity` and needs the biometric permission.

Behavior:
- Setting persisted in `shared_preferences` (`appLockEnabled`).
- A lock gate widget wraps the app. It locks at launch and when the app returns from the background after more than 30 seconds, and shows `LockScreen` until authentication succeeds.
- Privacy shield: when the app becomes `inactive` (app switcher), draw an opaque overlay so spending data is not visible in the preview.
- Turning the lock on first requires one successful authentication. If `isSupported()` is false, the switch is disabled with an explanation.
- State is kept in memory. If the app process is killed, it locks again at next launch.

*Honest limitation (say it in the report):* this protects the screen, not the stored data. The database is not encrypted.

### 12.10 Line items (F9)

**Pipeline addition**
```
OcrResult -> RuleItemsExtractor -> items + itemsConfidence
              if itemsConfidence < threshold and AI fallback is on:
                  LlmItemsExtractor (masked text) -> validated items
              -> editable "Items" section in Review -> stored via replaceItems()
```
Items are parsed in a separate extractor from the three core fields, so item parsing problems can never lower the core accuracy.

**Rule-based extraction (`RuleItemsExtractor`)**
1. Find the item block: it starts after a header line (`상품명`, `품명`, `품 명`, `메뉴`, `단가`, `수량`, `Description`, `Item`) or, if none, after the date or merchant block, and ends at the first total-like keyword (`합계`, `소계`, `총액`, `부가세`, `TOTAL`, `SUBTOTAL`).
2. For each line, read trailing integers: the last number is the line total. If three numbers appear, treat them as unit price, quantity and total and check that `unit * qty == total`.
3. The name is the text before the numbers, with leading barcodes or item codes (digit runs of 6 or more) removed.
4. Two-line items (a name line with no numbers followed by a line with only numbers) are joined.
5. Ignore lines with discounts as items; keep them as negative adjustments if present.

**Sum check -> confidence**
| Check | `itemsConfidence` |
|---|---|
| Sum of line totals equals the receipt total | 0.9 |
| Equals within about 1%, or after adding or removing VAT (total / 11 rounded) | 0.6 |
| Otherwise | 0.3 |

**Fallback.** If `itemsConfidence` is below 0.6 and the AI toggle is on, send the **masked OCR text** to Gemini with a fixed JSON schema (`{"items":[{"name":"","quantity":1,"line_total_minor":0}]}`), validate it in Dart, and run the sum check again. If it fails, keep the rule result and show the amber "Items total differs from the receipt total" hint.

**Why the sum check:** it is a cheap, objective signal that needs no labels, and the same check lets the UI tell the user when the items probably do not add up.

### 12.11 Evaluation additions

| Experiment | Data | Metric |
|---|---|---|
| Core fields (existing) | about 30 receipts | merchant, date, total accuracy |
| Edge detection on/off | 15 or more receipts photographed both ways | field accuracy and time |
| Line items | 10 or more receipts with labeled items | item precision and recall |
| Learn from corrections | scripted test | after one correction, next draft uses learned category |

Label file extension for items (`labels/001.json`):
```json
{"merchant": "GS25 대연점", "date": "2026-11-18", "total_minor": 4300, "currency": "KRW",
 "items": [{"name": "삼각김밥 참치마요", "quantity": 1, "line_total_minor": 1500},
           {"name": "바나나우유", "quantity": 2, "line_total_minor": 2800}]}
```
Item scoring (add to `tool/eval_report.py`; reuses `norm` from the earlier script):
```python
from difflib import SequenceMatcher

def item_scores(truth_items, pred_items, thr=0.7):
    """An item matches if its line total is equal AND the names are similar enough."""
    used, tp = set(), 0
    for t in truth_items:
        for j, p in enumerate(pred_items):
            if j in used:
                continue
            same_amount = t["line_total_minor"] == p.get("line_total_minor")
            sim = SequenceMatcher(None, norm(t["name"]), norm(p.get("name", ""))).ratio()
            if same_amount and sim >= thr:
                used.add(j)
                tp += 1
                break
    precision = tp / len(pred_items) if pred_items else 0.0
    recall = tp / len(truth_items) if truth_items else 0.0
    return precision, recall
```

### 12.12 Testing additions

- `normalizeMerchant`: table-driven tests (branch suffixes, parentheses, mixed languages, empty input).
- `CategorySuggester`: rule beats keyword; learn only on difference.
- `DuplicateDetector`: true duplicates, near misses (different total or day), empty merchant, excluded self.
- `InsightsEngine`: thresholds, partial-month comparison, not enough data.
- `RuleItemsExtractor` and `CompositeItemsExtractor` (mocktail): sum check, two-line items, LLM only when needed.
- Repository: filters (text, category, date range, item name), cascade delete of items, `merchant_rules` upsert.
- `BackupService` round trip with a temp directory and an in-memory-backed file database.
- `PdfExporter`: produces a non-empty PDF with Korean text in the data.
