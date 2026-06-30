import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/reward.dart';
import '../providers/rewards_provider.dart';

class CreateRewardSheet extends ConsumerStatefulWidget {
  const CreateRewardSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgMid,
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
    '🎁', '🎮', '🍕', '🍦', '🎬', '🏖️', '🎡', '⚽', '📚', '🛴',
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('New Reward', style: AppTextStyles.headline2,
              textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Emoji picker
          Text('Pick an icon', style: AppTextStyles.label),
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
                        ? AppColors.primary.withOpacity(0.25)
                        : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryLight
                          : AppColors.bgCardLight,
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
          Text('Reward name', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Movie night, Extra screen time…',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textMuted.withOpacity(0.5),
              ),
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primaryLight, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Star cost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Star cost', style: AppTextStyles.label),
              Text('$_starCost ⭐',
                  style: AppTextStyles.headline3
                      .copyWith(color: AppColors.accentYellow)),
            ],
          ),
          Slider(
            value: _starCost.toDouble(),
            min: 25,
            max: 500,
            divisions: 19,
            activeColor: AppColors.primaryLight,
            inactiveColor: AppColors.bgCardLight,
            onChanged: (v) => setState(() => _starCost = v.round()),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('25', style: AppTextStyles.label),
              Text('500', style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 24),
          AppButton.play(label: '✅  Save Reward', onTap: _save),
        ],
      ),
    );
  }
}
