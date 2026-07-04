import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../persistence/player_provider.dart';

/// `null` means "follow the device's system locale".
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._prefs)
      : super(_prefs.getString('locale_code') == null
            ? null
            : Locale(_prefs.getString('locale_code')!));

  final SharedPreferences _prefs;

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove('locale_code');
    } else {
      await _prefs.setString('locale_code', locale.languageCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LocaleNotifier(prefs);
});
