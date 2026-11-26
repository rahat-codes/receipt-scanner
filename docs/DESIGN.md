# DESIGN

Style: **glassmorphism**, light and dark following the system setting, Korean and English UI, Android and iOS.
Navigation: one receipts list as home, a floating Scan button, stats and settings as secondary screens.

## 1. Design plan

**Concept.** A receipt is a thin paper slip. The UI is a calm, cool gradient world where frosted glass panels float over it, and the one thing that looks like paper is the monthly total: a frosted *slip* with a perforated bottom edge. Everything else stays quiet so that slip is the memorable element.

**Palette** (all colors come from `lib/presentation/theme/app_colors.dart`; change them in one place)

| Name | Hex | Role |
|---|---|---|
| Ink | `#0F1B2D` | Text on light, dark-mode background base, text on primary buttons |
| Lagoon | `#12B5A6` | Primary (light mode). Dark mode uses lighter `#3DD6C6` |
| Iris | `#7C83FD` | Secondary, gradient partner, past-month bars |
| Fog | `#EAF1F6` | Light-mode background base, dark-mode text |
| Amber | `#F5A524` | "Needs review" highlight |
| Error | `#E5484D` | Destructive actions and errors |

**Backgrounds** (static, no animation)
- Light: linear gradient Fog `#EAF1F6` -> `#DCDDFF` -> `#CDF2ED` (top-left to bottom-right), plus two soft radial blobs of Iris and Lagoon at 25% opacity.
- Dark: `#0B1424` -> `#1A1F4A` -> `#0D3A39`, same blobs at 30% opacity.

**Type.** One family: **Pretendard** (free, SIL OFL, covers Korean and Latin). Bundle it in `assets/fonts/` and fall back to the system font. Weights: 400, 600, 800.

| Style | Size / weight | Use |
|---|---|---|
| amountXL | 40 / 800, tabular figures | Monthly total on the slip |
| amount | 18 / 700, tabular figures | Receipt amounts in rows |
| title | 22 / 700 | Screen titles |
| subtitle | 17 / 600 | Merchant names, section titles |
| body | 16 / 400 | Default text (keep 16 for Korean legibility) |
| caption | 13 / 500 | Dates, hints |

Use `FontFeature.tabularFigures()` on every amount so digits align in lists. Sentence case everywhere, no all-caps labels, no decorative eyebrows.

**Principles**
1. Spend boldness in one place: the perforated total slip. Everything else is disciplined.
2. Glass is for surfaces that float (slip, sheets, dialogs, form panel). List items are frosted fills **without** blur.
3. Readability beats effect. If contrast is below 4.5:1, raise the glass opacity.
4. Motion only answers an action. No entrance animations on every card.
5. Amber means "check this" and nothing else.

## 2. Glass system

### 2.1 Tokens (`lib/presentation/theme/glass_tokens.dart`)

| Token | Light | Dark |
|---|---|---|
| `glassFill` | white at 55% | white at 10% |
| `glassFillStrong` (sheets, dialogs, inputs) | white at 75% | `#16203A` at 85% |
| `glassBorder` | white at 70%, 1 px | white at 18%, 1 px |
| `blurSigma` | 18 | 24 |
| `shadow` | Ink at 10%, offset (0, 10), blur 30 | black at 35%, same geometry |
| `radiusSlip` | 28 | 28 |
| `radiusCard` | 20 | 20 |
| `radiusInput` | 14 | 14 |
| `radiusChip` | 999 | 999 |
| spacing scale | 4, 8, 12, 16, 24, 32 | same |

Expose tokens through a `ThemeExtension<GlassTheme>` so widgets read `Theme.of(context).extension<GlassTheme>()!`.

### 2.2 Widgets to build (`lib/presentation/theme/`)

- `AuroraBackground`: static gradient plus radial blobs, wraps every screen's `Scaffold` (`backgroundColor: Colors.transparent`).
- `GlassPanel`: `ClipRRect` -> `BackdropFilter(ImageFilter.blur)` -> `DecoratedBox` (fill, border, shadow). **Wrap in `RepaintBoundary`.** Use for the slip, bottom sheets, dialogs and the review form panel.
- `FrostedTile`: same fill and border **without** `BackdropFilter`. Use for every row in the receipts list and settings.
- `PerforatedSlip`: `GlassPanel` clipped by a `CustomClipper<Path>` that draws semicircular notches (radius about 6 px, spacing about 18 px) along the bottom edge.
- `AmberHint`: amber 1.5 px outline plus a caption below a field.

```dart
// Pattern for GlassPanel (WHY comments are required in real code)
class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.radius = 20, this.strong = false});
  final Widget child; final double radius; final bool strong;

  @override
  Widget build(BuildContext context) {
    final g = Theme.of(context).extension<GlassTheme>()!;
    // WHY: opaque surface when the user asked for high contrast; blur hurts legibility for some users.
    final opaque = MediaQuery.of(context).highContrast;
    final fill = opaque ? g.opaqueSurface : (strong ? g.fillStrong : g.fill);
    final box = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: g.border),
        boxShadow: [g.shadow],
      ),
      child: child,
    );
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: opaque
            ? box
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: g.blurSigma, sigmaY: g.blurSigma),
                child: box,
              ),
      ),
    );
  }
}
```

### 2.3 Performance and accessibility rules

- **Never** put `BackdropFilter` on items inside a scrolling list. One blur per screen region at most (slip, plus an open sheet or dialog).
- Text on glass: Ink on light glass, Fog on dark glass. Verify contrast at least 4.5:1 for body text and 3:1 for large text.
- Primary buttons: Lagoon fill with **Ink text** (white on Lagoon fails contrast).
- Tap targets at least 48 x 48 dp. Text must scale up to 200% without clipping (test on a large system font).
- Respect `MediaQuery.disableAnimations`: skip the count-up and use no transitions.
- Do not rely on color alone: amber fields also show a text hint and an icon; chart legends show names and values.

## 3. Screens

Routing: plain `Navigator.push` with `MaterialPageRoute` (five screens do not need a router package).

### 3.1 Receipts (home)

```
┌──────────────────────────────┐
│ Receipts            [chart][⚙]│  app bar (transparent), stats + settings icons
│                              │
│ ╔══════════════════════════╗ │
│ ║ November                 ║ │  PerforatedSlip
│ ║ ₩ 184,300                ║ │  amountXL, count-up on change
│ ║ 12 receipts              ║ │
│ ╚◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡◡╝ │  perforated edge
│                              │
│ ┌──────────────────────────┐ │  FrostedTile (no blur)
│ │ ● GS25 대연점     ₩4,300 │ │  category dot, merchant, amount
│ │   Nov 18 · Groceries     │ │  caption
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ ● Café Blue      ₩12,500 │ │
│ └──────────────────────────┘ │
│                              │
│                  [ + Scan ]  │  extended FAB (Lagoon, Ink text)
└──────────────────────────────┘
```

- Header shows the current month and its total for the default currency (KRW). Tapping the slip opens Stats.
- Row: category color dot, merchant (subtitle), caption with date and category name, amount right-aligned. A small "AI-assisted" icon appears if `parser_source == llm`.
- Swipe left to delete with an undo snackbar. Tap opens the detail screen.
- Empty state: a simple line illustration of a slip (use `CustomPaint` or an icon), title "No receipts yet", body "Scan your first receipt to start tracking.", button "Scan receipt".
- **Scan button** opens a glass bottom sheet with the actions listed in section 8.1 (system camera and gallery via `image_picker`, plus manual entry and, when enabled, auto-crop scanning) (system camera and `image_picker`).

### 3.2 Processing (modal state over the scan flow)

A `GlassPanel` dialog with a progress indicator and a status line that changes with the pipeline: "Reading text...", "Finding the total...", and, only if the fallback runs, "Asking AI to double-check...". A "Cancel" text button is always available. No fake delays.

### 3.3 Review (add and edit)

Plain, editable form on a `GlassPanel` (strong fill). Fields, top to bottom:

1. Merchant (text)
2. Date (tap to open the date picker)
3. Total (numeric keypad; display grouping for KRW)
4. Currency (segmented control: KRW, USD)
5. Category (wrap of selectable chips with the category color dot)

- Fields in `needsReview` get an `AmberHint`: amber outline, a warning icon, and a hint such as "Check this: the total may be wrong".
- Top-right shows a small badge: "Auto", "AI-assisted" or "Edited" (from `parser_source`; becomes "Edited" once the user changes any field of an auto result, stored as `manual` only when everything was typed by hand).
- Buttons: **Save receipt** (primary), **Discard** (text button). Discard after edits asks "Discard this receipt?" with "Keep editing" and "Discard".
- Validation: total must be greater than 0; merchant may be empty (save as "Unknown merchant" localized). Show inline errors under the field, not toasts.
- If OCR found nothing: open the same form empty, with all fields flagged and the message "We couldn't read this receipt. Enter the details below."

### 3.4 Receipt detail

Receipt photo at the top (rounded, tap to zoom with `InteractiveViewer`), then a `GlassPanel` listing merchant, date, total, category, and a caption line showing how it was filled. Actions: **Edit** (opens Review), **Delete receipt** (destructive, confirmation dialog: "Delete this receipt? This can't be undone.").

### 3.5 Stats

```
┌──────────────────────────────┐
│ ‹  Stats                      │
│    [ ‹  November 2026  › ]    │  month selector
│  ┌────────────────────────┐  │
│  │      ◜◝  donut         │  │  GlassPanel (the one blur on this screen)
│  │     ◟◞  ₩184,300       │  │  total in the center
│  │ ● Food        ₩72,000 39%│ │  legend: dot, name, amount, share
│  │ ● Groceries   ₩51,300 28%│ │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ ▂ ▅ ▃ ▇ ▄ ▆            │  │  last 6 months bar chart
│  │ Jun Jul Aug Sep Oct Nov │  │  current month in Lagoon, others Iris 60%
│  └────────────────────────┘  │
└──────────────────────────────┘
```

- Donut: `fl_chart` `PieChart` with a large center hole and category colors from the database. Tapping a slice highlights its legend row.
- Bars: `fl_chart` `BarChart`, y-axis hidden, value labels above bars abbreviated per locale (Korean: `18만`, English: `184K`).
- Empty month: "No receipts in this month." with the charts hidden.
- Both charts must have text alternatives (`Semantics` label summarizing the numbers).

### 3.6 Settings

Three `FrostedTile` groups:
- **Language:** System / English / 한국어
- **Appearance:** System / Light / Dark
- **AI double-check:** switch, with the helper text "When on, text from receipts the app can't read confidently is sent to Google's Gemini API. Photos are never sent. Card and phone numbers are hidden first."

Changes apply immediately and persist.

## 4. Copy (English and Korean)

Use these as the first ARB entries. Sentence case, active verbs, same word for the same action everywhere.

| Key | English | 한국어 |
|---|---|---|
| appTitle | Receipt Scanner | 영수증 스캐너 |
| scanReceipt | Scan receipt | 영수증 스캔 |
| takePhoto | Take photo | 사진 촬영 |
| chooseFromGallery | Choose from gallery | 갤러리에서 선택 |
| receiptsTitle | Receipts | 영수증 |
| statsTitle | Stats | 통계 |
| settingsTitle | Settings | 설정 |
| receiptCount | {count, plural, =1{1 receipt} other{{count} receipts}} | 영수증 {count}건 |
| emptyTitle | No receipts yet | 아직 영수증이 없어요 |
| emptyBody | Scan your first receipt to start tracking. | 첫 영수증을 스캔해서 지출을 기록해 보세요. |
| reading | Reading text... | 글자를 읽는 중... |
| findingTotal | Finding the total... | 합계를 찾는 중... |
| askingAi | Asking AI to double-check... | AI가 다시 확인하는 중... |
| merchant | Merchant | 상호 |
| date | Date | 날짜 |
| total | Total | 합계 |
| currency | Currency | 통화 |
| category | Category | 카테고리 |
| saveReceipt | Save receipt | 영수증 저장 |
| discard | Discard | 취소 |
| keepEditing | Keep editing | 계속 수정 |
| deleteReceipt | Delete receipt | 영수증 삭제 |
| deleteConfirm | Delete this receipt? This can't be undone. | 이 영수증을 삭제할까요? 되돌릴 수 없어요. |
| checkThis | Check this: it may be wrong. | 확인해 주세요. 틀릴 수 있어요. |
| unreadable | We couldn't read this receipt. Enter the details below. | 영수증을 읽지 못했어요. 아래에 직접 입력해 주세요. |
| unknownMerchant | Unknown merchant | 알 수 없는 상호 |
| badgeAuto | Auto | 자동 |
| badgeAi | AI-assisted | AI 보조 |
| badgeEdited | Edited | 수정됨 |
| aiUnavailable | AI check unavailable. Please review the fields. | AI 확인을 사용할 수 없어요. 항목을 확인해 주세요. |
| permissionCamera | Allow camera access to scan receipts. | 영수증을 스캔하려면 카메라 접근을 허용해 주세요. |
| openSettings | Open settings | 설정 열기 |
| noReceiptsMonth | No receipts in this month. | 이달에는 영수증이 없어요. |
| language | Language | 언어 |
| appearance | Appearance | 화면 모드 |
| aiDoubleCheck | AI double-check | AI 재확인 |
| aiDoubleCheckHelp | (see 3.6) | 확인이 어려운 영수증의 텍스트만 Google Gemini API로 전송해요. 사진은 전송하지 않으며, 카드·전화번호는 먼저 가려요. |
| total_this_month | {month} total | {month} 합계 |

Category labels: use the table in `docs/SCHEMA.md`.

## 5. Formatting rules

- Amounts: `NumberFormat.currency` per locale. KRW has no decimals. English: `₩12,300`. Korean: `12,300원`. USD: `$12.30`.
- Dates: `DateFormat.yMMMd(locale)` in lists, `yMMMMd` in detail.
- Never format money from a `double`; convert from minor units with the `Money` helper.

## 6. Motion (only these)

1. Total on the slip animates from the old value to the new one over about 400 ms when the data changes (`TweenAnimationBuilder`). Skipped when animations are disabled.
2. New list item slides in once after saving. Delete uses the swipe dismiss with an undo snackbar.
3. Standard Material page and bottom-sheet transitions. Nothing else.

## 7. Design acceptance checklist

- [ ] Light and dark both look intentional (check the glass opacity in each)
- [ ] Only the slip, sheets, dialogs and form panel use blur; list scrolling stays smooth on a mid-range phone
- [ ] All text readable on glass at 200% font scale
- [ ] Korean strings do not overflow buttons or chips
- [ ] Amber hints are visible but not alarming; each has text, not color only
- [ ] Every screen has loading, empty and error states
- [ ] No hardcoded colors or strings in widget files

---

## 8. Extended UI (v2)

Each feature appears only when its flag is on (`docs/ARCHITECTURE.md` section 12.2). Same glass system, tokens and rules as before: blur only on the slip, sheets, dialogs, lock screen and form panel; `FrostedTile` everywhere else.

### 8.1 Scan sheet (replaces the two-action sheet)

A glass bottom sheet with up to four actions, in this order:
1. **Scan with auto-crop** (only if edge detection is on) - primary style
2. **Take photo**
3. **Choose from gallery**
4. **Enter manually** (opens the Review form empty, today's date, all fields editable)

If auto-crop is off, "Take photo" is the primary action.

### 8.2 Home: search and filter

- Below the slip: a `FrostedTile` search field (hint "Search merchant or item"), debounced about 300 ms.
- Under it, a horizontally scrolling row of chips: **Category** (opens a multi-choice sheet; single selection is enough), **Date range** (system date range picker). Active chips use the Lagoon outline and a check or close icon.
- When any filter is active: the slip shows the **filtered** total with a caption "Filtered", and a "Clear filters" text button appears.
- No results: simple state "No receipts match your search." with a "Clear filters" button.
- Do not hide the Scan button while searching.

### 8.3 Duplicate dialog

A `GlassPanel` dialog: title "Possible duplicate", body "You already saved a receipt with the same total on this day.", a compact summary tile of the existing receipt (merchant, date, amount), and three actions: **View existing** (secondary), **Save anyway** (primary), **Discard** (text button).

### 8.4 Review additions

- Under the Category chips: when a learned rule was used, show a caption with a small history icon: "Suggested from your past choices". Changing the category removes the caption.
- **Items (optional)** section (only if line items are on): a collapsed `FrostedTile` header with the item count. Expanded rows: item name (text), quantity (small numeric), line total (numeric), delete icon. "Add item" button below.
- Sum line under the list: "Items total ₩X · Receipt total ₩Y". If they differ, show it with the amber hint and the text "Items total differs from the receipt total." (information only; saving is never blocked).
- Items extracted by AI carry the same "AI-assisted" badge as the receipt.

### 8.5 Detail additions

Below the main panel, a "Items" `FrostedTile` list (name, quantity, amount) when items exist.

### 8.6 Stats additions

Top to bottom: month selector, **Insights**, donut, bars, **Top merchants**.
- **Insights:** up to 3 `FrostedTile` cards, each with a small icon (trend up, trend down, store, receipt) and one localized sentence. Positive and negative changes do not use red or green alone: the sentence and the arrow icon carry the meaning. Hidden when there is not enough data.
- **Top merchants:** up to 5 rows: rank number, merchant, visits caption, amount right-aligned, and a thin proportional bar behind or under the row (Lagoon at 25%).
- **Share action** in the app bar (share icon) opens the PDF sheet (section 8.7).

### 8.7 PDF sheet

A glass bottom sheet: month name, switch "Include receipt photos (larger file)" (off by default), the warning "This file contains your spending data. Share it only with people you trust.", and a primary button "Create PDF". While creating, show a progress indicator in the button. On success the system share sheet opens.

### 8.8 Settings additions

New `FrostedTile` groups:
- **App lock** switch with the help text from the copy table. Disabled with an explanation if the device has no screen lock.
- **Backup and restore:** "Create backup" and "Restore from backup" tiles, with the warning "Backup files contain all your receipts and photos. Keep them private." Restore uses a destructive-style confirmation dialog (section 4 copy). Progress and result shown with a dialog or snackbar ("Backup restored.").
- The "AI double-check" help text also mentions item names (see the copy table).

### 8.9 Lock screen and privacy shield

- **Lock screen:** full-screen `AuroraBackground`, a centered `GlassPanel` with a lock icon, the app name, and an **Unlock** button. The system authentication prompt opens automatically once; the button retries.
- **Privacy shield:** when the app goes inactive (app switcher), cover it with an opaque Ink (dark) or Fog (light) screen with the app icon. No spending data may appear in the app switcher preview.

### 8.10 Added copy (English and Korean)

| Key | English | 한국어 |
|---|---|---|
| enterManually | Enter manually | 직접 입력 |
| scanWithAutoCrop | Scan with auto-crop | 자동 자르기로 스캔 |
| searchHint | Search merchant or item | 상호 또는 품목 검색 |
| filterCategory | Category | 카테고리 |
| filterDateRange | Date range | 기간 |
| filtered | Filtered | 필터 적용됨 |
| clearFilters | Clear filters | 필터 초기화 |
| noResults | No receipts match your search. | 검색 결과가 없어요. |
| duplicateTitle | Possible duplicate | 중복일 수 있어요 |
| duplicateBody | You already saved a receipt with the same total on this day. | 같은 날 같은 금액의 영수증이 이미 저장되어 있어요. |
| viewExisting | View existing | 기존 영수증 보기 |
| saveAnyway | Save anyway | 그래도 저장 |
| suggestedFromHistory | Suggested from your past choices | 이전 선택을 바탕으로 추천했어요 |
| itemsSection | Items (optional) | 품목 (선택) |
| addItem | Add item | 품목 추가 |
| itemName | Item name | 품목명 |
| itemQty | Qty | 수량 |
| itemsTotalLine | Items total {items} · Receipt total {total} | 품목 합계 {items} · 영수증 합계 {total} |
| itemsTotalMismatch | Items total differs from the receipt total. | 품목 합계가 영수증 합계와 달라요. |
| topMerchants | Top merchants | 자주 간 곳 |
| visitCount | {count, plural, =1{1 visit} other{{count} visits}} | {count}회 방문 |
| insightsTitle | Insights | 인사이트 |
| insightMonthUp | Spending is up {percent}% compared with the same period last month. | 지난달 같은 기간보다 지출이 {percent}% 늘었어요. |
| insightMonthDown | Spending is down {percent}% compared with the same period last month. | 지난달 같은 기간보다 지출이 {percent}% 줄었어요. |
| insightCategoryUp | {category} spending is up {percent}% from last month. | {category} 지출이 지난달보다 {percent}% 늘었어요. |
| insightCategoryDown | {category} spending is down {percent}% from last month. | {category} 지출이 지난달보다 {percent}% 줄었어요. |
| insightTopCategory | {category} is {percent}% of this month's spending. | 이번 달 지출의 {percent}%가 {category}예요. |
| insightFrequent | You visited {merchant} {count} times this month. | 이번 달 {merchant}에 {count}번 갔어요. |
| insightBiggest | Your biggest receipt was {amount} at {merchant}. | 가장 큰 지출은 {merchant}의 {amount}이에요. |
| exportPdf | Export PDF | PDF 내보내기 |
| includePhotos | Include receipt photos (larger file) | 영수증 사진 포함 (파일이 커져요) |
| pdfWarning | This file contains your spending data. Share it only with people you trust. | 이 파일에는 지출 정보가 들어 있어요. 믿을 수 있는 사람과만 공유하세요. |
| createPdf | Create PDF | PDF 만들기 |
| appLock | App lock | 앱 잠금 |
| appLockHelp | Asks for your fingerprint, face or phone passcode when opening the app. This locks the screen; it does not encrypt your data. | 앱을 열 때 지문, 얼굴 또는 휴대폰 잠금 번호를 요청해요. 화면을 잠그는 기능이며 데이터를 암호화하지는 않아요. |
| appLockUnavailable | Set a screen lock on your phone to use this. | 사용하려면 휴대폰에 화면 잠금을 설정해 주세요. |
| unlock | Unlock | 잠금 해제 |
| backupRestore | Backup and restore | 백업 및 복원 |
| createBackup | Create backup | 백업 만들기 |
| restoreBackup | Restore from backup | 백업에서 복원 |
| backupWarning | Backup files contain all your receipts and photos. Keep them private. | 백업 파일에는 모든 영수증과 사진이 들어 있어요. 안전하게 보관하세요. |
| restoreConfirm | Replace all current data with this backup? A safety copy of your current data will be saved first. | 현재 데이터를 이 백업으로 모두 바꿀까요? 현재 데이터는 먼저 안전 사본으로 저장돼요. |
| restoreDone | Backup restored. | 복원했어요. |
| restoreInvalid | This file isn't a valid backup. | 올바른 백업 파일이 아니에요. |
| restoreNewer | This backup was made by a newer version of the app. | 더 새로운 버전의 앱에서 만든 백업이에요. |
| aiDoubleCheckHelp (updated) | When on, text from receipts the app can't read confidently (including item names) is sent to Google's Gemini API. Photos are never sent. Card and phone numbers are hidden first. | 확인이 어려운 영수증의 텍스트(품목명 포함)만 Google Gemini API로 전송해요. 사진은 전송하지 않으며, 카드·전화번호는 먼저 가려요. |

Pluralization and placeholders must use ICU syntax in the ARB files. Translated sentences carry the whole meaning, so do not build sentences by joining fragments in Dart.

### 8.11 Added design acceptance checklist

- [ ] Search and filter work together; clearing returns the full list and the normal total
- [ ] Duplicate dialog, lock screen and PDF sheet read well in light and dark and at 200% font scale
- [ ] Items editor rows do not overflow in Korean; the sum line is readable
- [ ] Insights and top merchants are hidden or replaced by a calm empty state when there is no data
- [ ] No spending data is visible in the app switcher when the app lock is on
- [ ] Destructive actions (delete, restore) use the destructive style and a confirmation
