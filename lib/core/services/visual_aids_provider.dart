import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../persistence/player_provider.dart';

/// Parent-controlled toggle for Grade 1 (ageBand 0) visual aids — number
/// line / dot array shown below the problem during gameplay. Defaults on,
/// since the whole point is to help the youngest kids by default.
class VisualAidsNotifier extends StateNotifier<bool> {
  VisualAidsNotifier(this._prefs)
      : super(_prefs.getBool('visual_aids_enabled') ?? true);

  final SharedPreferences _prefs;

  Future<void> setEnabled(bool value) async {
    state = value;
    await _prefs.setBool('visual_aids_enabled', value);
  }
}

final visualAidsEnabledProvider =
    StateNotifierProvider<VisualAidsNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return VisualAidsNotifier(prefs);
});
