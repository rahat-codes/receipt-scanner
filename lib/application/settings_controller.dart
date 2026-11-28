import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../data/settings/settings_store.dart';

class SettingsState {
  final String language;
  final String themeMode;
  final bool geminiFallback;
  final bool aiConsent;
  final bool aiAssistantEnabled;

  const SettingsState({
    required this.language,
    required this.themeMode,
    required this.geminiFallback,
    required this.aiConsent,
    required this.aiAssistantEnabled,
  });

  SettingsState copyWith({
    String? language,
    String? themeMode,
    bool? geminiFallback,
    bool? aiConsent,
    bool? aiAssistantEnabled,
  }) {
    return SettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      geminiFallback: geminiFallback ?? this.geminiFallback,
      aiConsent: aiConsent ?? this.aiConsent,
      aiAssistantEnabled: aiAssistantEnabled ?? this.aiAssistantEnabled,
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
          aiConsent: store.getAiConsent(),
          aiAssistantEnabled: store.getAiAssistantEnabled(),
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

  Future<void> setAiConsent(bool enabled) async {
    await store.setAiConsent(enabled);
    state = state.copyWith(aiConsent: enabled);
  }

  Future<void> setAiAssistantEnabled(bool enabled) async {
    await store.setAiAssistantEnabled(enabled);
    state = state.copyWith(aiAssistantEnabled: enabled);
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final store = ref.watch(settingsStoreProvider);
  return SettingsController(store);
});
