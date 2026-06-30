import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CharacterDisplay extends StatelessWidget {
  final String imagePath;
  final String name;
  final String quote;
  final double size;

  const CharacterDisplay({
    super.key,
    required this.imagePath,
    required this.name,
    required this.quote,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing circle avatar with character image
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.55),
                blurRadius: 36,
                spreadRadius: 6,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Name
        Text(
          name,
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.primaryLight,
          ),
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
