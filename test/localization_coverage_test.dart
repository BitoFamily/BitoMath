import 'package:flutter_test/flutter_test.dart';
import 'package:bito_math/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations loads for every supported locale', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test('${locale.languageCode} loads and returns non-empty strings',
          () async {
        final l10n = await AppLocalizations.delegate.load(locale);

        // A sampling across the app — static strings, plurals, and a
        // parameterized string — to catch any missing/broken key.
        expect(l10n.settingsTitle, isNotEmpty);
        expect(l10n.playNowButton, isNotEmpty);
        expect(l10n.cocoCelebrate1, isNotEmpty);
        expect(l10n.katoEncourage2, isNotEmpty);
        expect(l10n.sonaNeutral3, isNotEmpty);
        expect(l10n.onboardingGreeting('Alex'), contains('Alex'));
        expect(l10n.rewardsReadyBadge(1), isNotEmpty);
        expect(l10n.rewardsReadyBadge(3), contains('3'));
        expect(l10n.starsProgress(2, 5), contains('2'));
        expect(l10n.starsProgress(2, 5), contains('5'));
      });
    }

    test('all 4 expected locales are registered', () {
      final codes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
      expect(codes, {'en', 'fr', 'hi', 'ar'});
    });
  });
}
