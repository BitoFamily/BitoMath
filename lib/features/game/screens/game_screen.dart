import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/game_state.dart';
import '../models/question_config.dart';
import '../providers/game_provider.dart';
import '../widgets/answer_button.dart';
import '../widgets/timer_ring.dart';

class GameScreen extends ConsumerWidget {
  final int ageBand;
  final bool isPractice;

  const GameScreen({
    super.key,
    required this.ageBand,
    required this.isPractice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.read(playerProfileProvider);
    final qConfig = QuestionConfig(
      ageBand: ageBand,
      enabledTopics: profile.enabledTopics,
      topicAccuracy: profile.topicAccuracy,
    );
    final config = (
      ageBand: ageBand,
      isPractice: isPractice,
      topics: qConfig.key,
    );

    ref.listen<GameState>(gameProvider(config), (prev, next) {
      if (next.phase == GamePhase.finished) {
        HapticFeedback.vibrate();
        context.go('/results', extra: next);
      }
      if (prev != null &&
          next.streak > 0 &&
          next.streak % AppConstants.bonusStreakThreshold == 0 &&
          next.streak != prev.streak) {
        HapticFeedback.heavyImpact();
        SoundService.instance.streak();
      }
      if (prev != null &&
          !next.isPractice &&
          next.phase == GamePhase.playing &&
          next.secondsRemaining == 10 &&
          prev.secondsRemaining > 10) {
        HapticFeedback.mediumImpact();
      }
    });

    final state = ref.watch(gameProvider(config));
    final notifier = ref.read(gameProvider(config).notifier);

    void confirmExit() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.bgMid,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Leave game?', style: AppTextStyles.headline3),
          content: Text(
            'Your progress this round will be lost.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep playing',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.primaryLight)),
            ),
            TextButton(
              onPressed: () => context.go(Routes.home),
              child: Text('Exit',
                  style:
                      AppTextStyles.label.copyWith(color: AppColors.accentCoral)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: confirmExit,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.bgCardLight),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _HUD(state: state),
                const SizedBox(height: 16),
                _AgeBandChip(ageBand: ageBand, isPractice: isPractice),
                const Spacer(),
                _QuestionDisplay(state: state),
                const Spacer(),
                _AnswerGrid(
                  state: state,
                  onTap: (i) {
                    final q = state.currentQuestion;
                    if (q != null) {
                      if (q.choices[i] == q.correctAnswer) {
                        HapticFeedback.lightImpact();
                        SoundService.instance.correct();
                      } else {
                        HapticFeedback.mediumImpact();
                        SoundService.instance.wrong();
                      }
                    }
                    notifier.answerQuestion(i);
                  },
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── HUD ────────────────────────────────────────────────────────────────────

class _HUD extends StatelessWidget {
  final GameState state;
  const _HUD({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!state.isPractice)
          TimerRing(
            secondsRemaining: state.secondsRemaining,
            totalSeconds: AppConstants.defaultGameDurationSeconds,
          )
        else
          const SizedBox(width: 80, height: 80),
        const Spacer(),
        _HUDStat(
            icon: '⚡',
            label: 'Score',
            value: '${state.score}',
            color: AppColors.accentYellow),
        const SizedBox(width: 20),
        _HUDStat(
            icon: AppConstants.iconStreak,
            label: 'Streak',
            value: '${state.streak}',
            color: AppColors.accentCoral),
      ],
    );
  }
}

class _HUDStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _HUDStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.headline3.copyWith(color: color)),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}

class _AgeBandChip extends StatelessWidget {
  final int ageBand;
  final bool isPractice;
  const _AgeBandChip({required this.ageBand, required this.isPractice});

  @override
  Widget build(BuildContext context) {
    final label =
        '${AppConstants.ageBandLabels[ageBand]}${isPractice ? ' · Practice' : ''}';
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.bgCardLight),
        ),
        child: Text(label, style: AppTextStyles.label),
      ),
    );
  }
}

// ── Question display ───────────────────────────────────────────────────────

class _QuestionDisplay extends StatelessWidget {
  final GameState state;
  const _QuestionDisplay({required this.state});

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion;
    if (q == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Q ${state.totalAnswered + (state.phase == GamePhase.answering ? 0 : 1)}',
          style: AppTextStyles.label.copyWith(color: AppColors.primaryLight),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            q.problem,
            key: ValueKey(q.problem),
            style: AppTextStyles.gameQuestion,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        if (state.streak > 0 &&
            state.streak % AppConstants.bonusStreakThreshold == 0)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.accentYellow.withOpacity(0.5)),
            ),
            child: Text(
              '🔥 ${state.streak} in a row! +5 bonus!',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.accentYellow),
            ),
          ),
      ],
    );
  }
}

// ── Answer grid ────────────────────────────────────────────────────────────

class _AnswerGrid extends StatelessWidget {
  final GameState state;
  final void Function(int) onTap;
  const _AnswerGrid({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion;
    if (q == null) return const SizedBox.shrink();
    final isAnswering = state.phase == GamePhase.answering;

    Widget button(int i) {
      bool? result;
      if (isAnswering) {
        final isSelected = state.selectedChoiceIndex == i;
        final isCorrect = q.choices[i] == q.correctAnswer;
        if (isSelected) {
          result = state.lastAnswerCorrect;
        } else if (isCorrect && state.lastAnswerCorrect == false) {
          result = true;
        }
      }
      return AnswerButton(
        value: q.choices[i],
        result: result,
        enabled: !isAnswering,
        onTap: () => onTap(i),
      );
    }

    return Column(
      children: [
        Row(children: [
          Expanded(child: button(0)),
          const SizedBox(width: 12),
          Expanded(child: button(1)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: button(2)),
          const SizedBox(width: 12),
          Expanded(child: button(3)),
        ]),
      ],
    );
  }
}
