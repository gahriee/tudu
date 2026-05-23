import 'package:flutter/material.dart';

class AppColors {
  static const primary        = Color(0xFFEA580C);
  static const primaryDark    = Color(0xFFFB923C);
  static const secondary      = Color(0xFF0D9488);
  static const secondaryDark  = Color(0xFF2DD4BF);

  static const background     = Color(0xFFFFF7ED);
  static const backgroundDark = Color(0xFF0C0A09);
  static const surface        = Color(0xFFFFFFFF);
  static const surfaceDark    = Color(0xFF1C1917);

  static const textPrimary    = Color(0xFF1C1917);
  static const textDark       = Color(0xFFFAFAF9);
  static const textSecondary  = Color(0xFF78716C);

  static const outline        = Color(0xFFFED7AA);
  static const outlineDark    = Color(0xFF292524);

  static const error          = Color(0xFFDC2626);
}

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary:   AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    surface:   AppColors.surface,
    error:     AppColors.error,
    outline:   AppColors.outline,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.outline),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary:   AppColors.primaryDark,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryDark,
    surface:   AppColors.surfaceDark,
    error:     Color(0xFFF87171),
    outline:   AppColors.outlineDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textDark,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.outlineDark),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outlineDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
    ),
  ),
);
