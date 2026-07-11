import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Static dot-array visual aid for multiplication: [rows] rows of [cols]
/// dots each, so the child can count the total instead of guessing.
class DotArrayVisualAid extends StatelessWidget {
  final int rows;
  final int cols;

  const DotArrayVisualAid({super.key, required this.rows, required this.cols});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        rows,
        (r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              cols,
              (c) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
