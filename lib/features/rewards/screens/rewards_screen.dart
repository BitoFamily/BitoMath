import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/reward.dart';
import '../providers/rewards_provider.dart';
import '../widgets/reward_progress_bar.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(playerProfileProvider);
    final rewards = ref.watch(rewardsProvider);
    final total = profile.stars;
    final available = rewards.availableStars(total);

    final ready = rewards.readyRewards(total);
    final upcoming = rewards.upcomingRewards(total);
    final redeemed = rewards.redeemedRewards;

    return Scaffold(
      backgroundColor: colors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textSecondary),
        title: Text(l10n.rewardsTitle, style: AppTextStyles.headline3(colors)),
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
            Text(l10n.rewardsReadySectionTitle,
                style: AppTextStyles.headline3(colors)),
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
                style: AppTextStyles.headline3(colors)),
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
                style: AppTextStyles.headline3(colors)),
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

class _StarSummaryCard extends ConsumerWidget {
  final int total;
  final int available;
  const _StarSummaryCard({required this.total, required this.available});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final showSplit = available != total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: colors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.starsCount(total),
                  style: AppTextStyles.headline2(colors)
                      .copyWith(color: colors.accentYellow)),
              Text(l10n.totalEarnedLabel,
                  style: AppTextStyles.label(colors)
                      .copyWith(color: colors.textSecondary)),
            ],
          ),
          const Spacer(),
          if (showSplit)
            Text(l10n.availableStarsLabel(available),
                style: AppTextStyles.body(colors)
                    .copyWith(color: colors.textPrimary)),
        ],
      ),
    );
  }
}

// ── Ready to claim ─────────────────────────────────────────────────────────

class _ReadyRewardRow extends ConsumerWidget {
  final Reward reward;
  const _ReadyRewardRow({required this.reward});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      accentColor: colors.accentYellow.withValues(alpha: 0.5),
      child: Row(
        children: [
          Text(reward.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.name, style: AppTextStyles.body(colors)),
                const SizedBox(height: 2),
                Text(l10n.rewardsAskParentToRedeem,
                    style: AppTextStyles.label(colors)
                        .copyWith(color: colors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.accentYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: colors.accentYellow.withValues(alpha: 0.5)),
            ),
            child: Text(l10n.rewardReadyBadge,
                style: AppTextStyles.label(colors)
                    .copyWith(color: colors.accentYellow)),
          ),
        ],
      ),
    );
  }
}

// ── Redeemed history ────────────────────────────────────────────────────────

class _RedeemedRewardRow extends ConsumerWidget {
  final Reward reward;
  const _RedeemedRewardRow({required this.reward});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colors.bgCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.bgCardLight),
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
                  style: AppTextStyles.body(colors).copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reward.redeemedAt != null
                      ? l10n.rewardsRedeemedOnLabel(reward.redeemedAt!)
                      : l10n.redeemedCheck,
                  style: AppTextStyles.label(colors)
                      .copyWith(color: colors.accentGreen),
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

class _EmptyState extends ConsumerWidget {
  final String icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(message,
              style: AppTextStyles.body(colors).copyWith(color: colors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
