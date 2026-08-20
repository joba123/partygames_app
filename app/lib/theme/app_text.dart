import 'package:flutter/material.dart';

/// Type scale from the handoff: Space Grotesk for everything spoken,
/// JetBrains Mono for counters/timers/role-codes/labels.
/// Body never below 15px, in-game content 24–44px.
class AppText {
  AppText._();

  static const _grotesk = 'SpaceGrotesk';
  static const _mono = 'JetBrainsMono';

  static TextStyle display(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w700,
        fontSize: 44,
        height: 1.0,
        letterSpacing: -44 * 0.03,
        color: color,
      );

  static TextStyle headline(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w700,
        fontSize: 30,
        height: 34 / 30,
        letterSpacing: -30 * 0.02,
        color: color,
      );

  static TextStyle title(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 26 / 22,
        letterSpacing: -22 * 0.02,
        color: color,
      );

  static TextStyle body(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w400,
        fontSize: 17,
        height: 26 / 17,
        color: color,
      );

  static TextStyle bodySmall(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 1.5,
        color: color,
      );

  static TextStyle caption(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w400,
        fontSize: 13,
        height: 1.4,
        color: color,
      );

  static TextStyle buttonLabel(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        height: 20 / 15,
        color: color,
      );

  static TextStyle buttonLabelLarge(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w600,
        fontSize: 17,
        height: 1.0,
        color: color,
      );

  static TextStyle nameLabel(Color color) => TextStyle(
        fontFamily: _grotesk,
        fontWeight: FontWeight.w500,
        fontSize: 17,
        height: 1.0,
        color: color,
      );

  /// Mono label — pass already-uppercased text (Dart doesn't auto-transform).
  static TextStyle labelMono(Color color, {double size = 12}) => TextStyle(
        fontFamily: _mono,
        fontWeight: FontWeight.w500,
        fontSize: size,
        height: 1.0,
        letterSpacing: size * 0.12,
        color: color,
      );

  static TextStyle monoValue(Color color, {double size = 15, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
        fontFamily: _mono,
        fontWeight: weight,
        fontSize: size,
        height: 1.0,
        color: color,
      );

  static TextStyle monoDisplay(Color color, {double size = 68}) => TextStyle(
        fontFamily: _mono,
        fontWeight: FontWeight.w700,
        fontSize: size,
        height: 1.0,
        letterSpacing: -size * 0.02,
        color: color,
      );
}
