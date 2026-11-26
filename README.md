# Receipt Scanner (영수증 스캐너)

An offline-first Flutter application (Android & iOS) developed as a mobile programming final project. It enables users to photograph receipts (in Korean or English), extract receipt details via on-device ML Kit OCR and rule-based parsers, and optionally invoke the Gemini API as an intelligent fallback when confidence is low. All data is securely stored locally using Drift/SQLite with zero server tracking or login required.

---

## Features

- **Core (P0):**
  - **Scan & Extract:** System camera / gallery image input, on-device Google ML Kit OCR (Korean script recognizer supporting Latin text & digits).
  - **Deterministic Parsing:** Rule-based extraction of merchant, purchase date, total amount, and currency (KRW default, USD supported) with confidence scoring and amber review highlights.
  - **AI Fallback:** Optional Gemini API REST integration utilizing masked OCR text (protecting card/phone numbers) when rule confidence is low.
  - **Review & Manage:** Editable form, category tagging, local Drift database storage, search, history list, and monthly totals.
  - **Stats & Localization:** Donut chart of category spending and 6-month spending trends using `fl_chart`, fully localized in English and Korean (`flutter_gen-l10n`).
  - **Glassmorphism Design:** Modern frosted glass UI with dynamic light and dark themes.

- **Extended Scope (v2, behind feature flags):**
  - Manual entry, search & filter, top merchants ranking, duplicate warning, learning category corrections, spending insights, PDF report export & share, edge detection/auto-crop, line-item extraction, backup & restore, and app biometrics lock (`local_auth`).

---

## Architecture

The project follows strict clean architecture and separation of concerns:
```
presentation -> application -> domain <- data
```
- **`domain/`**: Pure Dart entities and abstract interfaces (no Flutter/plugin dependencies).
- **`data/`**: Concrete implementations (ML Kit, Drift repository, Gemini client).
- **`application/`**: Use case controllers (Riverpod state management).
- **`presentation/`**: Screens and custom glassmorphism widgets.

---

## Documentation

Comprehensive project documentation is available in the [`docs/`](docs/) directory:
- [PRD (Product Requirements Document)](docs/PRD.md)
- [Architecture & Data Flow](docs/ARCHITECTURE.md)
- [Database Schema & Drift Models](docs/SCHEMA.md)
- [UI / UX Design & Glassmorphism Spec](docs/DESIGN.md)
- [7-Day Plan & Gates](docs/PLAN.md)
- [Team Collaboration & Git Workflow](docs/COLLABORATION.md)

---

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Dart SDK
- Android Studio / Xcode for platform dependencies and emulators/devices.

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/receipt-scanner.git
   cd receipt-scanner
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**
   Copy `.env.example` to `.env` and configure your Gemini API key (optional, for AI fallback):
   ```bash
   cp .env.example .env
   ```

4. **Generate code (Drift database & localization):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter gen-l10n
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

---

## Running Tests

Run unit and widget tests:
```bash
flutter test
```

Check code analysis:
```bash
flutter analyze
```

---

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.
