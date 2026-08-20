import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/app_text.dart';

/// Circular avatar with the player's initial, coloured by rotation index.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.initial,
    required this.colorIndex,
    this.size = 36,
    this.fontSize = 15,
  });

  final String initial;
  final int colorIndex;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fill = AvatarPalette.fill(colorIndex, brightness);
    final onFill = AvatarPalette.onFill(colorIndex, brightness);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(size * 0.33)),
      alignment: Alignment.center,
      child: Text(initial, style: AppText.nameLabel(onFill).copyWith(
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
      )),
    );
  }
}

/// Large round avatar (handoff / clue-turn / resolution screens).
class AvatarCircleRound extends StatelessWidget {
  const AvatarCircleRound({
    super.key,
    required this.initial,
    required this.colorIndex,
    this.size = 120,
    this.fontSize = 48,
  });

  final String initial;
  final int colorIndex;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fill = AvatarPalette.fill(colorIndex, brightness);
    final onFill = AvatarPalette.onFill(colorIndex, brightness);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initial, style: AppText.display(onFill).copyWith(fontSize: fontSize)),
    );
  }
}
