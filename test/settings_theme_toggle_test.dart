import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bito_math/core/persistence/player_provider.dart';
import 'package:bito_math/core/services/theme_mode_provider.dart';
import 'package:bito_math/core/theme/app_colors.dart';
import 'package:bito_math/core/theme/app_theme.dart';
import 'package:bito_math/features/settings/screens/settings_screen.dart';
import 'package:bito_math/l10n/app_localizations.dart';

void main() {
  testWidgets(
      'tapping Playground in Settings switches the live theme and persists it',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final app = ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: Consumer(builder: (context, ref, _) {
        final mode = ref.watch(themeModeProvider);
        return MaterialApp(
          theme: mode == AppThemeMode.playground
              ? AppTheme.light
              : AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        );
      }),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Defaults to classic (dark) — matches AppPalette.dark's background.
    Scaffold scaffold() => tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold().backgroundColor, AppPalette.dark.bgDeep);

    expect(find.text('Playground (light)'), findsOneWidget);
    await tester.tap(find.text('Playground (light)'));
    await tester.pumpAndSettle();

    // The whole live app re-themes immediately, not just the toggle row.
    expect(scaffold().backgroundColor, AppPalette.light.bgDeep);

    // Persisted: a fresh provider tree reading the same SharedPreferences
    // instance should come back up already in Playground mode.
    final freshPrefs = await SharedPreferences.getInstance();
    expect(freshPrefs.getString('theme_mode'), AppThemeMode.playground.name);
  });
}
