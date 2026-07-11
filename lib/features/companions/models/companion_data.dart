import 'dart:math';
import 'package:flutter/widgets.dart';
import '../../../l10n/app_localizations.dart';

class CompanionData {
  final int index;
  final String emoji;
  final String name;
  final int unlockStars; // 0 = always available

  const CompanionData({
    required this.index,
    required this.emoji,
    required this.name,
    required this.unlockStars,
  });

  bool isUnlocked(int stars) => stars >= unlockStars;

  /// Each companion has a real quote pool per mood.
  String quote(BuildContext context, CompanionMood mood) {
    final l10n = AppLocalizations.of(context)!;
    final quotes = switch ((index, mood)) {
      (0, CompanionMood.neutral) => [
          l10n.cocoNeutral1,
          l10n.cocoNeutral2,
          l10n.cocoNeutral3
        ],
      (0, CompanionMood.celebrate) => [
          l10n.cocoCelebrate1,
          l10n.cocoCelebrate2,
          l10n.cocoCelebrate3,
        ],
      (0, CompanionMood.encourage) => [
          l10n.cocoEncourage1,
          l10n.cocoEncourage2,
          l10n.cocoEncourage3,
        ],
      (1, CompanionMood.neutral) => [
          l10n.katoNeutral1,
          l10n.katoNeutral2,
          l10n.katoNeutral3
        ],
      (1, CompanionMood.celebrate) => [
          l10n.katoCelebrate1,
          l10n.katoCelebrate2,
          l10n.katoCelebrate3,
        ],
      (1, CompanionMood.encourage) => [
          l10n.katoEncourage1,
          l10n.katoEncourage2,
          l10n.katoEncourage3,
        ],
      (2, CompanionMood.neutral) => [
          l10n.sonaNeutral1,
          l10n.sonaNeutral2,
          l10n.sonaNeutral3
        ],
      (2, CompanionMood.celebrate) => [
          l10n.sonaCelebrate1,
          l10n.sonaCelebrate2,
          l10n.sonaCelebrate3,
        ],
      (2, CompanionMood.encourage) => [
          l10n.sonaEncourage1,
          l10n.sonaEncourage2,
          l10n.sonaEncourage3,
        ],
      (_, _) => [l10n.companionComingSoonQuote],
    };
    return quotes[Random().nextInt(quotes.length)];
  }

  static const List<CompanionData> all = [
    // Coco — puppy-bot, MVP launch hero
    CompanionData(index: 0, emoji: '🐾', name: 'Coco', unlockStars: 0),
    // Kato — boy-bot, unlocks at Gold tier (500 stars)
    CompanionData(index: 1, emoji: '⚡', name: 'Kato', unlockStars: 500),
    // Sona — girl-bot, unlocks at Diamond tier (1500 stars)
    CompanionData(index: 2, emoji: '✨', name: 'Sona', unlockStars: 1500),
  ];
}

enum CompanionMood { neutral, celebrate, encourage }
