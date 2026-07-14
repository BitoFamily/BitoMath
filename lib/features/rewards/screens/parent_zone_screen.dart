import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/age_band_strings.dart';
import '../../../core/constants/topic_strings.dart';
import '../../../core/persistence/player_profile.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/services/visual_aids_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/reward.dart';
import '../models/session_log.dart';
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
    final colors = ref.watch(appPaletteProvider);
    final rewards = ref.watch(rewardsProvider);
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: colors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textSecondary),
        title: Text(AppLocalizations.of(context)!.parentZoneTitle,
            style: AppTextStyles.headline3(colors)),
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
          const _VisualAidsSection(),
          const SizedBox(height: 20),
          _SessionSection(logs: rewards.sessionLogs),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Star summary ───────────────────────────────────────────────────────────

class _StarSummary extends ConsumerWidget {
  final PlayerProfile profile;
  final RewardsState rewards;
  const _StarSummary({required this.profile, required this.rewards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final total = profile.stars;
    final available = rewards.availableStars(total);
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
              Text(
                  profile.name.isNotEmpty
                      ? profile.name
                      : l10n.defaultPlayerName,
                  style: AppTextStyles.headline3(colors)),
              const SizedBox(height: 4),
              Text(AgeBandStrings.name(context, profile.ageBand),
                  style: AppTextStyles.label(colors)
                      .copyWith(color: colors.textSecondary)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.starsCount(total),
                  style: AppTextStyles.headline2(colors)
                      .copyWith(color: colors.accentYellow)),
              Text(l10n.totalEarnedLabel,
                  style: AppTextStyles.label(colors)
                      .copyWith(color: colors.textSecondary)),
              if (showSplit) ...[
                const SizedBox(height: 4),
                Text(l10n.availableStarsLabel(available),
                    style: AppTextStyles.label(colors)
                        .copyWith(color: colors.textPrimary)),
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
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.navRewards, style: AppTextStyles.headline3(colors)),
            if (rewards.rewards.length < 5)
              GestureDetector(
                onTap: () => CreateRewardSheet.show(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: colors.primaryLight.withValues(alpha: 0.5)),
                  ),
                  child: Text(l10n.addButton,
                      style: AppTextStyles.label(colors)
                          .copyWith(color: colors.primaryLight)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (rewards.rewards.isEmpty)
          _EmptyState(
            icon: '🎁',
            message: l10n.noRewardsYet,
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

class _RewardRow extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: reward.isRedeemed
            ? colors.bgCard.withValues(alpha: 0.5)
            : colors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _achieved && !reward.isRedeemed
              ? colors.accentYellow.withValues(alpha: 0.5)
              : colors.bgCardLight,
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
                  style: AppTextStyles.body(colors).copyWith(
                    decoration:
                        reward.isRedeemed ? TextDecoration.lineThrough : null,
                    color: reward.isRedeemed
                        ? colors.textMuted
                        : colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reward.isRedeemed
                      ? l10n.redeemedCheck
                      : l10n.starsProgress(availableStars, reward.starCost),
                  style: AppTextStyles.label(colors).copyWith(
                    color: reward.isRedeemed
                        ? colors.accentGreen
                        : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!reward.isRedeemed && _achieved)
            TextButton(
              onPressed: onRedeem,
              child: Text(l10n.redeemButton,
                  style: AppTextStyles.label(colors)
                      .copyWith(color: colors.accentGreen)),
            )
          else
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: colors.textMuted, size: 20),
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

  static const _topicsByBand = [
    ['add', 'sub'],
    ['add', 'sub', 'mul'],
    ['add', 'sub', 'mul', 'div'],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final available = _topicsByBand[profile.ageBand];
    final enabled = profile.enabledTopics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.practiceTopicsTitle, style: AppTextStyles.headline3(colors)),
        const SizedBox(height: 4),
        Text(
          l10n.practiceTopicsSubtitle,
          style: AppTextStyles.label(colors).copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 12),
        ...available.map((topic) {
          final isOn = enabled.contains(topic);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              radius: 14,
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                value: isOn,
                activeThumbColor: colors.primaryLight,
                title: Text(TopicStrings.label(context, topic),
                    style: AppTextStyles.body(colors)),
                onChanged: (v) {
                  // Always keep at least one topic enabled
                  final newSet = Set<String>.from(enabled);
                  if (!v && newSet.length == 1) return;
                  if (v) {
                    newSet.add(topic);
                  } else {
                    newSet.remove(topic);
                  }
                  ref
                      .read(playerProfileProvider.notifier)
                      .setEnabledTopics(newSet);
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Visual aids toggle ──────────────────────────────────────────────────────

class _VisualAidsSection extends ConsumerWidget {
  const _VisualAidsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref.watch(visualAidsEnabledProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.bgCardLight),
      ),
      child: SwitchListTile(
        value: enabled,
        activeThumbColor: colors.primaryLight,
        title: Text(l10n.visualAidsTitle, style: AppTextStyles.body(colors)),
        subtitle: Text(
          l10n.visualAidsSubtitle,
          style: AppTextStyles.label(colors).copyWith(color: colors.textMuted),
        ),
        onChanged: (v) =>
            ref.read(visualAidsEnabledProvider.notifier).setEnabled(v),
      ),
    );
  }
}

// ── Session log ────────────────────────────────────────────────────────────

class _SessionSection extends ConsumerWidget {
  final List<SessionLog> logs;
  const _SessionSection({required this.logs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recentSessionsTitle, style: AppTextStyles.headline3(colors)),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          _EmptyState(
            icon: '📊',
            message: l10n.noSessionsParent,
          )
        else
          ...logs.take(10).map((log) => _SessionRow(log: log)),
      ],
    );
  }
}

class _SessionRow extends ConsumerWidget {
  final SessionLog log;
  const _SessionRow({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final pct = (log.accuracy * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(log.isPractice ? '🎯' : '⚡',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.date, style: AppTextStyles.label(colors)),
                const SizedBox(height: 2),
                Text(
                  l10n.sessionCorrectAndAccuracy(
                      log.correctCount, log.totalAnswered, pct),
                  style: AppTextStyles.body(colors)
                      .copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Text(l10n.starsEarnedPrefix(log.starsEarned),
              style: AppTextStyles.label(colors)
                  .copyWith(color: colors.accentYellow)),
        ],
      ),
      ),
    );
  }
}

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
