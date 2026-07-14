import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bito_math/core/persistence/player_provider.dart';
import 'package:bito_math/features/home/widgets/age_band_sheet.dart';
import 'package:bito_math/l10n/app_localizations.dart';

void main() {
  testWidgets('AgeBandSheet shows Level N title with age+description subtext',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AgeBandSheet.show(context, isPractice: true),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Level 3'), findsOneWidget);
    expect(find.textContaining('Grade'), findsNothing);
    expect(
      find.text('Counting, addition & subtraction up to 10 (age 5–6)'),
      findsOneWidget,
    );
    expect(
      find.text('Addition & subtraction up to 20 (age 6–7)'),
      findsOneWidget,
    );
    expect(
      find.text('Bigger numbers, intro to multiplication (age 7–8)'),
      findsOneWidget,
    );
  });
}
