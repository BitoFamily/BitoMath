import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../models/companion_data.dart';

class CompanionSelectScreen extends ConsumerWidget {
  const CompanionSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textSecondary),
        title: Text(AppLocalizations.of(context)!.companionsTitle,
            style: AppTextStyles.headline3),
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
            onTap: unlocked
                ? () {
                    HapticFeedback.lightImpact();
                    ref.read(playerProfileProvider.notifier).setCharacter(i);
                    Navigator.pop(context);
                  }
                : () {
                    _showLockedToast(context, companion.unlockStars);
                  },
          );
        },
      ),
    );
  }

  void _showLockedToast(BuildContext context, int starsNeeded) {
    final l10n = AppLocalizations.of(context)!;
    final message = starsNeeded >= 9999
        ? l10n.companionComingSoonToast
        : l10n.companionUnlockAt(starsNeeded);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.bgMid,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  final CompanionData companion;
  final bool unlocked;
  final bool selected;
  final VoidCallback onTap;

  const _CompanionCard({
    required this.companion,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.characterPrimary[companion.index]
                  .withValues(alpha: 0.2)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.characterPrimary[companion.index]
                : unlocked
                    ? AppColors.bgCardLight
                    : AppColors.bgCardLight.withValues(alpha: 0.5),
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
                                  AppColors.characterPrimary[companion.index],
                                  AppColors.characterSecondary[companion.index],
                                ],
                              )
                            : const LinearGradient(colors: [
                                AppColors.bgCardLight,
                                AppColors.bgMid
                              ]),
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
                    style: AppTextStyles.headline3.copyWith(
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!unlocked)
                    Text(
                      companion.unlockStars >= 9999
                          ? AppLocalizations.of(context)!
                              .companionComingSoonBadge
                          : AppLocalizations.of(context)!
                              .starsCount(companion.unlockStars),
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textMuted),
                    )
                  else if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.characterPrimary[companion.index]
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.companionActiveBadge,
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.characterPrimary[companion.index]),
                      ),
                    ),
                ],
              ),
            ),
            if (!unlocked)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.lock_rounded,
                    color: AppColors.textMuted, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
