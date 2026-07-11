import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/reward.dart';

class RewardProgressBar extends ConsumerWidget {
  final Reward reward;
  final int currentStars;

  const RewardProgressBar({
    super.key,
    required this.reward,
    required this.currentStars,
  });

  double get _progress => (currentStars / reward.starCost).clamp(0.0, 1.0);

  bool get _achieved => currentStars >= reward.starCost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      accentColor: _achieved
          ? colors.accentYellow.withValues(alpha: 0.6)
          : colors.bgCardLight,
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
                  style: AppTextStyles.body(colors),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_achieved)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.accentYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: colors.accentYellow.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    l10n.rewardReadyBadge,
                    style: AppTextStyles.label(colors)
                        .copyWith(color: colors.accentYellow),
                  ),
                )
              else
                Text(
                  l10n.starsProgress(currentStars, reward.starCost),
                  style: AppTextStyles.label(colors)
                      .copyWith(color: colors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 7,
              backgroundColor: colors.bgCardLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                _achieved ? colors.accentYellow : colors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
