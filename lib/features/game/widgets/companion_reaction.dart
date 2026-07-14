import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../companions/models/companion_data.dart';
import '../models/game_state.dart';

/// Small companion avatar pinned to a corner during gameplay. Pops a speech
/// bubble with a quote whenever the player answers — celebratory for correct
/// (extra emphatic on a streak milestone), encouraging for wrong. Purely
/// reactive to [state] changes via [didUpdateWidget], so it stays a drop-in
/// sibling in GameScreen's layout rather than an overlay that could drift
/// over the answer buttons.
class CompanionReaction extends ConsumerStatefulWidget {
  final GameState state;
  const CompanionReaction({super.key, required this.state});

  @override
  ConsumerState<CompanionReaction> createState() => _CompanionReactionState();
}

class _CompanionReactionState extends ConsumerState<CompanionReaction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceAnim;
  String? _bubbleText;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant CompanionReaction oldWidget) {
    super.didUpdateWidget(oldWidget);
    final justAnswered =
        widget.state.totalAnswered > oldWidget.state.totalAnswered;
    if (justAnswered) _react();
  }

  void _react() {
    final index = ref.read(playerProfileProvider).selectedCharacter;
    final companion = CompanionData.all[index];
    final correct = widget.state.lastAnswerCorrect == true;
    final isStreakMilestone = correct &&
        widget.state.streak > 0 &&
        widget.state.streak % AppConstants.bonusStreakThreshold == 0;
    final mood = correct ? CompanionMood.celebrate : CompanionMood.encourage;

    setState(() => _bubbleText = companion.quote(context, mood));

    // Bounce pop-in then settle back — completes well within the ~650ms
    // window before the next question appears, so it never delays pacing.
    _bounceCtrl.forward(from: 0).then((_) {
      if (mounted) _bounceCtrl.reverse();
    });
    if (isStreakMilestone) {
      HapticFeedback.selectionClick();
    }

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _bubbleText = null);
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appPaletteProvider);
    final index = ref.watch(
        playerProfileProvider.select((p) => p.selectedCharacter));
    final accent = colors.characterPrimary[index];

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4, right: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                alignment: Alignment.bottomRight,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _bubbleText == null
                  ? const SizedBox.shrink()
                  : _SpeechBubble(
                      key: ValueKey(_bubbleText),
                      text: _bubbleText!,
                      accent: accent,
                      colors: colors,
                    ),
            ),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) =>
                  Transform.scale(scale: _bounceAnim.value, child: child),
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.bgCard,
                  border: Border.all(color: accent, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    AppConstants.characterImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  final Color accent;
  final AppPalette colors;
  const _SpeechBubble({
    super.key,
    required this.text,
    required this.accent,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.6)),
        ),
        child: Text(
          text,
          style: AppTextStyles.label(colors).copyWith(color: colors.textPrimary),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
