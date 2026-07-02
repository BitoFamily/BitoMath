class AppConstants {
  static const String appName = 'Bito Math';

  // Age bands — Levels 1–3 (Ages 5–8)
  // "Level" instead of "Grade" is school-system-agnostic, which matters once
  // the app is localized into markets with different grade conventions.
  static const int ageBandLevel1 = 0;
  static const int ageBandLevel2 = 1;
  static const int ageBandLevel3 = 2;
  static const int ageBandCount = 3;

  // Localized display strings for age bands live in AgeBandStrings
  // (lib/core/constants/age_band_strings.dart) since they depend on BuildContext.

  // Game defaults
  static const int defaultGameDurationSeconds = 60;
  static const int questionsPerRound = 20;
  static const int pointsPerCorrect = 10;
  static const int bonusStreakThreshold = 5;

  // XP / Reward thresholds
  static const int starsForBronze = 50;
  static const int starsForSilver = 200;
  static const int starsForGold = 500;
  static const int starsForDiamond = 1500;

  // Bito character roster — Coco (hero), Kato & Sona (teased)
  static const List<String> characterImages = [
    'assets/images/coco.png',
    'assets/images/kato.png',
    'assets/images/sona.png',
  ];
  static const List<String> characterNames = ['Coco', 'Kato', 'Sona'];
  // Localized teaser quote for the carousel lives in AgeBandStrings.characterQuote
  // (Coco's real quote, or the "Coming soon!" placeholder for Kato/Sona).

  // Reward emoji icons used across the UI
  static const String iconStar = '⭐';
  static const String iconStreak = '🔥';
  static const String iconTrophy = '🏆';
  static const String iconGem = '💎';
  static const String iconCoin = '🪙';
  static const String iconCorrect = '✅';
  static const String iconWrong = '❌';
  static const String iconShield = '🛡️';
}
