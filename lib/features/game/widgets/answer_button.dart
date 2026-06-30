import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AnswerButton extends StatelessWidget {
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

  Color get _bgColor => switch (result) {
        true => AppColors.accentGreen.withOpacity(0.22),
        false => AppColors.accentCoral.withOpacity(0.22),
        _ => AppColors.bgCard,
      };

  Color get _borderColor => switch (result) {
        true => AppColors.accentGreen,
        false => AppColors.accentCoral,
        _ => AppColors.bgCardLight,
      };

  Color get _textColor => switch (result) {
        true => AppColors.accentGreen,
        false => AppColors.accentCoral,
        _ => AppColors.textPrimary,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () {
        HapticFeedback.lightImpact();
        onTap?.call();
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 72,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 2),
          boxShadow: result == true
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            '$value',
            style: AppTextStyles.gameAnswer.copyWith(color: _textColor),
          ),
        ),
      ),
    );
  }
}
