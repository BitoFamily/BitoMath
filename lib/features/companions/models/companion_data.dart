import 'dart:math';

class CompanionData {
  final int index;
  final String emoji;
  final String name;
  final int unlockStars; // 0 = always available

  final List<String> neutralQuotes;
  final List<String> celebrateQuotes;
  final List<String> encourageQuotes;

  const CompanionData({
    required this.index,
    required this.emoji,
    required this.name,
    required this.unlockStars,
    required this.neutralQuotes,
    required this.celebrateQuotes,
    required this.encourageQuotes,
  });

  bool isUnlocked(int stars) => stars >= unlockStars;

  String quote(CompanionMood mood) {
    final list = switch (mood) {
      CompanionMood.celebrate => celebrateQuotes,
      CompanionMood.encourage => encourageQuotes,
      CompanionMood.neutral => neutralQuotes,
    };
    return list[Random().nextInt(list.length)];
  }

  static const List<CompanionData> all = [
    // Coco — puppy-bot, MVP launch hero
    CompanionData(
      index: 0,
      emoji: '🐾',
      name: 'Coco',
      unlockStars: 0,
      neutralQuotes: [
        '"Ready for a challenge?"',
        '"Let\'s go — numbers are fun!"',
        '"Every question is a new adventure!"',
      ],
      celebrateQuotes: [
        '"Woof woof! You\'re amazing!"',
        '"That was PAWSOME! Keep it up!"',
        '"You\'re on fire — Coco believes in you!"',
      ],
      encourageQuotes: [
        '"Even puppies keep trying!"',
        '"A stumble is just a step forward!"',
        '"You\'ve got this — Coco is cheering for you!"',
      ],
    ),
    // Kato — boy-bot, teased for future release
    CompanionData(
      index: 1,
      emoji: '⚡',
      name: 'Kato',
      unlockStars: 9999,
      neutralQuotes: [
        '"Coming soon!"',
      ],
      celebrateQuotes: [
        '"Coming soon!"',
      ],
      encourageQuotes: [
        '"Coming soon!"',
      ],
    ),
    // Sona — girl-bot, teased for future release
    CompanionData(
      index: 2,
      emoji: '✨',
      name: 'Sona',
      unlockStars: 9999,
      neutralQuotes: [
        '"Coming soon!"',
      ],
      celebrateQuotes: [
        '"Coming soon!"',
      ],
      encourageQuotes: [
        '"Coming soon!"',
      ],
    ),
  ];
}

enum CompanionMood { neutral, celebrate, encourage }
