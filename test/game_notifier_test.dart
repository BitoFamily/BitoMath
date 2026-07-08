import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bito_math/features/game/models/game_state.dart';
import 'package:bito_math/features/game/models/question_config.dart';
import 'package:bito_math/features/game/providers/game_provider.dart';

GameNotifier _makeNotifier({required bool isPractice}) {
  final qConfig = QuestionConfig(
    ageBand: 1,
    enabledTopics: const {'add', 'sub'},
    topicAccuracy: const {},
  );
  return GameNotifier(
    (ageBand: 1, isPractice: isPractice, topics: 'add,sub'),
    qConfig,
  );
}

void main() {
  group('GameNotifier state machine', () {
    test('starts in the playing phase with a question ready', () {
      final notifier = _makeNotifier(isPractice: true);
      addTearDown(notifier.dispose);

      expect(notifier.state.phase, GamePhase.playing);
      expect(notifier.state.currentQuestion, isNotNull);
    });

    test('transitions playing -> answering -> playing on correct answer', () {
      fakeAsync((async) {
        final notifier = _makeNotifier(isPractice: true);
        addTearDown(notifier.dispose);

        final q = notifier.state.currentQuestion!;
        final correctIndex = q.choices.indexOf(q.correctAnswer);

        notifier.answerQuestion(correctIndex);
        expect(notifier.state.phase, GamePhase.answering);
        expect(notifier.state.lastAnswerCorrect, isTrue);
        expect(notifier.state.score, greaterThan(0));

        // The notifier waits ~650ms before advancing to the next question.
        async.elapse(const Duration(milliseconds: 700));
        expect(notifier.state.phase, GamePhase.playing);
        expect(notifier.state.currentQuestion, isNotNull);
      });
    });

    test('emits GamePhase.finished when the timer reaches zero', () {
      fakeAsync((async) {
        final notifier = _makeNotifier(isPractice: false);
        addTearDown(notifier.dispose);

        expect(notifier.state.phase, GamePhase.playing);

        async.elapse(const Duration(seconds: 60));
        expect(notifier.state.phase, GamePhase.finished);
      });
    });

    test('practice mode never starts a countdown timer', () {
      fakeAsync((async) {
        final notifier = _makeNotifier(isPractice: true);
        addTearDown(notifier.dispose);

        async.elapse(const Duration(seconds: 60));
        expect(notifier.state.phase, isNot(GamePhase.finished));
      });
    });
  });
}
