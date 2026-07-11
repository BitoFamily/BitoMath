import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Static number-line visual aid for addition/subtraction, Grade 1 (ageBand
/// 0) only. Shows tick marks 0..[maxValue], a hop arc from [start] to [end]
/// (backwards for subtraction), and markers at both ends. Pure CustomPainter
/// — no animation, per the "static widgets only" constraint.
class NumberLineVisualAid extends StatelessWidget {
  final int start;
  final int end;
  final int maxValue;

  const NumberLineVisualAid({
    super.key,
    required this.start,
    required this.end,
    this.maxValue = 15,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: CustomPaint(
        painter: _NumberLinePainter(
          start: start,
          end: end,
          maxValue: maxValue,
          trackColor: AppColors.bgCardLight,
          hopColor: AppColors.primaryLight,
          startColor: AppColors.accentCoral,
          endColor: AppColors.accentYellow,
          labelStyle: AppTextStyles.label.copyWith(fontSize: 9),
        ),
      ),
    );
  }
}

class _NumberLinePainter extends CustomPainter {
  final int start;
  final int end;
  final int maxValue;
  final Color trackColor;
  final Color hopColor;
  final Color startColor;
  final Color endColor;
  final TextStyle labelStyle;

  _NumberLinePainter({
    required this.start,
    required this.end,
    required this.maxValue,
    required this.trackColor,
    required this.hopColor,
    required this.startColor,
    required this.endColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const horizontalPadding = 10.0;
    final usableWidth = size.width - horizontalPadding * 2;
    final step = maxValue == 0 ? 0.0 : usableWidth / maxValue;
    final lineY = size.height * 0.45;

    double xFor(int n) => horizontalPadding + step * n;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(xFor(0), lineY), Offset(xFor(maxValue), lineY), trackPaint);

    final tickPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 2;
    for (var i = 0; i <= maxValue; i++) {
      canvas.drawLine(
        Offset(xFor(i), lineY - 4),
        Offset(xFor(i), lineY + 4),
        tickPaint,
      );
      final tp = TextPainter(
        text: TextSpan(text: '$i', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(xFor(i) - tp.width / 2, lineY + 8));
    }

    // Hop arcs between each consecutive integer from start to end.
    final lo = start < end ? start : end;
    final hi = start < end ? end : start;
    final arcPaint = Paint()
      ..color = hopColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (var i = lo; i < hi; i++) {
      final p1 = Offset(xFor(i), lineY);
      final p2 = Offset(xFor(i + 1), lineY);
      final apex = Offset((p1.dx + p2.dx) / 2, lineY - step.clamp(0, 22));
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(apex.dx, apex.dy, p2.dx, p2.dy);
      canvas.drawPath(path, arcPaint);
    }

    canvas.drawCircle(Offset(xFor(start), lineY), 5, Paint()..color = startColor);
    canvas.drawCircle(Offset(xFor(end), lineY), 6, Paint()..color = endColor);
  }

  @override
  bool shouldRepaint(_NumberLinePainter old) =>
      old.start != start || old.end != end || old.maxValue != maxValue;
}
