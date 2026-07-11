import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);
  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData _build(AppPalette c, Brightness brightness) {
    final colorScheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: c.primary,
            secondary: c.accentYellow,
            surface: c.bgCard,
            error: c.error,
          )
        : ColorScheme.light(
            primary: c.primary,
            secondary: c.accentYellow,
            surface: c.bgCard,
            error: c.error,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.bgDeep,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.nunitoTextTheme(
        brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme,
      ),
      cardTheme: CardThemeData(
        color: c.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      iconTheme: IconThemeData(color: c.textSecondary),
      dividerColor: c.bgCardLight,
    );
  }
}
