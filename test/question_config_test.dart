import 'package:flutter_test/flutter_test.dart';
import 'package:bito_math/features/game/models/question_config.dart';

void main() {
  group('QuestionConfig.adaptLevel', () {
    test('returns easier tier (0) at 0.55 accuracy', () {
      final config = QuestionConfig(
        ageBand: 1,
        enabledTopics: const {'add'},
        topicAccuracy: const {'add': 0.55},
      );
      expect(config.adaptLevel('add'), 0);
    });

    test('returns normal tier (1) at 0.72 accuracy', () {
      final config = QuestionConfig(
        ageBand: 1,
        enabledTopics: const {'add'},
        topicAccuracy: const {'add': 0.72},
      );
      expect(config.adaptLevel('add'), 1);
    });

    test('returns harder tier (2) at 0.90 accuracy', () {
      final config = QuestionConfig(
        ageBand: 1,
        enabledTopics: const {'add'},
        topicAccuracy: const {'add': 0.90},
      );
      expect(config.adaptLevel('add'), 2);
    });

    test('returns normal tier (1) when no accuracy is stored yet', () {
      final config = QuestionConfig(
        ageBand: 1,
        enabledTopics: const {'add'},
        topicAccuracy: const {},
      );
      expect(config.adaptLevel('add'), 1);
    });
  });

  group('QuestionConfig.available', () {
    test('band 0 only ever allows add/sub, even if more are enabled', () {
      final config = QuestionConfig(
        ageBand: 0,
        enabledTopics: const {'add', 'sub', 'mul', 'div'},
        topicAccuracy: const {},
      );
      expect(config.available.toSet(), {'add', 'sub'});
    });

    test('falls back to the full band-appropriate set if nothing is enabled',
        () {
      final config = QuestionConfig(
        ageBand: 1,
        enabledTopics: const {},
        topicAccuracy: const {},
      );
      expect(config.available.toSet(), {'add', 'sub', 'mul'});
    });
  });
}
