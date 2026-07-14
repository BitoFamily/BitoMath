import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/theme_mode_provider.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_card.dart';

class StatBadge extends ConsumerWidget {
  final String icon;
  final String label;
  final String value;
  final Color? valueColor;

  const StatBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.statNumber(colors).copyWith(
              color: valueColor ?? colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.label(colors)),
        ],
      ),
    );
  }
}
