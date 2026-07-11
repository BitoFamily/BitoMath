import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../persistence/player_provider.dart';
import '../theme/app_colors.dart';

enum AppThemeMode { classic, playground }

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_fromPrefs(_prefs));

  final SharedPreferences _prefs;

  static AppThemeMode _fromPrefs(SharedPreferences prefs) =>
      prefs.getString('theme_mode') == AppThemeMode.playground.name
          ? AppThemeMode.playground
          : AppThemeMode.classic;

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    await _prefs.setString('theme_mode', mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeModeNotifier(prefs);
});

final appPaletteProvider = Provider<AppPalette>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode == AppThemeMode.playground ? AppPalette.light : AppPalette.dark;
});
