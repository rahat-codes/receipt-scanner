# Security and Safety Review

## Scope
This document covers the security, safety, and privacy review for **Receipt Scanner** v1.0.0. The audit evaluates local data protection, secret handling, network traffic, AI assistant data minimization, and build hardening.

---

## Findings Summary Table

| ID | Area | Severity | Evidence | Proposed Fix / Action | Effort | Status |
|---|---|---|---|---|---|---|
| F-01 | Data at rest / Backups | Medium | `android/app/src/main/AndroidManifest.xml` | Set `android:allowBackup="false"` and `android:fullBackupContent="false"` to prevent Google Drive auto-backup of receipt photos and local database. | S | **Fixed** |
| F-02 | Data at rest / Cleanup | Medium | `lib/presentation/screens/review_screen.dart:82` | Implemented `_cleanupImage()` on review discard and failed save to eliminate orphan image files. | S | **Fixed** |
| F-03 | Data at rest / Privacy | Low | `lib/presentation/screens/settings_screen.dart:102` | Added "Delete all data" tile in Settings with confirmation dialog to wipe database tables and receipt photos. | M | **Fixed** |
| F-04 | Network / Permissions | High | `android/app/src/main/AndroidManifest.xml:3` | Explicitly declared `<uses-permission android:name="android.permission.INTERNET" />` in main manifest for release AI assistant queries. | S | **Fixed** |
| F-05 | Secrets / Bundling | Low | `pubspec.yaml` assets (`.env`) | Documented client APK key extraction risk and Cloud Console API key restriction / rotation requirements. | S | **Accepted** |

---

## Commands to Re-Verify

1. **Static Analysis**:
   ```bash
   flutter analyze
   ```
2. **Automated Test Suite**:
   ```bash
   flutter test --reporter expanded
   ```
3. **Secret Pattern Check**:
   ```bash
   git grep -E "AIza[0-9A-Za-z_-]{35}" -- ':!.env.example'
   ```
4. **Obfuscated Release Build**:
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/symbols
   ```
5. **OCR Fixture Evaluation**:
   ```bash
   dart tool/generate_predictions.dart
   python tool/eval_report.py
   ```

---

## Residual Risks

1. **Client-Side API Key Extraction**:
   Because `.env` is bundled in `pubspec.yaml` assets for offline client operation, an attacker can extract `app-release.apk`, unzip it, and read `GEMINI_API_KEY` from `assets/flutter_assets/.env`.
   *Mitigation*: For this student demo, the key is restricted in Google Cloud Console / AI Studio to the Generative Language API with quota caps and must be rotated after the demo. A production deployment requires a server-side backend proxy where keys reside strictly on the server.

2. **Unencrypted Storage at Rest & No App Lock**:
   Receipt photos and SQLite database records (`app.sqlite`) are stored in unencrypted app-private storage (`getApplicationDocumentsDirectory()`). The app currently does not enforce biometric app lock (local_auth).
   *Mitigation*: Data is protected by standard Android/iOS application sandbox isolation.

3. **Free Gemini Tier Content Review**:
   On Google's free Gemini API tier, submitted content may be logged and inspected by human reviewers to improve Google models.
   *Mitigation*: The app displays an explicit consent dialog warning users not to submit real personal data. This demo uses synthetic test data. Apps targeting users in the EEA, Switzerland, or the UK must use paid enterprise API tiers.

4. **Merchant Name Transmission**:
   When answering AI assistant questions about specific spending places, merchant names (up to 10 per answer) are sent to Gemini.
   *Mitigation*: Raw OCR text, receipt photos, and line item names are never sent to Gemini.

5. **iOS Unverified Platform**:
   The application was compiled and tested on Android and Windows developer environments. iOS build, ATS, and privacy manifest configurations remain unverified on macOS hardware.

6. **sqlite3_flutter_libs Upstream EOL**:
   `sqlite3_flutter_libs` is marked end-of-life upstream by its maintainer.
   *Mitigation*: Migration to standard Flutter `sqlite3` or system SQLite bindings is flagged for future maintenance.

---

## How to Report a Vulnerability

If you discover a security vulnerability or privacy issue in this project, please report it directly via GitHub Security Advisories or contact the repository maintainer. Do not open public issues for zero-day vulnerabilities.
