import 'dart:math';
import '../models/question.dart';
import '../models/question_config.dart';

class QuestionGenerator {
  static final Random _rng = Random();

  static Question generate(QuestionConfig config) {
    final topics = config.available;
    final topic = topics[_rng.nextInt(topics.length)];
    final level = config.adaptLevel(topic);

    if (topic == 'add') return _addition(config.ageBand, level);
    if (topic == 'sub') return _subtraction(config.ageBand, level);
    if (topic == 'mul') return _multiplication(config.ageBand, level);
    return _division(config.ageBand, level);
  }

  // ── Addition ──────────────────────────────────────────────────────────────

  static Question _addition(int band, int level) {
    final max = _addMax(band, level);
    final a = _rng.nextInt(max) + 1;
    final b = _rng.nextInt(max) + 1;
    final answer = a + b;
    return Question(
      problem: '$a + $b =',
      correctAnswer: answer,
      choices: _choices(answer, min: 1, max: max * 2),
      topic: 'add',
    );
  }

  static int _addMax(int band, int level) {
    const table = [
      [5, 10, 15],   // band 0
      [15, 20, 30],  // band 1
      [30, 50, 75],  // band 2
    ];
    return table[band][level];
  }

  // ── Subtraction ───────────────────────────────────────────────────────────

  static Question _subtraction(int band, int level) {
    final max = _addMax(band, level); // reuse same ranges
    final b = _rng.nextInt(max - 1) + 1;
    final a = b + _rng.nextInt(max); // a ≥ b, always non-negative result
    final answer = a - b;
    return Question(
      problem: '$a − $b =',
      correctAnswer: answer,
      choices: _choices(answer, min: 0, max: max * 2 - 1),
      topic: 'sub',
    );
  }

  // ── Multiplication ────────────────────────────────────────────────────────

  static Question _multiplication(int band, int level) {
    final maxA = _mulMaxA(band, level);
    final maxB = _mulMaxB(band, level);
    final a = _rng.nextInt(maxA) + 1;
    final b = _rng.nextInt(maxB) + 1;
    final answer = a * b;
    return Question(
      problem: '$a × $b =',
      correctAnswer: answer,
      choices: _choices(answer, min: 1, max: maxA * maxB),
      topic: 'mul',
    );
  }

  static int _mulMaxA(int band, int level) {
    const table = [
      [5, 8, 10],   // band 1 (no mul at band 0)
      [5, 8, 10],
      [8, 10, 12],  // band 2
    ];
    return table[band.clamp(1, 2)][level];
  }

  static int _mulMaxB(int band, int level) {
    const table = [
      [3, 5, 7],
      [3, 5, 7],
      [5, 9, 12],
    ];
    return table[band.clamp(1, 2)][level];
  }

  // ── Division ──────────────────────────────────────────────────────────────

  static Question _division(int band, int level) {
    final maxDivisor = _divMax(level);
    final divisor = _rng.nextInt(maxDivisor - 1) + 2; // 2..maxDivisor
    final quotient = _rng.nextInt(12) + 1; // 1..12
    final dividend = divisor * quotient;
    return Question(
      problem: '$dividend ÷ $divisor =',
      correctAnswer: quotient,
      choices: _choices(quotient, min: 1, max: 12),
      topic: 'div',
    );
  }

  static int _divMax(int level) => [6, 9, 12][level];

  // ── Distractor choices ────────────────────────────────────────────────────

  static List<int> _choices(int correct, {required int min, required int max}) {
    final Set<int> chosen = {correct};
    int attempts = 0;
    while (chosen.length < 4 && attempts < 200) {
      attempts++;
      final distance = _rng.nextInt(5) + 1;
      final candidate = correct + (_rng.nextBool() ? distance : -distance);
      if (candidate >= min && candidate <= max) chosen.add(candidate);
    }
    int fill = min;
    while (chosen.length < 4) {
      if (!chosen.contains(fill)) chosen.add(fill);
      fill++;
    }
    return chosen.toList()..shuffle(_rng);
  }
}
