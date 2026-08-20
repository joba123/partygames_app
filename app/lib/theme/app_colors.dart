import 'package:flutter/material.dart';

/// Which of the five game categories a tile/chip belongs to.
/// Colour-codes every game across the hub, filters and settings.
enum GameCategory { klassiker, neu, fuerMutige, redenUndRaten, schnell }

extension GameCategoryLabel on GameCategory {
  String get label => switch (this) {
        GameCategory.klassiker => 'Klassiker',
        GameCategory.neu => 'Neu',
        GameCategory.fuerMutige => 'Für Mutige',
        GameCategory.redenUndRaten => 'Reden & Raten',
        GameCategory.schnell => 'Schnell',
      };
}

/// Dark palette (default) and light pendants, lifted 1:1 from the
/// Claude Design handoff's Design-System section.
class AppColors {
  AppColors._();

  // Dark — default
  static const darkPrimary = Color(0xFFFFC49B);
  static const darkOnPrimary = Color(0xFF2B1A0E);
  static const darkSecondary = Color(0xFFE5B6F2);
  static const darkOnSecondary = Color(0xFF2A1430);
  static const darkAccentSafe = Color(0xFF9BE8D8);
  static const darkOnAccentSafe = Color(0xFF0E2C26);
  static const darkDanger = Color(0xFFFF8A7A);
  static const darkOnDanger = Color(0xFF3A100A);
  static const darkWarning = Color(0xFFFFE28A);
  static const darkOnWarning = Color(0xFF33280A);

  static const darkBackground = Color(0xFF0D0B0A);
  static const darkSurface = Color(0xFF1A1615);
  static const darkSurfaceContainer = Color(0xFF262120);
  static const darkOutline = Color(0xFF38312D);
  static const darkOutlineVariant = Color(0xFF2E2724);

  static const darkTextPrimary = Color(0xFFF7F1EA);
  static const darkTextSecondary = Color(0xFFB6ABA3);
  static const darkTextMuted = Color(0xFF9A8F87);
  static const darkTextFaint = Color(0xFF8A7F77);
  static const darkTextDim = Color(0xFF6F655F);

  // Light pendants
  static const lightPrimary = Color(0xFFC2643A);
  static const lightOnPrimary = Color(0xFFFFF7F0);
  static const lightSecondary = Color(0xFF7B3E96);
  static const lightOnSecondary = Color(0xFFFFF7F0);
  static const lightAccentSafe = Color(0xFF0F7A66);
  static const lightOnAccentSafe = Color(0xFFE4F7F2);
  static const lightDanger = Color(0xFFC2402A);
  static const lightOnDanger = Color(0xFFFFF7F0);
  static const lightWarning = Color(0xFF9A7100);
  static const lightOnWarning = Color(0xFFFFF7E0);

  static const lightBackground = Color(0xFFFFF7F0);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceContainer = Color(0xFFFFF1E7);
  static const lightOutline = Color(0xFFE7DBD1);
  static const lightOutlineVariant = Color(0xFFE7DBD1);

  static const lightTextPrimary = Color(0xFF241A14);
  static const lightTextSecondary = Color(0xFF6B564A);
  static const lightTextMuted = Color(0xFF8A7364);
  static const lightTextFaint = Color(0xFFA2907F);
  static const lightTextDim = Color(0xFFA2907F);

  /// Solid category accent colour (dark-mode token colour / light "on" colour).
  static Color category(GameCategory c, Brightness b) {
    final dark = b == Brightness.dark;
    return switch (c) {
      GameCategory.klassiker => dark ? darkPrimary : lightPrimary,
      GameCategory.neu => dark ? darkAccentSafe : lightAccentSafe,
      GameCategory.fuerMutige => dark ? darkDanger : lightDanger,
      GameCategory.redenUndRaten => dark ? darkSecondary : lightSecondary,
      GameCategory.schnell => dark ? darkWarning : lightWarning,
    };
  }

  /// Soft tinted background for chips/icon tiles per category.
  static Color categoryTint(GameCategory c, Brightness b) {
    if (b == Brightness.dark) {
      return category(c, b).withValues(alpha: .14);
    }
    return switch (c) {
      GameCategory.klassiker => const Color(0xFFFFF1E7),
      GameCategory.neu => const Color(0xFFE4F7F2),
      GameCategory.fuerMutige => const Color(0xFFFBE4E1),
      GameCategory.redenUndRaten => const Color(0xFFF7EDFB),
      GameCategory.schnell => const Color(0xFFFFF7E0),
    };
  }
}
