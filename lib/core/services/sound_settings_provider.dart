import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../persistence/player_provider.dart';
import 'sound_service.dart';

class SoundSettingsNotifier extends StateNotifier<bool> {
  SoundSettingsNotifier(this._prefs) : super(_prefs.getBool('sound_enabled') ?? true) {
    SoundService.instance.enabled = state;
  }

  final SharedPreferences _prefs;

  Future<void> setEnabled(bool value) async {
    state = value;
    SoundService.instance.enabled = value;
    await _prefs.setBool('sound_enabled', value);
  }
}

final soundSettingsProvider =
    StateNotifierProvider<SoundSettingsNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SoundSettingsNotifier(prefs);
});
