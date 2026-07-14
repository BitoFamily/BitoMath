import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/reward.dart';
import '../providers/rewards_provider.dart';

class CreateRewardSheet extends ConsumerStatefulWidget {
  const CreateRewardSheet({super.key});

  static Future<void> show(BuildContext context) {
    final colors = ProviderScope.containerOf(context).read(appPaletteProvider);
    return showModalBottomSheet(
      context: context,
      backgroundColor: colors.bgMid,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const CreateRewardSheet(),
    );
  }

  @override
  ConsumerState<CreateRewardSheet> createState() => _CreateRewardSheetState();
}

class _CreateRewardSheetState extends ConsumerState<CreateRewardSheet> {
  final _nameCtrl = TextEditingController();
  String _emoji = '🎁';
  int _starCost = 100;

  static const _emojiOptions = [
    '🎁',
    '🎮',
    '🍕',
    '🍦',
    '🎬',
    '🏖️',
    '🎡',
    '⚽',
    '📚',
    '🛴',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final reward = Reward(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      emoji: _emoji,
      starCost: _starCost,
    );
    await ref.read(rewardsProvider.notifier).addReward(reward);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appPaletteProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.newRewardTitle,
              style: AppTextStyles.headline2(colors),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Emoji picker
          Text(l10n.pickAnIconLabel, style: AppTextStyles.label(colors)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _emojiOptions.map((e) {
              final selected = e == _emoji;
              return GestureDetector(
                onTap: () => setState(() => _emoji = e),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary.withValues(alpha: 0.25)
                        : colors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? colors.primaryLight : colors.bgCardLight,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Reward name
          Text(l10n.rewardNameLabel, style: AppTextStyles.label(colors)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.body(colors).copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.rewardNameHint,
              hintStyle: AppTextStyles.body(colors).copyWith(
                color: colors.textMuted.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primaryLight, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Star cost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.starCostLabel, style: AppTextStyles.label(colors)),
              Text(l10n.starsCount(_starCost),
                  style: AppTextStyles.headline3(colors)
                      .copyWith(color: colors.accentYellow)),
            ],
          ),
          Slider(
            value: _starCost.toDouble(),
            min: 25,
            max: 500,
            divisions: 19,
            activeColor: colors.primaryLight,
            inactiveColor: colors.bgCardLight,
            onChanged: (v) => setState(() => _starCost = v.round()),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('25', style: AppTextStyles.label(colors)),
              Text('500', style: AppTextStyles.label(colors)),
            ],
          ),
          const SizedBox(height: 24),
          AppButton.play(label: l10n.saveRewardButton, onTap: _save),
        ],
      ),
    );
  }
}
