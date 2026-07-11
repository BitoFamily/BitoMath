import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bito_math/features/game/models/question.dart';
import 'package:bito_math/features/game/providers/question_generator.dart';
import 'package:bito_math/features/game/models/question_config.dart';
import 'package:bito_math/features/game/widgets/dot_array_visual_aid.dart';
import 'package:bito_math/features/game/widgets/number_line_visual_aid.dart';
import 'package:bito_math/features/game/widgets/visual_aid.dart';

void main() {
  group('QuestionGenerator operand plumbing', () {
    test('addition question exposes operandA + operandB summing to the answer', () {
      final config = QuestionConfig(
        ageBand: 0,
        enabledTopics: const {'add'},
        topicAccuracy: const {},
      );
      for (var i = 0; i < 50; i++) {
        final q = QuestionGenerator.generate(config);
        expect(q.operandA + q.operandB, q.correctAnswer);
      }
    });

    test('subtraction question exposes operandA - operandB = answer', () {
      final config = QuestionConfig(
        ageBand: 0,
        enabledTopics: const {'sub'},
        topicAccuracy: const {},
      );
      for (var i = 0; i < 50; i++) {
        final q = QuestionGenerator.generate(config);
        expect(q.operandA - q.operandB, q.correctAnswer);
      }
    });

    test('multiplication question exposes operandA x operandB = answer', () {
      final config = QuestionConfig(
        ageBand: 1,
        enabledTopics: const {'mul'},
        topicAccuracy: const {},
      );
      for (var i = 0; i < 50; i++) {
        final q = QuestionGenerator.generate(config);
        expect(q.operandA * q.operandB, q.correctAnswer);
      }
    });
  });

  group('VisualAid dispatch', () {
    testWidgets('renders NumberLineVisualAid for add', (tester) async {
      const q = Question(
        problem: '3 + 4 =',
        correctAnswer: 7,
        choices: [5, 6, 7, 8],
        topic: 'add',
        operandA: 3,
        operandB: 4,
      );
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: VisualAid(question: q))));
      expect(find.byType(NumberLineVisualAid), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders NumberLineVisualAid for sub', (tester) async {
      const q = Question(
        problem: '9 − 4 =',
        correctAnswer: 5,
        choices: [3, 4, 5, 6],
        topic: 'sub',
        operandA: 9,
        operandB: 4,
      );
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: VisualAid(question: q))));
      expect(find.byType(NumberLineVisualAid), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders DotArrayVisualAid with rows x cols dots for mul',
        (tester) async {
      const q = Question(
        problem: '3 × 4 =',
        correctAnswer: 12,
        choices: [10, 11, 12, 13],
        topic: 'mul',
        operandA: 3,
        operandB: 4,
      );
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: VisualAid(question: q))));
      expect(find.byType(DotArrayVisualAid), findsOneWidget);
      expect(tester.takeException(), isNull);

      final dotArray = tester.widget<DotArrayVisualAid>(
          find.byType(DotArrayVisualAid));
      expect(dotArray.rows, 3);
      expect(dotArray.cols, 4);
    });

    testWidgets('renders nothing for div', (tester) async {
      const q = Question(
        problem: '12 ÷ 4 =',
        correctAnswer: 3,
        choices: [2, 3, 4, 5],
        topic: 'div',
        operandA: 12,
        operandB: 4,
      );
      await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: VisualAid(question: q))));
      expect(find.byType(NumberLineVisualAid), findsNothing);
      expect(find.byType(DotArrayVisualAid), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
