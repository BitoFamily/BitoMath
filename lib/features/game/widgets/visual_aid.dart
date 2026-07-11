import 'package:flutter/widgets.dart';
import '../models/question.dart';
import 'dot_array_visual_aid.dart';
import 'number_line_visual_aid.dart';

/// Picks the right visual aid for [question]'s topic. Number line for
/// add/sub, dot array for mul. No aid for div (or any future topic) — the
/// caller is expected to only show this for Grade 1 (ageBand 0), where the
/// question set is add/sub only today.
class VisualAid extends StatelessWidget {
  final Question question;
  const VisualAid({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    switch (question.topic) {
      case 'add':
      case 'sub':
        return NumberLineVisualAid(
          start: question.operandA,
          end: question.correctAnswer,
        );
      case 'mul':
        return DotArrayVisualAid(
          rows: question.operandA,
          cols: question.operandB,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
