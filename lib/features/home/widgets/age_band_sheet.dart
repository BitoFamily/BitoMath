import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';

class AgeBandSheet extends StatelessWidget {
  final bool isPractice;

  const AgeBandSheet({super.key, required this.isPractice});

  static Future<void> show(BuildContext context, {required bool isPractice}) async {
    final route = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.bgMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AgeBandSheet(isPractice: isPractice),
    );
    // Navigate from the caller's context after the sheet is closed
    if (context.mounted && route != null) {
      GoRouter.of(context).go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isPractice ? '🎯 Practice Mode' : '⚡ Quick Play',
            style: AppTextStyles.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Pick your age group',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...List.generate(AppConstants.ageBandLabels.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppButton.primary(
                label: AppConstants.ageBandLabels[i],
                onTap: () => Navigator.pop(
                  context,
                  isPractice ? '/practice/$i' : '/game/$i',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
