import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TimerRing extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final double size;

  const TimerRing({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    this.size = 80,
  });

  double get _progress =>
      totalSeconds == 0 ? 0.0 : (secondsRemaining / totalSeconds).clamp(0.0, 1.0);

  Color get _color {
    if (_progress > 0.5) return AppColors.accentGreen;
    if (_progress > 0.25) return AppColors.warning;
    return AppColors.accentCoral;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(progress: _progress, color: _color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$secondsRemaining',
                style: AppTextStyles.headline3.copyWith(color: _color),
              ),
              Text(
                'sec',
                style: AppTextStyles.label.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 10) / 2;

    final trackPaint = Paint()
      ..color = AppColors.bgCardLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start at 12 o'clock
      2 * pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
