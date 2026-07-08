import 'package:flutter_test/flutter_test.dart';
import 'package:bito_math/features/game/models/question_config.dart';
import 'package:bito_math/features/game/providers/question_generator.dart';

void main() {
  group('QuestionGenerator', () {
    const topicsByBand = {
      0: ['add', 'sub'],
      1: ['add', 'sub', 'mul'],
      2: ['add', 'sub', 'mul', 'div'],
    };

    for (final band in [0, 1, 2]) {
      for (final topic in topicsByBand[band]!) {
        test('produces a valid $topic question for band $band', () {
          final config = QuestionConfig(
            ageBand: band,
            enabledTopics: {topic},
            topicAccuracy: const {},
          );

          // Generate many questions to exercise the RNG across its range.
          for (var i = 0; i < 100; i++) {
            final q = QuestionGenerator.generate(config);

            expect(q.topic, topic);
            expect(q.choices, hasLength(4));
            expect(q.choices.toSet(), hasLength(4),
                reason: 'choices must not contain duplicates');
            expect(q.choices, contains(q.correctAnswer));

            switch (topic) {
              case 'add':
                final parts = q.problem.replaceAll('=', '').trim().split('+');
                final a = int.parse(parts[0].trim());
                final b = int.parse(parts[1].trim());
                expect(q.correctAnswer, a + b);
              case 'sub':
                final parts = q.problem.replaceAll('=', '').trim().split('−');
                final a = int.parse(parts[0].trim());
                final b = int.parse(parts[1].trim());
                expect(a, greaterThanOrEqualTo(b),
                    reason: 'subtraction must never go negative');
                expect(q.correctAnswer, a - b);
                expect(q.correctAnswer, greaterThanOrEqualTo(0));
              case 'mul':
                final parts = q.problem.replaceAll('=', '').trim().split('×');
                final a = int.parse(parts[0].trim());
                final b = int.parse(parts[1].trim());
                expect(q.correctAnswer, a * b);
              case 'div':
                final parts = q.problem.replaceAll('=', '').trim().split('÷');
                final dividend = int.parse(parts[0].trim());
                final divisor = int.parse(parts[1].trim());
                expect(dividend % divisor, 0,
                    reason: 'division questions must divide evenly');
                expect(q.correctAnswer, dividend ~/ divisor);
            }
          }
        });
      }
    }
  });
}
