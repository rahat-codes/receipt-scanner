import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static const String _keyLanguage = 'settings_language';
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyGeminiFallback = 'settings_gemini_fallback';

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
}
