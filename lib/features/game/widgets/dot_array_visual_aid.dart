import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/theme_mode_provider.dart';

/// Static dot-array visual aid for multiplication: [rows] rows of [cols]
/// dots each, so the child can count the total instead of guessing.
class DotArrayVisualAid extends ConsumerWidget {
  final int rows;
  final int cols;

  const DotArrayVisualAid({super.key, required this.rows, required this.cols});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primaryLight,
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
