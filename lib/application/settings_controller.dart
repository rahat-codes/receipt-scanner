import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../data/settings/settings_store.dart';

class SettingsState {
  final String language;
  final String themeMode;
  final bool geminiFallback;

  const SettingsState({
    required this.language,
    required this.themeMode,
    required this.geminiFallback,
  });

  SettingsState copyWith({
    String? language,
    String? themeMode,
    bool? geminiFallback,
  }) {
    return SettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      geminiFallback: geminiFallback ?? this.geminiFallback,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  final SettingsStore store;

  SettingsController(this.store)
      : super(SettingsState(
          language: store.getLanguage(),
          themeMode: store.getThemeMode(),
          geminiFallback: store.getGeminiFallback(),
        ));

  Future<void> setLanguage(String lang) async {
    await store.setLanguage(lang);
    state = state.copyWith(language: lang);
  }

  Future<void> setThemeMode(String mode) async {
    await store.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setGeminiFallback(bool enabled) async {
    await store.setGeminiFallback(enabled);
    state = state.copyWith(geminiFallback: enabled);
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final store = ref.watch(settingsStoreProvider);
  return SettingsController(store);
});
