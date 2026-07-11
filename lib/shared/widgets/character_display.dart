import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/theme_mode_provider.dart';
import '../../core/theme/app_text_styles.dart';

class CharacterDisplay extends ConsumerWidget {
  final String imagePath;
  final String name;
  final String quote;
  final double height;
  final Color? accentColor;

  const CharacterDisplay({
    super.key,
    required this.imagePath,
    required this.name,
    required this.quote,
    this.height = 160,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          height: height,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 14),

        // Name
        Text(
          name,
          style: AppTextStyles.headline3(colors)
              .copyWith(color: accentColor ?? colors.primaryLight),
        ),
        const SizedBox(height: 4),

        // Quote
        Text(
          quote,
          style: AppTextStyles.body(colors).copyWith(
            fontStyle: FontStyle.italic,
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
