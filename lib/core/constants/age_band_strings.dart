import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Localized display strings for the three age bands ("Level 1/2/3"),
/// keyed by the same `ageBand` index used throughout the app.
class AgeBandStrings {
  static String name(BuildContext context, int ageBand) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.level1Name, l10n.level2Name, l10n.level3Name][ageBand];
  }

  static String ageRange(BuildContext context, int ageBand) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.level1AgeRange,
      l10n.level2AgeRange,
      l10n.level3AgeRange,
    ][ageBand];
  }

  static String description(BuildContext context, int ageBand) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.level1Description,
      l10n.level2Description,
      l10n.level3Description,
    ][ageBand];
  }

  /// The character carousel teaser quote: Coco (index 0) has a real quote,
  /// Kato/Sona (teased, not yet playable) share the "Coming soon!" placeholder.
  static String characterQuote(BuildContext context, int characterIndex) {
    final l10n = AppLocalizations.of(context)!;
    return characterIndex == 0
        ? l10n.cocoNeutral1
        : l10n.companionComingSoonQuote;
  }
}
