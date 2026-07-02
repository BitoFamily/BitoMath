import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/reward.dart';

class RewardProgressBar extends StatelessWidget {
  final Reward reward;
  final int currentStars;

  const RewardProgressBar({
    super.key,
    required this.reward,
    required this.currentStars,
  });

  double get _progress =>
      (currentStars / reward.starCost).clamp(0.0, 1.0);

  bool get _achieved => currentStars >= reward.starCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _achieved
              ? AppColors.accentYellow.withValues(alpha: 0.6)
              : AppColors.bgCardLight,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reward.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reward.name,
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_achieved)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.accentYellow.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Ready! 🎉',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.accentYellow),
                  ),
                )
              else
                Text(
                  '$currentStars/${reward.starCost} ⭐',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 7,
              backgroundColor: AppColors.bgCardLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                _achieved ? AppColors.accentYellow : AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
