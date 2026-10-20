import 'package:flutter/material.dart';

/// Paper and ink. The light theme is warm off-white with near-black strokes,
/// the dark theme swaps the two instead of tinting everything, and one
/// terracotta accent carries anything interactive. Every pair clears 4.5:1 for
/// text and 3:1 for large text and controls, which the accessibility test
/// proves rather than assumes.
abstract final class HangmanColors {
  static const paper = Color(0xFFF4F1EA);
  static const paperRaised = Color(0xFFFFFDF8);
  static const ink = Color(0xFF1A1A17);
  static const inkSoft = Color(0xFF5A564D);
  static const rule = Color(0xFFCFC8B8);
  static const accent = Color(0xFFB4452E);
  static const correct = Color(0xFF2F6B4F);

  static const inkDark = Color(0xFF121210);
  static const inkDarkRaised = Color(0xFF1C1B18);
  static const paperDark = Color(0xFFEDE8DC);
  static const paperDarkSoft = Color(0xFFA49E90);
  static const ruleDark = Color(0xFF423E36);
  static const accentDark = Color(0xFFE08A6E);
  static const correctDark = Color(0xFF7FBF9B);
}

/// Shared shape language: nothing is a pill, nothing is a perfect circle.
abstract final class HangmanShapes {
  static const key = BorderRadius.all(Radius.circular(6));
  static const button = BorderRadius.all(Radius.circular(10));
  static const double keySize = 48;
  static const double buttonHeight = 56;
}

ThemeData hangmanLightTheme() => _theme(
  const ColorScheme(
    brightness: Brightness.light,
    primary: HangmanColors.accent,
    onPrimary: HangmanColors.paperRaised,
    secondary: HangmanColors.correct,
    onSecondary: HangmanColors.paperRaised,
    error: HangmanColors.accent,
    onError: HangmanColors.paperRaised,
    surface: HangmanColors.paper,
    onSurface: HangmanColors.ink,
    surfaceContainerHighest: HangmanColors.paperRaised,
    onSurfaceVariant: HangmanColors.inkSoft,
    outline: HangmanColors.rule,
  ),
);

ThemeData hangmanDarkTheme() => _theme(
  const ColorScheme(
    brightness: Brightness.dark,
    primary: HangmanColors.accentDark,
    onPrimary: HangmanColors.inkDark,
    secondary: HangmanColors.correctDark,
    onSecondary: HangmanColors.inkDark,
    error: HangmanColors.accentDark,
    onError: HangmanColors.inkDark,
    surface: HangmanColors.inkDark,
    onSurface: HangmanColors.paperDark,
    surfaceContainerHighest: HangmanColors.inkDarkRaised,
    onSurfaceVariant: HangmanColors.paperDarkSoft,
    outline: HangmanColors.ruleDark,
  ),
);

ThemeData _theme(ColorScheme colors) {
  final base = ThemeData(colorScheme: colors, useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: colors.surface,
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: colors.onSurface,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: colors.onSurfaceVariant,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        height: 1.55,
        color: colors.onSurface,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size.fromHeight(HangmanShapes.buttonHeight),
        shape: const RoundedRectangleBorder(borderRadius: HangmanShapes.button),
        textStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.onSurface,
        minimumSize: const Size.fromHeight(HangmanShapes.buttonHeight),
        shape: const RoundedRectangleBorder(borderRadius: HangmanShapes.button),
        textStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.outline, width: 1.5),
        minimumSize: const Size.fromHeight(HangmanShapes.buttonHeight),
        shape: const RoundedRectangleBorder(borderRadius: HangmanShapes.button),
        textStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: HangmanShapes.button,
        borderSide: BorderSide(color: colors.outline, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: HangmanShapes.button,
        borderSide: BorderSide(color: colors.outline, width: 1.5),
      ),
    ),
  );
}
