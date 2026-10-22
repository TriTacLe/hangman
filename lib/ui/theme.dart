import 'package:flutter/material.dart';

/// Black on white, green for a letter in the word and red for one that is not,
/// with the contrast numbers asserted in test/accessibility_test.dart.
abstract final class HangmanColors {
  static const paper = Color(0xFFFFFFFF);
  static const ink = Color(0xFF000000);
  static const inkSoft = Color(0xFF666666);
  static const hit = Color(0xFF008000);
  static const miss = Color(0xFFFF0000);

  static const paperDark = Color(0xFF000000);
  static const inkDark = Color(0xFFFFFFFF);
  static const inkDarkSoft = Color(0xFFAAAAAA);
  static const hitDark = Color(0xFF00FF00);
}

/// A heavier border is how a key says it was a hit, so weight carries the
/// meaning and colour only agrees.
abstract final class HangmanShapes {
  static const BorderRadius key = BorderRadius.all(Radius.circular(8));
  static const BorderRadius button = BorderRadius.all(Radius.circular(12));
  static const double keySize = 48;
  static const double buttonHeight = 56;
  static const double border = 2;
  static const double borderHeavy = 4;

  /// Spacing steps, deliberately uneven so the rhythm is composed rather than
  /// one gap repeated everywhere.
  static const double tight = 6;
  static const double snug = 12;
  static const double gap = 20;
  static const double loose = 36;
  static const double chapter = 56;
}

ThemeData hangmanLightTheme() => _theme(
  const ColorScheme(
    brightness: Brightness.light,
    primary: HangmanColors.ink,
    onPrimary: HangmanColors.paper,
    secondary: HangmanColors.hit,
    onSecondary: HangmanColors.paper,
    error: HangmanColors.miss,
    onError: HangmanColors.paper,
    surface: HangmanColors.paper,
    onSurface: HangmanColors.ink,
    surfaceContainerHighest: HangmanColors.paper,
    onSurfaceVariant: HangmanColors.inkSoft,
    outline: HangmanColors.ink,
  ),
);

ThemeData hangmanDarkTheme() => _theme(
  const ColorScheme(
    brightness: Brightness.dark,
    primary: HangmanColors.inkDark,
    onPrimary: HangmanColors.paperDark,
    secondary: HangmanColors.hitDark,
    onSecondary: HangmanColors.paperDark,
    error: HangmanColors.miss,
    onError: HangmanColors.paperDark,
    surface: HangmanColors.paperDark,
    onSurface: HangmanColors.inkDark,
    surfaceContainerHighest: HangmanColors.paperDark,
    onSurfaceVariant: HangmanColors.inkDarkSoft,
    outline: HangmanColors.inkDark,
  ),
);

ThemeData _theme(ColorScheme colors) {
  // Condensed, so the type is not the Roboto every Flutter app opens with.
  final base = ThemeData(
    colorScheme: colors,
    useMaterial3: true,
    fontFamily: 'sans-serif-condensed',
  );

  final label = base.textTheme.labelLarge?.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: colors.onSurface,
  );

  return base.copyWith(
    scaffoldBackgroundColor: colors.surface,
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        height: 1,
        color: colors.onSurface,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: colors.onSurface,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      titleSmall: label,
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 17,
        height: 1.6,
        color: colors.onSurface,
      ),
      labelLarge: label,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.onSurface,
      foregroundColor: colors.surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        color: colors.surface,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size.fromHeight(HangmanShapes.buttonHeight),
        shape: const RoundedRectangleBorder(borderRadius: HangmanShapes.button),
        textStyle: label?.copyWith(color: colors.onPrimary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.onSurface,
        minimumSize: const Size.fromHeight(HangmanShapes.buttonHeight),
        shape: const RoundedRectangleBorder(borderRadius: HangmanShapes.button),
        textStyle: label,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.outline, width: HangmanShapes.border),
        minimumSize: const Size.fromHeight(HangmanShapes.buttonHeight),
        shape: const RoundedRectangleBorder(borderRadius: HangmanShapes.button),
        textStyle: label,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.outline,
      thickness: HangmanShapes.border,
      space: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: HangmanShapes.button,
        side: BorderSide(color: colors.outline, width: HangmanShapes.border),
      ),
    ),
  );
}
