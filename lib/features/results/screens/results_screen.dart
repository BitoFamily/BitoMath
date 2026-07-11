import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/companions/models/companion_data.dart';
import '../../../features/game/models/game_state.dart';
import '../../../features/rewards/models/session_log.dart';
import '../../../features/rewards/providers/rewards_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final GameState result;
  const ResultsScreen({super.key, required this.result});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playResultFeedback();
      _persist();
    });
  }

  @override
  void dispose() {
    SoundService.instance.stopComplete();
    super.dispose();
  }

  void _playResultFeedback() {
    final stars = widget.result.starsEarned;
    if (stars >= 3) {
      HapticFeedback.heavyImpact();
      SoundService.instance.complete();
    } else if (stars > 0) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _persist() async {
    final result = widget.result;
    final notifier = ref.read(playerProfileProvider.notifier);
    final rewardsNotifier = ref.read(rewardsProvider.notifier);

    // Snapshot rewards state; it won't change during recordGameResult
    final rewardsState = ref.read(rewardsProvider);
    final availBefore =
        rewardsState.availableStars(ref.read(playerProfileProvider).stars);

    // Update profile (stars, best score, streak, topic accuracy)
    await notifier.recordGameResult(result);

    final availAfter =
        rewardsState.availableStars(ref.read(playerProfileProvider).stars);

    // Check for rewards that crossed their threshold this session
    final justUnlocked = rewardsState.rewards
        .where((r) =>
            !r.isRedeemed &&
            r.starCost > availBefore &&
            r.starCost <= availAfter)
        .map((r) => '${r.emoji} ${r.name}')
        .toList();

    // Log session
    final n = DateTime.now();
    final today =
        '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
    await rewardsNotifier.addSessionLog(SessionLog(
      date: today,
      score: result.score,
      correctCount: result.correctCount,
      totalAnswered: result.totalAnswered,
      starsEarned: result.correctCount,
      ageBand: result.ageBand,
      isPractice: result.isPractice,
    ));

    if (justUnlocked.isNotEmpty && mounted) {
      _showRewardDialog(justUnlocked);
    }
  }

  void _showRewardDialog(List<String> names) {
    final colors = ref.read(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(l10n.rewardUnlockedTitle,
                style: AppTextStyles.headline2(colors),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ...names.map((n) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(n,
                      style: AppTextStyles.body(colors)
                          .copyWith(color: colors.accentYellow),
                      textAlign: TextAlign.center),
                )),
            const SizedBox(height: 16),
            Text(l10n.showParentToClaim,
                style: AppTextStyles.label(colors)
                    .copyWith(color: colors.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.awesomeButton,
                style: AppTextStyles.body(colors)
                    .copyWith(color: colors.primaryLight)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appPaletteProvider);
    final result = widget.result;
    final stars = result.starsEarned;
    final accuracyPct = (result.accuracy * 100).round();
    final l10n = AppLocalizations.of(context)!;

    // Companion quote based on performance
    final profile = ref.read(playerProfileProvider);
    final companion = CompanionData
        .all[profile.selectedCharacter.clamp(0, CompanionData.all.length - 1)];
    final mood = stars >= 3
        ? CompanionMood.celebrate
        : stars == 0
            ? CompanionMood.encourage
            : CompanionMood.neutral;
    final companionQuote = companion.quote(context, mood);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                _StarRow(stars: stars),
                const SizedBox(height: 16),
                Text(
                  stars == 3
                      ? l10n.resultPerfect
                      : stars == 2
                          ? l10n.resultGreat
                          : stars == 1
                              ? l10n.resultKeepGoing
                              : l10n.resultTryAgain,
                  style: AppTextStyles.headline1(colors),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                // Companion reaction
                Text(
                  '${companion.emoji}  $companionQuote',
                  style: AppTextStyles.body(colors).copyWith(
                      color: colors.textSecondary,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _StatCard(
                  icon: AppConstants.iconStar,
                  label: l10n.statStarsEarned,
                  value: '+${result.correctCount}',
                  color: colors.accentYellow,
                ),
                const SizedBox(height: 10),
                _StatCard(
                  icon: '🎯',
                  label: l10n.statFinalScore,
                  value: '${result.score}',
                  color: colors.primaryLight,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: AppConstants.iconCorrect,
                        label: l10n.statCorrect,
                        value: '${result.correctCount}/${result.totalAnswered}',
                        color: colors.accentGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: '📈',
                        label: l10n.statAccuracy,
                        value: '$accuracyPct%',
                        color: colors.accentBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _StatCard(
                  icon: AppConstants.iconStreak,
                  label: l10n.statBestStreak,
                  value: l10n.inARow(result.bestStreak),
                  color: colors.accentCoral,
                ),
                const Spacer(),
                AppButton.play(
                  label: l10n.playAgainButton,
                  onTap: () {
                    final route = result.isPractice
                        ? '/practice/${result.ageBand}'
                        : '/game/${result.ageBand}';
                    context.go(route);
                  },
                ),
                const SizedBox(height: 14),
                AppButton.secondary(
                  label: l10n.homeButton,
                  onTap: () => context.go(Routes.home),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Star row ───────────────────────────────────────────────────────────────

class _StarRow extends ConsumerWidget {
  final int stars;
  const _StarRow({required this.stars});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('⭐',
              style: TextStyle(
                fontSize: 44,
                color: i < stars
                    ? colors.gold
                    : colors.textMuted.withValues(alpha: 0.3),
              )),
        );
      }),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────

class _StatCard extends ConsumerWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.label(colors)),
              const SizedBox(height: 2),
              Text(value,
                  style: AppTextStyles.headline3(colors).copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
