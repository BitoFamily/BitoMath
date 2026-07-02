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

  /// Coco (index 0) has real quotes per mood; Kato/Sona (teased, not yet
  /// playable) share the "Coming soon!" placeholder.
  String quote(BuildContext context, CompanionMood mood) {
    final l10n = AppLocalizations.of(context)!;
    if (index != 0) return l10n.companionComingSoonQuote;
    final quotes = switch (mood) {
      CompanionMood.neutral => [
          l10n.cocoNeutral1,
          l10n.cocoNeutral2,
          l10n.cocoNeutral3
        ],
      CompanionMood.celebrate => [
          l10n.cocoCelebrate1,
          l10n.cocoCelebrate2,
          l10n.cocoCelebrate3,
        ],
      CompanionMood.encourage => [
          l10n.cocoEncourage1,
          l10n.cocoEncourage2,
          l10n.cocoEncourage3,
        ],
    };
    return quotes[Random().nextInt(quotes.length)];
  }

  static const List<CompanionData> all = [
    // Coco — puppy-bot, MVP launch hero
    CompanionData(index: 0, emoji: '🐾', name: 'Coco', unlockStars: 0),
    // Kato — boy-bot, teased for future release
    CompanionData(index: 1, emoji: '⚡', name: 'Kato', unlockStars: 9999),
    // Sona — girl-bot, teased for future release
    CompanionData(index: 2, emoji: '✨', name: 'Sona', unlockStars: 9999),
  ];
}

enum CompanionMood { neutral, celebrate, encourage }
