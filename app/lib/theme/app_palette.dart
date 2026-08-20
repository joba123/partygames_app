import 'package:flutter/material.dart';
import 'app_colors.dart';

/// All the tokens a screen needs, resolved for the current brightness.
/// Kept as a ThemeExtension so every widget can do
/// `context.palette` instead of re-deriving light/dark branches everywhere.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.outline,
    required this.outlineVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.textDim,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.accentSafe,
    required this.onAccentSafe,
    required this.danger,
    required this.onDanger,
    required this.warning,
    required this.onWarning,
  });

  final Color background;
  final Color surface;
  final Color surfaceContainer;
  final Color outline;
  final Color outlineVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textFaint;
  final Color textDim;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color accentSafe;
  final Color onAccentSafe;
  final Color danger;
  final Color onDanger;
  final Color warning;
  final Color onWarning;

  static const dark = AppPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceContainer: AppColors.darkSurfaceContainer,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkOutlineVariant,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    textFaint: AppColors.darkTextFaint,
    textDim: AppColors.darkTextDim,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkOnSecondary,
    accentSafe: AppColors.darkAccentSafe,
    onAccentSafe: AppColors.darkOnAccentSafe,
    danger: AppColors.darkDanger,
    onDanger: AppColors.darkOnDanger,
    warning: AppColors.darkWarning,
    onWarning: AppColors.darkOnWarning,
  );

  static const light = AppPalette(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceContainer: AppColors.lightSurfaceContainer,
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    textFaint: AppColors.lightTextFaint,
    textDim: AppColors.lightTextDim,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    secondary: AppColors.lightSecondary,
    onSecondary: AppColors.lightOnSecondary,
    accentSafe: AppColors.lightAccentSafe,
    onAccentSafe: AppColors.lightOnAccentSafe,
    danger: AppColors.lightDanger,
    onDanger: AppColors.lightOnDanger,
    warning: AppColors.lightWarning,
    onWarning: AppColors.lightOnWarning,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceContainer,
    Color? outline,
    Color? outlineVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textFaint,
    Color? textDim,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? accentSafe,
    Color? onAccentSafe,
    Color? danger,
    Color? onDanger,
    Color? warning,
    Color? onWarning,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      textDim: textDim ?? this.textDim,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      accentSafe: accentSafe ?? this.accentSafe,
      onAccentSafe: onAccentSafe ?? this.onAccentSafe,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceContainer: c(surfaceContainer, other.surfaceContainer),
      outline: c(outline, other.outline),
      outlineVariant: c(outlineVariant, other.outlineVariant),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      textFaint: c(textFaint, other.textFaint),
      textDim: c(textDim, other.textDim),
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      secondary: c(secondary, other.secondary),
      onSecondary: c(onSecondary, other.onSecondary),
      accentSafe: c(accentSafe, other.accentSafe),
      onAccentSafe: c(onAccentSafe, other.onAccentSafe),
      danger: c(danger, other.danger),
      onDanger: c(onDanger, other.onDanger),
      warning: c(warning, other.warning),
      onWarning: c(onWarning, other.onWarning),
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
