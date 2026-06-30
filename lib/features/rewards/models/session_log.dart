class SessionLog {
  final String date; // 'yyyy-MM-dd'
  final int score;
  final int correctCount;
  final int totalAnswered;
  final int starsEarned; // = correctCount
  final int ageBand;
  final bool isPractice;

  const SessionLog({
    required this.date,
    required this.score,
    required this.correctCount,
    required this.totalAnswered,
    required this.starsEarned,
    required this.ageBand,
    required this.isPractice,
  });

  double get accuracy =>
      totalAnswered == 0 ? 0 : correctCount / totalAnswered;

  Map<String, dynamic> toJson() => {
        'date': date,
        'score': score,
        'correct': correctCount,
        'total': totalAnswered,
        'stars': starsEarned,
        'ageBand': ageBand,
        'practice': isPractice,
      };

  factory SessionLog.fromJson(Map<String, dynamic> j) => SessionLog(
        date: j['date'] as String,
        score: j['score'] as int,
        correctCount: j['correct'] as int,
        totalAnswered: j['total'] as int,
        starsEarned: j['stars'] as int,
        ageBand: j['ageBand'] as int,
        isPractice: j['practice'] as bool? ?? false,
      );
}
