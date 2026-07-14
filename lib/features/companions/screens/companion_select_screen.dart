import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/companion_data.dart';

class CompanionSelectScreen extends ConsumerWidget {
  const CompanionSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: colors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textSecondary),
        title: Text(AppLocalizations.of(context)!.companionsTitle,
            style: AppTextStyles.headline3(colors)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemCount: CompanionData.all.length,
        itemBuilder: (context, i) {
          final companion = CompanionData.all[i];
          final unlocked = companion.isUnlocked(profile.stars);
          final selected = profile.selectedCharacter == i;

          return _CompanionCard(
            companion: companion,
            unlocked: unlocked,
            selected: selected,
            currentStars: profile.stars,
            onTap: unlocked
                ? () {
                    HapticFeedback.lightImpact();
                    ref.read(playerProfileProvider.notifier).setCharacter(i);
                    Navigator.pop(context);
                  }
                : () {
                    _showLockedToast(context, colors, companion.unlockStars);
                  },
          );
        },
      ),
    );
  }

  void _showLockedToast(
      BuildContext context, AppPalette colors, int starsNeeded) {
    final l10n = AppLocalizations.of(context)!;
    final message = starsNeeded >= 9999
        ? l10n.companionComingSoonToast
        : l10n.companionUnlockAt(starsNeeded);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body(colors).copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.bgMid,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _CompanionCard extends ConsumerWidget {
  final CompanionData companion;
  final bool unlocked;
  final bool selected;
  final int currentStars;
  final VoidCallback onTap;

  const _CompanionCard({
    required this.companion,
    required this.unlocked,
    required this.selected,
    required this.currentStars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? colors.characterPrimary[companion.index].withValues(alpha: 0.2)
              : colors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colors.characterPrimary[companion.index]
                : unlocked
                    ? colors.bgCardLight
                    : colors.bgCardLight.withValues(alpha: 0.5),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: unlocked
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.saturation)
                        : const ColorFilter.matrix([
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: unlocked
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.characterPrimary[companion.index],
                                  colors.characterSecondary[companion.index],
                                ],
                              )
                            : LinearGradient(
                                colors: [colors.bgCardLight, colors.bgMid]),
                      ),
                      child: Center(
                        child: Text(
                          companion.emoji,
                          style: TextStyle(
                              fontSize: 42,
                              color: unlocked ? null : Colors.white30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    companion.name,
                    style: AppTextStyles.headline3(colors).copyWith(
                      color: unlocked ? colors.textPrimary : colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!unlocked && companion.unlockStars >= 9999)
                    Text(
                      AppLocalizations.of(context)!.companionComingSoonBadge,
                      style: AppTextStyles.label(colors)
                          .copyWith(color: colors.textMuted),
                    )
                  else if (!unlocked)
                    _UnlockProgress(
                      currentStars: currentStars,
                      goalStars: companion.unlockStars,
                      accent: colors.characterPrimary[companion.index],
                      colors: colors,
                    )
                  else if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.characterPrimary[companion.index]
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.companionActiveBadge,
                        style: AppTextStyles.label(colors).copyWith(
                            color: colors.characterPrimary[companion.index]),
                      ),
                    ),
                ],
              ),
            ),
            if (!unlocked)
              Positioned(
                top: 10,
                right: 10,
                child:
                    Icon(Icons.lock_rounded, color: colors.textMuted, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnlockProgress extends StatelessWidget {
  final int currentStars;
  final int goalStars;
  final Color accent;
  final AppPalette colors;

  const _UnlockProgress({
    required this.currentStars,
    required this.goalStars,
    required this.accent,
    required this.colors,
  });

  double get _progress =>
      goalStars == 0 ? 0.0 : (currentStars / goalStars).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.starsProgress(
            currentStars.clamp(0, goalStars),
            goalStars,
          ),
          style: AppTextStyles.label(colors).copyWith(color: colors.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 5,
            backgroundColor: colors.bgCardLight,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}
