import 'package:flutter/material.dart';

class AppColors {
  // Core brand — Bito Cyan (Electric)
  static const Color primary = Color(0xFF22D3EE);
  static const Color primaryDark = Color(0xFF0E7490);
  static const Color primaryLight = Color(0xFF67E8F9);

  // Accent palette
  static const Color accentYellow = Color(0xFFFFD600);
  static const Color accentCoral = Color(0xFFEF4444);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);

  // Backgrounds — Cyber Slate (dark/kids mode)
  static const Color bgDeep = Color(0xFF0F172A);
  static const Color bgMid = Color(0xFF1E293B);
  static const Color bgCard = Color(0xFF1E293B);
  static const Color bgCardLight = Color(0xFF334155);

  // Text (dark mode)
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Reward tiers
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color gem = Color(0xFF00E5FF);
  static const Color xp = Color(0xFF76FF03);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF97316);

  // Timer ring — Cool Blue, transitions to warning orange under 5s
  static const Color timerCool = Color(0xFF3B82F6);

  // Character brand colors
  static const Color cocoPrimary = Color(0xFF06B6D4); // Turquoise Glow
  static const Color cocoSecondary = Color(0xFF0EA5E9); // Teal Breeze
  static const Color katoPrimary = Color(0xFFF43F5E); // Rocket Coral
  static const Color katoSecondary = Color(0xFFF97316); // Electric Orange
  static const Color sonaPrimary = Color(0xFFA855F7); // Cosmic Violet
  static const Color sonaSecondary = Color(0xFF6366F1); // Digital Indigo

  static const List<Color> characterPrimary = [cocoPrimary, katoPrimary, sonaPrimary];
  static const List<Color> characterSecondary = [cocoSecondary, katoSecondary, sonaSecondary];

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
    colors: [Color(0xFF10B981), Color(0xFF00E676)],
  );
}
