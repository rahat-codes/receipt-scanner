import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static const String _keyLanguage = 'settings_language';
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyGeminiFallback = 'settings_gemini_fallback';
  static const String _keyAiConsent = 'settings_ai_consent';
  static const String _keyAiAssistantEnabled = 'settings_ai_assistant_enabled';

  final SharedPreferences prefs;

  SettingsStore(this.prefs);

  static Future<SettingsStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsStore(prefs);
  }

  String getLanguage() => prefs.getString(_keyLanguage) ?? 'system';
  Future<void> setLanguage(String lang) => prefs.setString(_keyLanguage, lang);

  String getThemeMode() => prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) => prefs.setString(_keyThemeMode, mode);

  bool getGeminiFallback() => prefs.getBool(_keyGeminiFallback) ?? true;
  Future<void> setGeminiFallback(bool enabled) => prefs.setBool(_keyGeminiFallback, enabled);

  bool getAiConsent() => prefs.getBool(_keyAiConsent) ?? false;
  Future<void> setAiConsent(bool enabled) => prefs.setBool(_keyAiConsent, enabled);

  bool getAiAssistantEnabled() => prefs.getBool(_keyAiAssistantEnabled) ?? false;
  Future<void> setAiAssistantEnabled(bool enabled) => prefs.setBool(_keyAiAssistantEnabled, enabled);
}
