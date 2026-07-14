import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class TimerRing extends ConsumerWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final double size;

  const TimerRing({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    this.size = 80,
  });

  double get _progress => totalSeconds == 0
      ? 0.0
      : (secondsRemaining / totalSeconds).clamp(0.0, 1.0);

  Color _color(AppPalette c) =>
      secondsRemaining < 5 ? c.warning : c.timerCool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final color = _color(colors);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: _progress,
              color: color,
              trackColor: colors.bgCardLight,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$secondsRemaining',
                style: AppTextStyles.headline3(colors).copyWith(color: color),
              ),
              Text(
                AppLocalizations.of(context)!.secondsLabel,
                style: AppTextStyles.label(colors).copyWith(fontSize: 11),
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
  final Color trackColor;

  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 10) / 2;

    final trackPaint = Paint()
      ..color = trackColor
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
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
