import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bito_math/core/persistence/player_provider.dart';
import 'package:bito_math/core/services/visual_aids_provider.dart';

void main() {
  group('visualAidsEnabledProvider', () {
    test('defaults to enabled when no preference is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ]);
      addTearDown(container.dispose);

      expect(container.read(visualAidsEnabledProvider), isTrue);
    });

    test('respects a previously stored disabled preference', () async {
      SharedPreferences.setMockInitialValues({'visual_aids_enabled': false});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ]);
      addTearDown(container.dispose);

      expect(container.read(visualAidsEnabledProvider), isFalse);
    });

    test('setEnabled persists the new value', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ]);
      addTearDown(container.dispose);

      await container
          .read(visualAidsEnabledProvider.notifier)
          .setEnabled(false);

      expect(container.read(visualAidsEnabledProvider), isFalse);
      expect(prefs.getBool('visual_aids_enabled'), isFalse);
    });
  });
}
