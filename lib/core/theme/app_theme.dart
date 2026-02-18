import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

class AppTheme {
  static ThemeData light() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppTokens.laurel,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      headlineLarge: GoogleFonts.baloo2(
        fontWeight: FontWeight.w700,
        color: AppTokens.deepInk,
      ),
      headlineMedium: GoogleFonts.baloo2(
        fontWeight: FontWeight.w700,
        color: AppTokens.deepInk,
      ),
      titleLarge: GoogleFonts.baloo2(
        fontWeight: FontWeight.w700,
        color: AppTokens.deepInk,
      ),
      bodyLarge: GoogleFonts.nunito(color: AppTokens.deepInk),
      bodyMedium: GoogleFonts.nunito(color: AppTokens.deepInk),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme.copyWith(
        primary: AppTokens.laurel,
        secondary: AppTokens.terracotta,
        surface: AppTokens.parchment,
        onSurface: AppTokens.deepInk,
      ),
      scaffoldBackgroundColor: AppTokens.parchment,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppTokens.parchment,
        foregroundColor: AppTokens.deepInk,
        elevation: 0,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppTokens.deepInk,
        ),
      ),
      cardTheme: CardTheme(
        color: AppTokens.warmMarble,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTokens.borderSoft),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTokens.borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTokens.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTokens.laurel, width: 1.8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.deepInk,
        contentTextStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
