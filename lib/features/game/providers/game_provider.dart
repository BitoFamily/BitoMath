import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/persistence/player_provider.dart';
import '../models/game_state.dart';
import '../models/question_config.dart';
import 'question_generator.dart';

// topics is a sorted, comma-joined string so record equality works correctly
typedef GameConfig = ({int ageBand, bool isPractice, String topics});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(GameConfig config, QuestionConfig questionConfig)
      : _qConfig = questionConfig,
        super(GameState.initial(config.ageBand, config.isPractice)) {
    _nextQuestion();
    if (!config.isPractice) _startTimer();
  }

  final QuestionConfig _qConfig;
  Timer? _gameTimer;
  Timer? _feedbackTimer;

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.secondsRemaining - 1;
      if (remaining <= 0) {
        _endGame();
      } else {
        state = state.copyWith(secondsRemaining: remaining);
      }
    });
  }

  void _nextQuestion() {
    state = state.copyWith(
      phase: GamePhase.playing,
      currentQuestion: QuestionGenerator.generate(_qConfig),
      clearSelection: true,
    );
  }

  void answerQuestion(int choiceIndex) {
    if (state.phase != GamePhase.playing) return;
    final q = state.currentQuestion!;
    final selected = q.choices[choiceIndex];
    final correct = selected == q.correctAnswer;
    final topic = q.topic;

    int newScore = state.score;
    int newStreak = state.streak;
    int newBestStreak = state.bestStreak;

    if (correct) {
      newStreak = state.streak + 1;
      newBestStreak =
          newStreak > state.bestStreak ? newStreak : state.bestStreak;
      newScore = state.score + AppConstants.pointsPerCorrect;
      if (newStreak % AppConstants.bonusStreakThreshold == 0) {
        newScore += 5;
      }
    } else {
      newStreak = 0;
    }

    // Per-topic tracking
    final newCorrectPerTopic = Map<String, int>.from(state.correctPerTopic);
    final newTotalPerTopic = Map<String, int>.from(state.totalPerTopic);
    newTotalPerTopic[topic] = (newTotalPerTopic[topic] ?? 0) + 1;
    if (correct) {
      newCorrectPerTopic[topic] = (newCorrectPerTopic[topic] ?? 0) + 1;
    }

    state = state.copyWith(
      phase: GamePhase.answering,
      selectedChoiceIndex: choiceIndex,
      lastAnswerCorrect: correct,
      score: newScore,
      streak: newStreak,
      bestStreak: newBestStreak,
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
      totalAnswered: state.totalAnswered + 1,
      correctPerTopic: newCorrectPerTopic,
      totalPerTopic: newTotalPerTopic,
    );

    _feedbackTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) _nextQuestion();
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _feedbackTimer?.cancel();
    state = state.copyWith(phase: GamePhase.finished);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider.autoDispose
    .family<GameNotifier, GameState, GameConfig>((ref, config) {
  final profile = ref.read(playerProfileProvider);
  final qConfig = QuestionConfig(
    ageBand: config.ageBand,
    enabledTopics: profile.enabledTopics,
    topicAccuracy: profile.topicAccuracy,
  );
  return GameNotifier(config, qConfig);
});
