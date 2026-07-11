import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle display(AppPalette c) => GoogleFonts.fredoka(
        fontSize: 52,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle headline1(AppPalette c) => GoogleFonts.fredoka(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
      );

  static TextStyle headline2(AppPalette c) => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
      );

  static TextStyle headline3(AppPalette c) => GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
      );

  static TextStyle bodyLarge(AppPalette c) => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: c.textSecondary,
      );

  static TextStyle body(AppPalette c) => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: c.textSecondary,
      );

  static TextStyle label(AppPalette c) => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: c.textMuted,
        letterSpacing: 0.5,
      );

  static TextStyle statNumber(AppPalette c) => GoogleFonts.fredoka(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
      );

  static TextStyle buttonText(AppPalette c) => GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
        letterSpacing: 1.2,
      );

  // Big question numbers shown during gameplay
  static TextStyle gameQuestion(AppPalette c) => GoogleFonts.fredoka(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
      );

  static TextStyle gameAnswer(AppPalette c) => GoogleFonts.fredoka(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: c.textPrimary,
      );
}
