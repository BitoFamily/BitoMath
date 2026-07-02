import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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

class _NamePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Text('⚡', style: TextStyle(fontSize: 72), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(
            'Welcome to\nBito Math!',
            style: AppTextStyles.headline1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "What's your name?",
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
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
            style: AppTextStyles.headline2.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Your name here...',
              hintStyle: AppTextStyles.headline2.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primaryLight,
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
          AppButton.play(label: "Let's Go! →", onTap: onNext),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Step 2: Age band ──────────────────────────────────────────────────────

class _AgePage extends StatelessWidget {
  final String playerName;
  final Future<void> Function(int ageBand) onSelect;

  const _AgePage({
    super.key,
    required this.playerName,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        playerName.isNotEmpty ? playerName : 'Champion';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'Hi, $displayName! 👋',
            style: AppTextStyles.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pick your level',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...List.generate(AppConstants.ageBandLabels.length, (i) {
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

class _AgeBandCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  static const _descriptions = [
    'Counting, addition & subtraction up to 10',
    'Addition & subtraction up to 20',
    'Bigger numbers, intro to multiplication',
  ];

  static const _icons = ['🌱', '🌟', '🚀'];

  const _AgeBandCard({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.bgCardLight, width: 1.5),
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
                    AppConstants.ageBandLabels[index],
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _descriptions[index],
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.primaryLight, size: 28),
          ],
        ),
      ),
    );
  }
}
