import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/age_band_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _goToAgeStep() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameFocus.requestFocus();
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _step = 1);
  }

  Future<void> _finish(int ageBand) async {
    HapticFeedback.mediumImpact();
    await ref.read(playerProfileProvider.notifier).completeOnboarding(
          name: _nameController.text.trim(),
          ageBand: ageBand,
        );
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appPaletteProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.backgroundGradient),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _step == 0
                ? _NamePage(
                    key: const ValueKey('name'),
                    controller: _nameController,
                    focusNode: _nameFocus,
                    onNext: _goToAgeStep,
                  )
                : _AgePage(
                    key: const ValueKey('age'),
                    playerName: _nameController.text.trim(),
                    onSelect: _finish,
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Step 1: Name ──────────────────────────────────────────────────────────

class _NamePage extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onNext;

  const _NamePage({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Text('⚡',
              style: TextStyle(fontSize: 72), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(
            l10n.onboardingWelcomeTitle,
            style: AppTextStyles.headline1(colors),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingNamePrompt,
            style: AppTextStyles.bodyLarge(colors)
                .copyWith(color: colors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textAlign: TextAlign.center,
            maxLength: 20,
            style: AppTextStyles.headline2(colors)
                .copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              counterText: '',
              hintText: l10n.onboardingNameHint,
              hintStyle: AppTextStyles.headline2(colors).copyWith(
                color: colors.textMuted.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: colors.primaryLight,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
            onSubmitted: (_) => onNext(),
          ),
          const SizedBox(height: 32),
          AppButton.play(label: l10n.onboardingLetsGo, onTap: onNext),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Step 2: Age band ──────────────────────────────────────────────────────

class _AgePage extends ConsumerWidget {
  final String playerName;
  final Future<void> Function(int ageBand) onSelect;

  const _AgePage({
    super.key,
    required this.playerName,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final displayName =
        playerName.isNotEmpty ? playerName : l10n.defaultPlayerName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            l10n.onboardingGreeting(displayName),
            style: AppTextStyles.headline2(colors),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pickYourLevel,
            style: AppTextStyles.bodyLarge(colors)
                .copyWith(color: colors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...List.generate(AppConstants.ageBandCount, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _AgeBandCard(
                index: i,
                onTap: () => onSelect(i),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }
}

class _AgeBandCard extends ConsumerWidget {
  final int index;
  final VoidCallback onTap;

  static const _icons = ['🌱', '🌟', '🚀'];

  const _AgeBandCard({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.bgCardLight, width: 1.5),
        ),
        child: Row(
          children: [
            Text(_icons[index], style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AgeBandStrings.name(context, index),
                    style: AppTextStyles.headline3(colors),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AgeBandStrings.description(context, index)} (${AgeBandStrings.ageRange(context, index)})',
                    style: AppTextStyles.label(colors).copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.primaryLight, size: 28),
          ],
        ),
      ),
    );
  }
}
