import '../../../core/constants/app_constants.dart';
import 'question.dart';

enum GamePhase { playing, answering, finished }

class GameState {
  final GamePhase phase;
  final int ageBand;
  final bool isPractice;
  final int score;
  final int streak;
  final int bestStreak;
  final int correctCount;
  final int totalAnswered;
  final int secondsRemaining;
  final Question? currentQuestion;
  final int? selectedChoiceIndex;
  final bool? lastAnswerCorrect;
  final Map<String, int> correctPerTopic; // 'add'→5, 'sub'→3, …
  final Map<String, int> totalPerTopic;

  const GameState({
    required this.phase,
    required this.ageBand,
    required this.isPractice,
    required this.score,
    required this.streak,
    required this.bestStreak,
    required this.correctCount,
    required this.totalAnswered,
    required this.secondsRemaining,
    this.currentQuestion,
    this.selectedChoiceIndex,
    this.lastAnswerCorrect,
    this.correctPerTopic = const {},
    this.totalPerTopic = const {},
  });

  factory GameState.initial(int ageBand, bool isPractice) => GameState(
        phase: GamePhase.playing,
        ageBand: ageBand,
        isPractice: isPractice,
        score: 0,
        streak: 0,
        bestStreak: 0,
        correctCount: 0,
        totalAnswered: 0,
        secondsRemaining: AppConstants.defaultGameDurationSeconds,
      );

  GameState copyWith({
    GamePhase? phase,
    int? ageBand,
    bool? isPractice,
    int? score,
    int? streak,
    int? bestStreak,
    int? correctCount,
    int? totalAnswered,
    int? secondsRemaining,
    Question? currentQuestion,
    int? selectedChoiceIndex,
    bool? lastAnswerCorrect,
    Map<String, int>? correctPerTopic,
    Map<String, int>? totalPerTopic,
    bool clearSelection = false,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      ageBand: ageBand ?? this.ageBand,
      isPractice: isPractice ?? this.isPractice,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      correctCount: correctCount ?? this.correctCount,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      selectedChoiceIndex:
          clearSelection ? null : (selectedChoiceIndex ?? this.selectedChoiceIndex),
      lastAnswerCorrect:
          clearSelection ? null : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      correctPerTopic: correctPerTopic ?? this.correctPerTopic,
      totalPerTopic: totalPerTopic ?? this.totalPerTopic,
    );
  }

  int get starsEarned {
    if (score >= 150) return 3;
    if (score >= 80) return 2;
    if (score >= 30) return 1;
    return 0;
  }

  double get accuracy =>
      totalAnswered == 0 ? 0.0 : correctCount / totalAnswered;

  /// Per-topic accuracy map for this session (only topics with ≥1 answer)
  Map<String, double> get sessionTopicAccuracy {
    final result = <String, double>{};
    for (final topic in totalPerTopic.keys) {
      final total = totalPerTopic[topic]!;
      if (total > 0) {
        result[topic] = (correctPerTopic[topic] ?? 0) / total;
      }
    }
    return result;
  }
}
