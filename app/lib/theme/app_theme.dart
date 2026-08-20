import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_palette.dart';
import 'app_spacing.dart';

/// Material 3 ThemeData for both brightnesses, mapped 1:1 from the
/// handoff's "Theme-Mapping (Material 3)" card:
/// primary→#FFC49B, secondary→#E5B6F2, tertiary→#9BE8D8, error→#FF8A7A,
/// surface→#1A1615, surfaceContainer→#262120, outlineVariant→#38312D,
/// brightness: dark (default).
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);
  static ThemeData get light => _build(Brightness.light, AppPalette.light);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.secondary,
      onSecondary: p.onSecondary,
      tertiary: p.accentSafe,
      onTertiary: p.onAccentSafe,
      error: p.danger,
      onError: p.onDanger,
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerHighest: p.surfaceContainer,
      outline: p.outline,
      outlineVariant: p.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      fontFamily: 'SpaceGrotesk',
      splashFactory: InkRipple.splashFactory,
      extensions: [p],
      dividerColor: p.outlineVariant,
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.primary;
          return p.surfaceContainer;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.onPrimary;
          return p.textFaint;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return p.outline;
        }),
      ),
    );
  }

  /// Handoff-neutral colours that stay the same across brightness
  /// (category colour code — dark tokens are used directly as accents,
  /// light mode gets satter variants; both live in [AppColors.category]).
  static const chipRadius = AppRadius.chip;
}
