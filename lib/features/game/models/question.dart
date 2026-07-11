class Question {
  final String problem;
  final int correctAnswer;
  final List<int> choices; // 4 items, shuffled, includes correctAnswer
  final String topic; // 'add' | 'sub' | 'mul' | 'div'

  // Raw operands as printed in [problem] (dividend/divisor for division),
  // kept alongside the formatted string so visual aids (number line, dot
  // array) can render them without re-parsing problem text.
  final int operandA;
  final int operandB;

  const Question({
    required this.problem,
    required this.correctAnswer,
    required this.choices,
    required this.topic,
    required this.operandA,
    required this.operandB,
  });
}
