import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/theme_mode_provider.dart';

/// Faint, static decorative layer of math symbols/numbers/stars behind
/// gameplay content — non-interactive and tinted from the active palette
/// so it reads correctly on both the light and dark backgrounds.
class GameBackgroundTexture extends ConsumerWidget {
  const GameBackgroundTexture({super.key});

  static const _glyphs = [
    ('+', Alignment(-0.85, -0.9)),
    ('7', Alignment(0.8, -0.75)),
    ('★', Alignment(-0.9, -0.3)),
    ('÷', Alignment(0.9, -0.15)),
    ('3', Alignment(-0.75, 0.25)),
    ('×', Alignment(0.85, 0.35)),
    ('★', Alignment(-0.4, 0.85)),
    ('9', Alignment(0.5, 0.9)),
    ('−', Alignment(0.15, -0.95)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final tint = colors.textMuted.withValues(alpha: 0.12);
    return IgnorePointer(
      child: Stack(
        children: [
          for (final (glyph, alignment) in _glyphs)
            Align(
              alignment: alignment,
              child: Text(
                glyph,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: tint,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
