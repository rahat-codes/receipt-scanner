import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receiptscanner/data/settings/settings_store.dart';

void main() {
  group('SettingsStore Tests', () {
    test('SettingsStore round trip persists language and theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SettingsStore.create();

      expect(store.getLanguage(), 'system');
      expect(store.getThemeMode(), 'system');

      await store.setLanguage('ko');
      expect(store.getLanguage(), 'ko');

      await store.setThemeMode('dark');
      expect(store.getThemeMode(), 'dark');
    });
  });
}
