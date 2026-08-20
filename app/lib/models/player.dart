import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Player {
  Player({required this.id, required this.name});

  final String id;
  String name;

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

/// Fixed rotation of avatar colours (cycles for player 6+), matching the
/// L/J/M/T/S avatars used throughout the screens.
class AvatarPalette {
  AvatarPalette._();

  static List<Color> fills(Brightness b) => b == Brightness.dark
      ? const [
          AppColors.darkPrimary,
          AppColors.darkSecondary,
          AppColors.darkAccentSafe,
          AppColors.darkWarning,
          Color(0xFFC9A6F2),
        ]
      : const [
          AppColors.lightPrimary,
          AppColors.lightSecondary,
          AppColors.lightAccentSafe,
          AppColors.lightWarning,
          Color(0xFF9A5EC2),
        ];

  static List<Color> onFills(Brightness b) => b == Brightness.dark
      ? const [
          AppColors.darkOnPrimary,
          AppColors.darkOnSecondary,
          AppColors.darkOnAccentSafe,
          AppColors.darkOnWarning,
          Color(0xFF241038),
        ]
      : const [
          AppColors.lightOnPrimary,
          AppColors.lightOnSecondary,
          AppColors.lightOnAccentSafe,
          AppColors.lightOnWarning,
          Color(0xFFFFF7F0),
        ];

  static Color fill(int index, Brightness b) => fills(b)[index % fills(b).length];
  static Color onFill(int index, Brightness b) => onFills(b)[index % onFills(b).length];
}
