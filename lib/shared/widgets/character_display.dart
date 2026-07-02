import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CharacterDisplay extends StatelessWidget {
  final String imagePath;
  final String name;
  final String quote;
  final double height;
  final Color accentColor;

  const CharacterDisplay({
    super.key,
    required this.imagePath,
    required this.name,
    required this.quote,
    this.height = 160,
    this.accentColor = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
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
          style: AppTextStyles.headline3.copyWith(color: accentColor),
        ),
        const SizedBox(height: 4),

        // Quote
        Text(
          quote,
          style: AppTextStyles.body.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
