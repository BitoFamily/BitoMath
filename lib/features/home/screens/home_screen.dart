import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/age_band_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/topic_strings.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/persistence/player_profile.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/rewards/providers/rewards_provider.dart';
import '../../../features/rewards/widgets/reward_progress_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/character_display.dart';
import '../../../shared/widgets/stat_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final profile = ref.watch(playerProfileProvider);
    final rewards = ref.watch(rewardsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                _Header(profile: profile),
                const SizedBox(height: 20),

                // Reward area: badge when rewards are ready, progress bar otherwise
                _RewardArea(rewards: rewards, totalStars: profile.stars),

                _CharacterCarousel(
                  selectedIndex: profile.selectedCharacter,
                  onChanged: (i) =>
                      ref.read(playerProfileProvider.notifier).setCharacter(i),
                  onLabelTap: () => context.push(Routes.companions),
                ),
                const SizedBox(height: 16),

                // Focus mode chip
                if (profile.focusTopic != null)
                  _FocusChip(topic: profile.focusTopic!),

                const SizedBox(height: 16),
                _StatsRow(profile: profile),
                const SizedBox(height: 28),
                AppButton.play(
                  label: l10n.playNowButton,
                  onTap: () => context.go('/game/${profile.ageBand}'),
                ),
                const SizedBox(height: 14),
                AppButton.secondary(
                  label: l10n.practiceButton,
                  onTap: () => context.go('/practice/${profile.ageBand}'),
                ),
                const Spacer(),
                _BottomNav(
                  onRewardsTap: () => context.push(Routes.rewards),
                  onProgressTap: () => context.push(Routes.progress),
                  onParentTap: () => context.push(Routes.parent),
                  onSettingsTap: () => context.push(Routes.settings),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final PlayerProfile profile;
  const _Header({required this.profile});

  String _tier(AppLocalizations l10n) {
    final s = profile.stars;
    if (s >= AppConstants.starsForDiamond) return l10n.tierBadgeDiamond;
    if (s >= AppConstants.starsForGold) return l10n.tierBadgeGold;
    if (s >= AppConstants.starsForSilver) return l10n.tierBadgeSilver;
    if (s >= AppConstants.starsForBronze) return l10n.tierBadgeBronze;
    return l10n.tierBadgeStarter;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final name =
        profile.name.isNotEmpty ? profile.name : l10n.defaultPlayerName;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeGreeting(name), style: AppTextStyles.body(colors)),
            const SizedBox(height: 2),
            Text('${AppConstants.appName} ⚡',
                style: AppTextStyles.headline2(colors)
                    .copyWith(color: colors.accentYellow)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: colors.primaryLight.withValues(alpha: 0.4)),
          ),
          child: Text(_tier(l10n),
              style: AppTextStyles.label(colors)
                  .copyWith(color: colors.accentYellow)),
        ),
      ],
    );
  }
}

// ── Focus chip ─────────────────────────────────────────────────────────────

class _FocusChip extends ConsumerWidget {
  final String topic;
  const _FocusChip({required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: colors.accentCoral.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: colors.accentCoral.withValues(alpha: 0.4)),
        ),
        child: Text(
          l10n.focusTodayLabel(TopicStrings.label(context, topic)),
          style: AppTextStyles.label(colors).copyWith(color: colors.accentCoral),
        ),
      ),
    );
  }
}

// ── Character carousel ─────────────────────────────────────────────────────

class _CharacterCarousel extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onLabelTap;

  const _CharacterCarousel({
    required this.selectedIndex,
    required this.onChanged,
    required this.onLabelTap,
  });

  void _prev() {
    HapticFeedback.selectionClick();
    onChanged((selectedIndex - 1 + AppConstants.characterImages.length) %
        AppConstants.characterImages.length);
  }

  void _next() {
    HapticFeedback.selectionClick();
    onChanged((selectedIndex + 1) % AppConstants.characterImages.length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return Row(
      children: [
        _ArrowButton(icon: Icons.chevron_left_rounded, onTap: _prev),
        Expanded(
          child: GestureDetector(
            onTap: onLabelTap,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: CharacterDisplay(
                key: ValueKey(selectedIndex),
                imagePath: AppConstants.characterImages[selectedIndex],
                name: AppConstants.characterNames[selectedIndex],
                quote: AgeBandStrings.characterQuote(context, selectedIndex),
                // Coco (index 0) is a small puppy-bot — displayed at half the
                // height of the human-scale Kato/Sona bots.
                height: selectedIndex == 0 ? 80 : 160,
                accentColor: colors.characterPrimary[selectedIndex],
              ),
            ),
          ),
        ),
        _ArrowButton(icon: Icons.chevron_right_rounded, onTap: _next),
      ],
    );
  }
}

class _ArrowButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.bgCard,
          shape: BoxShape.circle,
          border: Border.all(color: colors.bgCardLight),
        ),
        child: Icon(icon, color: colors.primaryLight, size: 24),
      ),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  final PlayerProfile profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: StatBadge(
            icon: AppConstants.iconStar,
            label: l10n.statStars,
            value: profile.stars.toString(),
            valueColor: colors.gold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatBadge(
            icon: AppConstants.iconStreak,
            label: l10n.statStreak,
            value: l10n.daysValue(profile.streakDays),
            valueColor: colors.accentCoral,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatBadge(
            icon: AppConstants.iconTrophy,
            label: l10n.statBest,
            value: profile.bestScore.toString(),
            valueColor: colors.accentYellow,
          ),
        ),
      ],
    );
  }
}

// ── Reward area ────────────────────────────────────────────────────────────

class _RewardArea extends StatelessWidget {
  final RewardsState rewards;
  final int totalStars;
  const _RewardArea({required this.rewards, required this.totalStars});

  @override
  Widget build(BuildContext context) {
    final ready = rewards.readyRewards(totalStars);
    final next = rewards.nextPendingReward(totalStars);
    final avail = rewards.availableStars(totalStars);

    if (ready.isEmpty && next == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          if (ready.isNotEmpty) ...[
            _RewardReadyBadge(count: ready.length),
            if (next != null) const SizedBox(height: 10),
          ],
          if (next != null)
            RewardProgressBar(reward: next, currentStars: avail),
        ],
      ),
    );
  }
}

class _RewardReadyBadge extends ConsumerWidget {
  final int count;
  const _RewardReadyBadge({required this.count});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.accentYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colors.accentYellow.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎁', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(l10n.rewardsReadyBadge(count),
              style: AppTextStyles.body(colors)
                  .copyWith(color: colors.accentYellow)),
          const SizedBox(width: 8),
          Text(l10n.tellAParent,
              style: AppTextStyles.label(colors)
                  .copyWith(color: colors.textMuted)),
        ],
      ),
    );
  }
}

// ── Bottom nav ─────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final VoidCallback onRewardsTap;
  final VoidCallback onProgressTap;
  final VoidCallback onParentTap;
  final VoidCallback onSettingsTap;
  const _BottomNav({
    required this.onRewardsTap,
    required this.onProgressTap,
    required this.onParentTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _NavItem(icon: '🏅', label: l10n.navRewards, onTap: onRewardsTap),
        _NavItem(icon: '📊', label: l10n.navProgress, onTap: onProgressTap),
        _NavItem(icon: '⚙️', label: l10n.navSettings, onTap: onSettingsTap),
        _NavItem(icon: '👨‍👩‍👧', label: l10n.navParent, onTap: onParentTap),
      ],
    );
  }
}

class _NavItem extends ConsumerWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.bgCardLight, width: 1.5),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.label(colors)),
        ],
      ),
    );
  }
}
