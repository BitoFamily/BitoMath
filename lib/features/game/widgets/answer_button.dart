import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/wiggle_animation.dart';

class AnswerButton extends ConsumerStatefulWidget {
  final int value;

  /// null = unanswered, true = this was the correct pick, false = wrong pick
  final bool? result;

  final bool enabled;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.value,
    required this.result,
    required this.enabled,
    this.onTap,
  });

  @override
  ConsumerState<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends ConsumerState<AnswerButton> {
  int _wiggleTrigger = 0;

  @override
  void didUpdateWidget(covariant AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Gentle wiggle instead of a harsh flash when this pick is revealed wrong.
    if (widget.result == false && oldWidget.result != false) {
      setState(() => _wiggleTrigger++);
    }
  }

  Color _bgColor(AppPalette c) => switch (widget.result) {
        true => c.accentGreen.withValues(alpha: 0.22),
        false => c.accentCoral.withValues(alpha: 0.22),
        _ => c.bgCard,
      };

  Color _borderColor(AppPalette c) => switch (widget.result) {
        true => c.accentGreen,
        false => c.accentCoral,
        _ => c.bgCardLight,
      };

  Color _textColor(AppPalette c) => switch (widget.result) {
        true => c.accentGreen,
        false => c.accentCoral,
        _ => c.textPrimary,
      };

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appPaletteProvider);
    final border = _borderColor(colors);
    return WiggleAnimation(
      trigger: _wiggleTrigger,
      child: GestureDetector(
        onTap: widget.enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onTap?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 72,
          decoration: BoxDecoration(
            color: _bgColor(colors),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 3),
            // Flat, non-blurry drop-shadow — matches AppCard's tactile look.
            boxShadow: widget.result == true
                ? [
                    BoxShadow(
                      color: border.withValues(alpha: 0.35),
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              '${widget.value}',
              style: AppTextStyles.gameAnswer(colors)
                  .copyWith(color: _textColor(colors)),
            ),
          ),
        ),
      ),
    );
  }
}
