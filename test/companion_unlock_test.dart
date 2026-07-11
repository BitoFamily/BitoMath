import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bito_math/core/constants/app_constants.dart';
import 'package:bito_math/core/persistence/player_provider.dart';
import 'package:bito_math/features/companions/models/companion_data.dart';
import 'package:bito_math/l10n/app_localizations.dart';
import 'package:bito_math/shared/widgets/character_display.dart';

void main() {
  group('Companion unlock thresholds', () {
    test('Kato unlocks at 500 stars (Gold tier)', () {
      final kato = CompanionData.all[1];
      expect(kato.unlockStars, 500);
      expect(kato.isUnlocked(499), isFalse);
      expect(kato.isUnlocked(500), isTrue);
    });

    test('Sona unlocks at 1500 stars (Diamond tier)', () {
      final sona = CompanionData.all[2];
      expect(sona.unlockStars, 1500);
      expect(sona.isUnlocked(1499), isFalse);
      expect(sona.isUnlocked(1500), isTrue);
    });
  });

  group('Companion quote pools', () {
    testWidgets('Kato and Sona each have real (non-placeholder) quotes',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        }),
      ));
      await tester.pump();

      final l10n = AppLocalizations.of(ctx)!;
      for (final mood in CompanionMood.values) {
        final katoQuote = CompanionData.all[1].quote(ctx, mood);
        final sonaQuote = CompanionData.all[2].quote(ctx, mood);
        expect(katoQuote, isNot(l10n.companionComingSoonQuote));
        expect(sonaQuote, isNot(l10n.companionComingSoonQuote));
      }
    });
  });

  group('Companion artwork renders', () {
    testWidgets('kato.png renders without error via CharacterDisplay',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          home: CharacterDisplay(
            imagePath: 'assets/images/kato.png',
            name: 'Kato',
            quote: 'test',
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('sona.png renders without error via CharacterDisplay',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          home: CharacterDisplay(
            imagePath: 'assets/images/sona.png',
            name: 'Sona',
            quote: 'test',
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsOneWidget);
    });

    test('characterImages paths match CompanionData order', () {
      expect(AppConstants.characterImages[1], 'assets/images/kato.png');
      expect(AppConstants.characterImages[2], 'assets/images/sona.png');
    });
  });
}
