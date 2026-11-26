# DESIGN

Style: **glassmorphism**, light and dark following the system setting, Korean and English UI, Android and iOS.
Navigation: one receipts list as home, a floating Scan button, stats, assistant, and settings as secondary screens.

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

**Backgrounds** (multi-layer ambient gradient + glowing radial orbs)
- Light: linear gradient `[Color(0xFFEBF2F7), Color(0xFFDCE6F1), Color(0xFFE2EAF4)]`, overlaid with multi-layer glowing ambient radial orbs (Lagoon cyan top-left, Iris purple center-right, Sky blue bottom-left) to provide distinct background contrast behind glass elements.
- Dark: linear gradient `[Color(0xFF070E1B), Color(0xFF0F172A), Color(0xFF131F37)]`, overlaid with neon teal (`#3DD6C6`), iris violet (`#818CF8`), and sky blue (`#38BDF8`) ambient radial orbs for high-contrast glass refraction.

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
- `FrostedTile`: glass tile with 12px `BackdropFilter` blur, `g.fill` background, subtle border, shadow, and InkWell feedback. Use for every row in the receipts list and settings.
- `PerforatedSlip`: `GlassPanel` clipped by a `CustomClipper<Path>` that draws semicircular notches (radius about 6 px, spacing about 18 px) along the bottom edge.
- `AmberHint`: amber 1.5 px outline plus a caption below a field.

---

## 3. Screens

### 3.1 Receipts (home)

- Header shows current month total on perforated slip. App bar contains Stats, Assistant (sparkle icon, if enabled), and Settings actions.

---

## 9. Extended UI (v3: AI Assistant & Tips)

Each feature appears only when its flag is on (`aiAssistant`, `tipNotifications`). Same glass system and design tokens apply.

### 9.1 Assistant Screen (`assistant_screen.dart`)

Opened via the sparkle icon (`Icons.auto_awesome`) in the home app bar. Displays two tabs: "Chat" and "Tips".

```
┌──────────────────────────────┐
│ ‹  AI Assistant     [clear]  │  App bar with clear chat button
│  ┌────────────────────────┐  │
│  │   [ Chat ]  [ Tips ]   │  │  Segmented tab bar
│  └────────────────────────┘  │
│                              │
│  [ Suggestion Chips Wrap ]   │  "Food in Nov?", "Where to save?", "Compare months"
│                              │
│  ┌────────────────────────┐  │
│  │ User question bubble   │  │  Right-aligned FrostedTile bubble
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ Assistant reply bubble │  │  Left-aligned FrostedTile bubble (Lagoon accent)
│  └────────────────────────┘  │
│                              │
│  AI can make mistakes...     │  Permanent disclaimer caption
│  [ Type a question...  > ]   │  GlassPanel input bar
└──────────────────────────────┘
```

- **Suggestion Chips**: 3 horizontal choice chips ("Food in Nov?", "Where can I save?", "Compare this month with last month"). Tapping populates and submits the prompt.
- **Chat Bubbles**: Frosted fill tiles (no `BackdropFilter` per message for performance). User messages aligned right; Assistant replies aligned left with Iris accent icon.
- **Input Bar**: Bottom `GlassPanel` with text field and send icon button. Displays typing indicator during API call.
- **Disclaimer**: Permanent caption at bottom: *"AI can make mistakes. Tips are general, not financial advice."*
- **First-Use Consent Dialog**: Appears on first chat attempt explaining: *"The AI assistant analyzes precomputed monthly totals and category shares to answer your questions. Merchant names, raw receipts, and card numbers are never shared."* Options: "I agree", "Cancel".
- **Clear Chat Action**: Top-right app bar action clears in-memory chat turns immediately.

### 9.2 Tips Tab

Shows a list of generated and scheduled tips in `FrostedTile` cards with category icons, title, body, and timestamp. Unread tips feature a subtle Lagoon dot indicator.

### 9.3 Settings Additions (v3)

New `FrostedTile` group for AI & Notifications:
- **AI Assistant switch**: Enables/disables F12 chat.
- **Tip notifications switch**: Enables/disables F13 local notifications (requests runtime notification permission on toggle).
- **Tip frequency dropdown**: Off, Weekly, 3 per week, Daily.
- **Preferred notification time picker**: Clamped between 08:00 and 21:00.
- **Personalize tips with AI switch**: Disabled if AI assistant switch is off.
- **Show amounts in notifications switch**: Off by default for lock-screen privacy.

### 9.4 Added Copy (English & Korean)

| Key | English | 한국어 |
|---|---|---|
| assistantTitle | AI Assistant | AI 어시스턴트 |
| tabChat | Chat | 대화 |
| tabTips | Tips | 팁 |
| chipFoodMonth | How much on food in November? | 11월 식비는 얼마나 썼나요? |
| chipWhereToSave | Where can I save money? | 어디서 절약할 수 있을까요? |
| chipCompareMonths | Compare this month with last month | 이번 달과 지난달 지출 비교해줘 |
| disclaimerText | AI can make mistakes. Tips are general, not financial advice. | AI는 실수할 수 있어요. 팁은 일반적인 조언이며 재무 상담이 아니에요. |
| clearChat | Clear chat | 대화 삭제 |
| chatCleared | Chat history cleared. | 대화 내용이 삭제되었어요. |
| consentTitle | Enable AI Assistant? | AI 어시스턴트를 사용할까요? |
| consentBody | The AI assistant uses precomputed monthly totals and category shares to answer your questions. Merchant names, item details, and card numbers are never sent. | AI 어시스턴트는 집계된 월별 합계와 카테고리 비율만 사용하여 질문에 답변해요. 상호명, 세부 품목, 카드번호는 절대 전송되지 않아요. |
| agree | Agree | 동의함 |
| askAssistantHint | Type a question about your spending... | 지출에 대해 궁금한 점을 물어보세요... |
| offlineAssistantFallback | Here's what I can tell without AI: | AI 없이 확인할 수 있는 내용이에요: |
| aiAssistantSetting | AI Assistant | AI 어시스턴트 |
| aiAssistantHelp | Ask questions about your spending in plain language. | 지출에 대해 대화형으로 질문하고 답변을 받아요. |
| tipNotifications | Tip notifications | 지출 팁 알림 |
| tipNotificationsHelp | Receive local notifications with practical money-saving tips. | 실용적인 지출 절약 팁을 알림으로 받아요. |
| tipFrequency | Notification frequency | 알림 주기 |
| freqOff | Off | 끄기 |
| freqWeekly | Weekly | 매주 1회 |
| freqThreePerWeek | 3 per week | 주 3회 |
| freqDaily | Daily | 매일 1회 |
| preferredTime | Preferred time | 알림 시각 |
| personalizeTipsAi | Personalize tips with AI | AI로 맞춤 팁 생성 |
| showAmountsInNotifs | Show amounts in notifications | 알림에 금액 표시 |
| showAmountsHelp | Off by default to keep spending private on your lock screen. | 잠금 화면 보안을 위해 기본적으로 금액을 숨겨요. |

### 9.5 Acceptance Checklist (v3)

- [ ] Chat bubbles render crisply in Light and Dark modes without scrolling jank.
- [ ] Suggestion chips properly send prompts and render responses.
- [ ] Offline query renders friendly message + deterministic insights fallback.
- [ ] First use presents consent dialog.
- [ ] Lock-screen notification shows no monetary amounts unless enabled in settings.
- [ ] Clear chat wipes in-memory messages immediately.
