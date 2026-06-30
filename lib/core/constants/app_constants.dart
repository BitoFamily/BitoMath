class AppConstants {
  static const String appName = 'Bito Math';
  static const String appTagline = 'Learn, earn, reward!';

  // Age bands — Grades 1–3 (Ages 5–8)
  static const int ageBandGrade1 = 0;
  static const int ageBandGrade2 = 1;
  static const int ageBandGrade3 = 2;

  static const List<String> ageBandLabels = ['Grade 1 (Age 5–6)', 'Grade 2 (Age 6–7)', 'Grade 3 (Age 7–8)'];

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
  static const List<String> characterQuotes = [
    '"Ready for a challenge?"',
    '"Coming soon!"',
    '"Coming soon!"',
  ];

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
