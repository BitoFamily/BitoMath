import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/reward.dart';
import '../providers/rewards_provider.dart';
import '../widgets/reward_progress_bar.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(playerProfileProvider);
    final rewards = ref.watch(rewardsProvider);
    final total = profile.stars;
    final available = rewards.availableStars(total);

    final ready = rewards.readyRewards(total);
    final upcoming = rewards.upcomingRewards(total);
    final redeemed = rewards.redeemedRewards;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textSecondary),
        title: Text(l10n.rewardsTitle, style: AppTextStyles.headline3),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _StarSummaryCard(total: total, available: available),
          const SizedBox(height: 24),
          if (rewards.rewards.isEmpty)
            _EmptyState(icon: '🎁', message: l10n.rewardsNoneConfigured)
          else ...[
            Text(l10n.rewardsReadySectionTitle, style: AppTextStyles.headline3),
            const SizedBox(height: 12),
            if (ready.isEmpty)
              _EmptyState(icon: '🎁', message: l10n.rewardsNoneReadyMessage)
            else
              ...ready.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReadyRewardRow(reward: r),
                  )),
            const SizedBox(height: 24),
            Text(l10n.rewardsUpcomingSectionTitle,
                style: AppTextStyles.headline3),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              _EmptyState(icon: '⭐', message: l10n.rewardsNoUpcomingMessage)
            else
              ...upcoming.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RewardProgressBar(reward: r, currentStars: available),
                  )),
            const SizedBox(height: 24),
            Text(l10n.rewardsHistorySectionTitle,
                style: AppTextStyles.headline3),
            const SizedBox(height: 12),
            if (redeemed.isEmpty)
              _EmptyState(icon: '✅', message: l10n.rewardsNoHistoryMessage)
            else
              ...redeemed.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RedeemedRewardRow(reward: r),
                  )),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Star summary ───────────────────────────────────────────────────────────

class _StarSummaryCard extends StatelessWidget {
  final int total;
  final int available;
  const _StarSummaryCard({required this.total, required this.available});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showSplit = available != total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.starsCount(total),
                  style: AppTextStyles.headline2
                      .copyWith(color: AppColors.accentYellow)),
              Text(l10n.totalEarnedLabel,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          if (showSplit)
            Text(l10n.availableStarsLabel(available),
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ── Ready to claim ─────────────────────────────────────────────────────────

class _ReadyRewardRow extends StatelessWidget {
  final Reward reward;
  const _ReadyRewardRow({required this.reward});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.accentYellow.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Text(reward.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.name, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(l10n.rewardsAskParentToRedeem,
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.accentYellow.withValues(alpha: 0.5)),
            ),
            child: Text(l10n.rewardReadyBadge,
                style:
                    AppTextStyles.label.copyWith(color: AppColors.accentYellow)),
          ),
        ],
      ),
    );
  }
}

// ── Redeemed history ────────────────────────────────────────────────────────

class _RedeemedRewardRow extends StatelessWidget {
  final Reward reward;
  const _RedeemedRewardRow({required this.reward});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Row(
        children: [
          Text(reward.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  style: AppTextStyles.body.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reward.redeemedAt != null
                      ? l10n.rewardsRedeemedOnLabel(reward.redeemedAt!)
                      : l10n.redeemedCheck,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.accentGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(message,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
