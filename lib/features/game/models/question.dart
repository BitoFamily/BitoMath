class Question {
  final String problem;
  final int correctAnswer;
  final List<int> choices; // 4 items, shuffled, includes correctAnswer
  final String topic; // 'add' | 'sub' | 'mul' | 'div'

  const Question({
    required this.problem,
    required this.correctAnswer,
    required this.choices,
    required this.topic,
  });
}
