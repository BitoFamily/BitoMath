import 'package:flutter/material.dart';

class AppColors {
  // Primary purple
  static const Color primary = Color(0xFF6C3CE1);
  static const Color primaryDark = Color(0xFF4A1FA8);
  static const Color primaryLight = Color(0xFF9B6FFF);

  // Accent palette
  static const Color accentYellow = Color(0xFFFFD600);
  static const Color accentCoral = Color(0xFFFF5757);
  static const Color accentGreen = Color(0xFF00C853);
  static const Color accentBlue = Color(0xFF00B4FF);

  // Backgrounds
  static const Color bgDeep = Color(0xFF0F0C29);
  static const Color bgMid = Color(0xFF302B63);
  static const Color bgCard = Color(0xFF1E1A4B);
  static const Color bgCardLight = Color(0xFF2A2660);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCDC4F0);
  static const Color textMuted = Color(0xFF8A82B4);

  // Reward tiers
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color gem = Color(0xFF00E5FF);
  static const Color xp = Color(0xFF76FF03);

  // Semantic
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB00);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDeep, bgMid],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient playGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFFD600)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
  );
}
