import 'package:flutter/material.dart';

class AppPalette {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;

  final Color accentYellow;
  final Color accentCoral;
  final Color accentGreen;
  final Color accentBlue;

  final Color bgDeep;
  final Color bgMid;
  final Color bgCard;
  final Color bgCardLight;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color gold;
  final Color silver;
  final Color bronze;
  final Color gem;
  final Color xp;

  final Color success;
  final Color error;
  final Color warning;

  final Color timerCool;

  final Color cocoPrimary;
  final Color cocoSecondary;
  final Color katoPrimary;
  final Color katoSecondary;
  final Color sonaPrimary;
  final Color sonaSecondary;

  final LinearGradient backgroundGradient;
  final LinearGradient primaryGradient;
  final LinearGradient playGradient;
  final LinearGradient successGradient;

  List<Color> get characterPrimary => [cocoPrimary, katoPrimary, sonaPrimary];
  List<Color> get characterSecondary =>
      [cocoSecondary, katoSecondary, sonaSecondary];

  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accentYellow,
    required this.accentCoral,
    required this.accentGreen,
    required this.accentBlue,
    required this.bgDeep,
    required this.bgMid,
    required this.bgCard,
    required this.bgCardLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.gold,
    required this.silver,
    required this.bronze,
    required this.gem,
    required this.xp,
    required this.success,
    required this.error,
    required this.warning,
    required this.timerCool,
    required this.cocoPrimary,
    required this.cocoSecondary,
    required this.katoPrimary,
    required this.katoSecondary,
    required this.sonaPrimary,
    required this.sonaSecondary,
    required this.backgroundGradient,
    required this.primaryGradient,
    required this.playGradient,
    required this.successGradient,
  });

  // "Classic" — Cyber Slate dark theme (original app-wide default).
  static const AppPalette dark = AppPalette(
    primary: Color(0xFF22D3EE),
    primaryDark: Color(0xFF0E7490),
    primaryLight: Color(0xFF67E8F9),
    accentYellow: Color(0xFFFFD600),
    accentCoral: Color(0xFFEF4444),
    accentGreen: Color(0xFF10B981),
    accentBlue: Color(0xFF3B82F6),
    bgDeep: Color(0xFF0F172A),
    bgMid: Color(0xFF1E293B),
    bgCard: Color(0xFF1E293B),
    bgCardLight: Color(0xFF334155),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    gold: Color(0xFFFFD700),
    silver: Color(0xFFC0C0C0),
    bronze: Color(0xFFCD7F32),
    gem: Color(0xFF00E5FF),
    xp: Color(0xFF76FF03),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF97316),
    timerCool: Color(0xFF3B82F6),
    cocoPrimary: Color(0xFF06B6D4),
    cocoSecondary: Color(0xFF0EA5E9),
    katoPrimary: Color(0xFFF43F5E),
    katoSecondary: Color(0xFFF97316),
    sonaPrimary: Color(0xFFA855F7),
    sonaSecondary: Color(0xFF6366F1),
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    ),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF22D3EE), Color(0xFF67E8F9)],
    ),
    playGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B35), Color(0xFFFFD600)],
    ),
    successGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF10B981), Color(0xFF00E676)],
    ),
  );

  // "Playground" — light Sunny Cream theme (issue #22). See
  // docs/color-guidelines.md §2 for the rationale behind each value.
  static const AppPalette light = AppPalette(
    primary: Color(0xFF0F766E), // Deep Teal
    primaryDark: Color(0xFF0B5E57),
    primaryLight: Color(0xFF2DD4BF), // Teal Breeze — decorative/glow only
    accentYellow: Color(0xFFCA8A04), // Honey Gold — safe for text/icons
    accentCoral: Color(0xFFFB7185), // Warm Coral, same value as `error`
    accentGreen: Color(0xFF059669), // Meadow Green, same value as `success`
    accentBlue: Color(0xFF0EA5E9), // Sky Blue, same value as `timerCool`
    bgDeep: Color(0xFFFFFBF2), // Creamy Vanilla
    bgMid: Color(0xFFFFF3DC),
    bgCard: Color(0xFFFFFFFF),
    bgCardLight: Color(0xFFEDE0C8), // Warm Sand
    textPrimary: Color(0xFF3A2E22), // Espresso Ink
    textSecondary: Color(0xFF8A7A63), // Warm Taupe
    textMuted: Color(0xFFBFB093), // Soft Sand
    gold: Color(0xFFFFD700),
    silver: Color(0xFFC0C0C0),
    bronze: Color(0xFFCD7F32),
    gem: Color(0xFF00E5FF),
    xp: Color(0xFF76FF03),
    success: Color(0xFF059669),
    error: Color(0xFFFB7185),
    warning: Color(0xFFF97316),
    timerCool: Color(0xFF0EA5E9),
    cocoPrimary: Color(0xFF06B6D4),
    cocoSecondary: Color(0xFF0EA5E9),
    katoPrimary: Color(0xFFF43F5E),
    katoSecondary: Color(0xFFF97316),
    sonaPrimary: Color(0xFFA855F7),
    sonaSecondary: Color(0xFF6366F1),
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFBF2), Color(0xFFFFF3DC)],
    ),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F766E), Color(0xFF2DD4BF)],
    ),
    playGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFB7185), Color(0xFFFFD600)],
    ),
    successGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF059669), Color(0xFF34D399)],
    ),
  );
}
