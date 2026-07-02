import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/persistence/player_profile.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/reward.dart';
import '../providers/rewards_provider.dart';
import '../widgets/create_reward_sheet.dart';
import 'pin_screen.dart';

// Entry gate: shows PIN screen first, then ParentZoneScreen
class ParentGateScreen extends ConsumerStatefulWidget {
  const ParentGateScreen({super.key});

  @override
  ConsumerState<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends ConsumerState<ParentGateScreen> {
  bool _verified = false;

  @override
  Widget build(BuildContext context) {
    final pin = ref.watch(rewardsProvider).pin;

    if (!_verified) {
      return PinScreen(
        mode: pin.isEmpty ? PinMode.create : PinMode.verify,
        onSuccess: () => setState(() => _verified = true),
      );
    }

    return const _ParentZone();
  }
}

// ── Actual parent zone ─────────────────────────────────────────────────────

class _ParentZone extends ConsumerWidget {
  const _ParentZone();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textSecondary),
        title: Text('Parent Zone', style: AppTextStyles.headline3),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _StarSummary(profile: profile, rewards: rewards),
          const SizedBox(height: 20),
          _RewardsSection(rewards: rewards, profile: profile),
          const SizedBox(height: 20),
          _TopicSection(profile: profile),
          const SizedBox(height: 20),
          _SessionSection(logs: rewards.sessionLogs),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Star summary ───────────────────────────────────────────────────────────

class _StarSummary extends StatelessWidget {
  final PlayerProfile profile;
  final RewardsState rewards;
  const _StarSummary({required this.profile, required this.rewards});

  @override
  Widget build(BuildContext context) {
    final total = profile.stars;
    final available = rewards.availableStars(total);
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
              Text(profile.name.isNotEmpty ? profile.name : 'Champion',
                  style: AppTextStyles.headline3),
              const SizedBox(height: 4),
              Text(AppConstants.ageBandLabels[profile.ageBand],
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$total ⭐',
                  style: AppTextStyles.headline2
                      .copyWith(color: AppColors.accentYellow)),
              Text('Total earned',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary)),
              if (showSplit) ...[
                const SizedBox(height: 4),
                Text('$available ⭐ available',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textPrimary)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Rewards section ────────────────────────────────────────────────────────

class _RewardsSection extends ConsumerWidget {
  final RewardsState rewards;
  final PlayerProfile profile;

  const _RewardsSection({required this.rewards, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rewards', style: AppTextStyles.headline3),
            if (rewards.rewards.length < 5)
              GestureDetector(
                onTap: () => CreateRewardSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
                  ),
                  child: Text('+ Add',
                      style:
                          AppTextStyles.label.copyWith(color: AppColors.primaryLight)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (rewards.rewards.isEmpty)
          const _EmptyState(
            icon: '🎁',
            message: 'No rewards yet.\nTap "+ Add" to create the first one!',
          )
        else ...[
          ...rewards.rewards.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RewardRow(
                  reward: r,
                  availableStars: rewards.availableStars(profile.stars),
                  onRedeem: () =>
                      ref.read(rewardsProvider.notifier).redeemReward(r.id),
                  onDelete: () =>
                      ref.read(rewardsProvider.notifier).deleteReward(r.id),
                ),
              )),
        ],
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  final Reward reward;
  final int availableStars;
  final VoidCallback onRedeem;
  final VoidCallback onDelete;

  const _RewardRow({
    required this.reward,
    required this.availableStars,
    required this.onRedeem,
    required this.onDelete,
  });

  bool get _achieved => availableStars >= reward.starCost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: reward.isRedeemed
            ? AppColors.bgCard.withValues(alpha: 0.5)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _achieved && !reward.isRedeemed
              ? AppColors.accentYellow.withValues(alpha: 0.5)
              : AppColors.bgCardLight,
        ),
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
                    decoration: reward.isRedeemed
                        ? TextDecoration.lineThrough
                        : null,
                    color: reward.isRedeemed
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reward.isRedeemed
                      ? 'Redeemed ✓'
                      : '$availableStars/${reward.starCost} ⭐',
                  style: AppTextStyles.label.copyWith(
                    color: reward.isRedeemed
                        ? AppColors.accentGreen
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!reward.isRedeemed && _achieved)
            TextButton(
              onPressed: onRedeem,
              child: Text('Redeem',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.accentGreen)),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.textMuted, size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

// ── Topic section (Phase 6) ────────────────────────────────────────────────

class _TopicSection extends ConsumerWidget {
  final PlayerProfile profile;
  const _TopicSection({required this.profile});

  static const _topicLabels = {
    'add': '+ Addition',
    'sub': '− Subtraction',
    'mul': '× Multiplication',
    'div': '÷ Division',
  };

  static const _topicsByBand = [
    ['add', 'sub'],
    ['add', 'sub', 'mul'],
    ['add', 'sub', 'mul', 'div'],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = _topicsByBand[profile.ageBand];
    final enabled = profile.enabledTopics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Practice Topics', style: AppTextStyles.headline3),
        const SizedBox(height: 4),
        Text(
          'Choose which operations to include in games',
          style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        ...available.map((topic) {
          final isOn = enabled.contains(topic);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bgCardLight),
            ),
            child: SwitchListTile(
              value: isOn,
              activeThumbColor: AppColors.primaryLight,
              title: Text(_topicLabels[topic]!, style: AppTextStyles.body),
              onChanged: (v) {
                // Always keep at least one topic enabled
                final newSet = Set<String>.from(enabled);
                if (!v && newSet.length == 1) return;
                if (v) {
                  newSet.add(topic);
                } else {
                  newSet.remove(topic);
                }
                ref.read(playerProfileProvider.notifier).setEnabledTopics(newSet);
              },
            ),
          );
        }),
      ],
    );
  }
}

// ── Session log ────────────────────────────────────────────────────────────

class _SessionSection extends StatelessWidget {
  final List logs;
  const _SessionSection({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Sessions', style: AppTextStyles.headline3),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          const _EmptyState(
            icon: '📊',
            message: 'No sessions recorded yet.\nPlay a game to see results here!',
          )
        else
          ...logs.take(10).map((log) => _SessionRow(log: log)),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  final log;
  const _SessionRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final pct = (log.accuracy * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Row(
        children: [
          Text(log.isPractice ? '🎯' : '⚡',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.date, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  '${log.correctCount}/${log.totalAnswered} correct · $pct% accuracy',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text('+${log.starsEarned} ⭐',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.accentYellow)),
        ],
      ),
    );
  }
}

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
