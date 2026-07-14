import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/theme_mode_provider.dart';

/// Tactile "clicky" card: solid accent border + flat (non-blurry) bottom
/// drop-shadow, matching the Playground Teal brief's card treatment.
/// [translucent] switches to the softer overlay style used for result/
/// content cards (semi-transparent fill, no shadow).
///
/// Built on [Material] rather than a plain [Container] so anything
/// interactive placed inside (ListTile, InkWell, TextButton) still paints
/// its background/ink splashes correctly — a raw color-filled Container
/// ancestor hides them.
class AppCard extends ConsumerWidget {
  final Widget child;
  final double radius;
  final double borderWidth;
  final Color? accentColor;
  final bool translucent;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.borderWidth = 3,
    this.accentColor,
    this.translucent = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final border = accentColor ?? colors.bgCardLight;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: translucent
            ? []
            : [
                BoxShadow(
                  color: border.withValues(alpha: 0.35),
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: translucent
            ? colors.bgCard.withValues(alpha: 0.85)
            : colors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border, width: borderWidth),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
