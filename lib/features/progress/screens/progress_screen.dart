import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/topic_strings.dart';
import '../../../core/persistence/player_profile.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../rewards/models/session_log.dart';
import '../../rewards/providers/rewards_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final logs = ref.watch(rewardsProvider).sessionLogs;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textSecondary),
        title: Text(AppLocalizations.of(context)!.progressTitle,
            style: AppTextStyles.headline3),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _HeroRow(profile: profile),
          const SizedBox(height: 20),
          _TierCard(stars: profile.stars),
          const SizedBox(height: 20),
          _TopicMastery(profile: profile),
          const SizedBox(height: 20),
          _SessionHistory(logs: logs),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Hero stats row ─────────────────────────────────────────────────────────

class _HeroRow extends StatelessWidget {
  final PlayerProfile profile;
  const _HeroRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: AppConstants.iconStar,
            label: l10n.statStars,
            value: '${profile.stars}',
            color: AppColors.gold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: AppConstants.iconStreak,
            label: l10n.statDayStreak,
            value: '${profile.streakDays}',
            color: AppColors.accentCoral,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: AppConstants.iconTrophy,
            label: l10n.statBestScore,
            value: '${profile.bestScore}',
            color: AppColors.accentYellow,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.headline3.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Tier progress card ─────────────────────────────────────────────────────

class _TierCard extends StatelessWidget {
  final int stars;
  const _TierCard({required this.stars});

  static const _emojis = ['⭐', '🥉', '🥈', '🥇', '💎'];
  static const _thresholds = [
    0,
    AppConstants.starsForBronze,
    AppConstants.starsForSilver,
    AppConstants.starsForGold,
    AppConstants.starsForDiamond,
  ];

  static List<String> _names(AppLocalizations l10n) => [
        l10n.tierNameStarter,
        l10n.tierNameBronze,
        l10n.tierNameSilver,
        l10n.tierNameGold,
        l10n.tierNameDiamond,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final names = _names(l10n);
    int currentIdx = 0;
    for (int i = _thresholds.length - 1; i >= 0; i--) {
      if (stars >= _thresholds[i]) {
        currentIdx = i;
        break;
      }
    }

    final isMax = currentIdx == _thresholds.length - 1;
    final nextIdx = isMax ? currentIdx : currentIdx + 1;
    final floor = _thresholds[currentIdx];
    final ceiling = _thresholds[nextIdx];
    final progress =
        isMax ? 1.0 : ((stars - floor) / (ceiling - floor)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tierProgressTitle, style: AppTextStyles.headline3),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_thresholds.length, (i) {
              final achieved = stars >= _thresholds[i];
              final isCurrent = i == currentIdx;
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      _emojis[i],
                      style: TextStyle(
                        fontSize: isCurrent ? 30 : 18,
                        color: achieved
                            ? null
                            : AppColors.textMuted.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      names[i],
                      style: AppTextStyles.label.copyWith(
                        color: isCurrent
                            ? AppColors.accentYellow
                            : AppColors.textMuted,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.bgCardLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isMax ? AppColors.gem : AppColors.accentYellow,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (isMax)
            Text(l10n.maxTierReached,
                style: AppTextStyles.label.copyWith(color: AppColors.gem))
          else
            Text(
              l10n.starsToGo(stars, ceiling, ceiling - stars),
              style:
                  AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

// ── Topic mastery ──────────────────────────────────────────────────────────

class _TopicMastery extends StatelessWidget {
  final PlayerProfile profile;
  const _TopicMastery({required this.profile});

  static const _topicsByBand = [
    ['add', 'sub'],
    ['add', 'sub', 'mul'],
    ['add', 'sub', 'mul', 'div'],
  ];

  Color _barColor(double acc) {
    if (acc >= 0.85) return AppColors.accentGreen;
    if (acc >= 0.60) return AppColors.accentYellow;
    return AppColors.accentCoral;
  }

  String _statusText(AppLocalizations l10n, double acc) {
    if (acc >= 0.85) return l10n.statusMastered;
    if (acc >= 0.60) return l10n.statusGettingThere;
    return l10n.statusNeedsPractice;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topics = _topicsByBand[profile.ageBand];
    final focus = profile.focusTopic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.topicMasteryTitle, style: AppTextStyles.headline3),
        const SizedBox(height: 12),
        ...topics.map((topic) {
          final label = TopicStrings.label(context, topic);
          final accuracy = profile.topicAccuracy[topic];
          final isEnabled = profile.enabledTopics.contains(topic);
          final isFocus = topic == focus;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFocus
                    ? AppColors.accentCoral.withValues(alpha: 0.5)
                    : AppColors.bgCardLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: AppTextStyles.body),
                    if (isFocus) ...[
                      const SizedBox(width: 8),
                      _Chip(
                          label: l10n.focusChipLabel,
                          color: AppColors.accentCoral),
                    ],
                    const Spacer(),
                    if (!isEnabled)
                      Text(l10n.topicOff,
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textMuted))
                    else if (accuracy == null)
                      Text(l10n.topicNotPlayedYet,
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textMuted))
                    else
                      Text(
                        l10n.topicPercent((accuracy * 100).round()),
                        style: AppTextStyles.headline3
                            .copyWith(color: _barColor(accuracy)),
                      ),
                  ],
                ),
                if (accuracy != null && isEnabled) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: accuracy.clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: AppColors.bgCardLight,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_barColor(accuracy)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_statusText(l10n, accuracy),
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textMuted)),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
    );
  }
}

// ── Session history ────────────────────────────────────────────────────────

class _SessionHistory extends StatelessWidget {
  final List<SessionLog> logs;
  const _SessionHistory({required this.logs});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recentSessionsTitle, style: AppTextStyles.headline3),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          _EmptyCard(
            icon: '📊',
            message: l10n.noSessionsProgress,
          )
        else
          ...logs.take(20).map((log) => _SessionRow(log: log)),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  final SessionLog log;
  const _SessionRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pct = (log.accuracy * 100).round();
    final pctColor = pct >= 85
        ? AppColors.accentGreen
        : pct >= 60
            ? AppColors.accentYellow
            : AppColors.accentCoral;

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
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.date, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  l10n.sessionCorrectCount(log.correctCount, log.totalAnswered),
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.topicPercent(pct),
                  style: AppTextStyles.headline3.copyWith(color: pctColor)),
              Text(l10n.starsEarnedPrefix(log.starsEarned),
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.accentYellow)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

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
