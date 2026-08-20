import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One glyph per game.
///
/// The handoff's icon system asks for a 24-grid built from circles, rounded
/// rects, triangles and lines. This set keeps that vocabulary but draws every
/// glyph in two tones: a filled silhouette in a washed-out accent carries the
/// mass, crisp contours in the full accent carry the detail. Flat outlines
/// disappeared against the tinted medallions on the hub — a body behind them
/// makes each game readable at a glance in a dark room.
enum GameIconType {
  impostor,
  truthOrDare,
  wouldRather,
  neverHaveIEver,
  bomb,
  roulette,
  charade,
  duel,
  quiz,
  taboo,
  liar,
  fakeFact,
  bet,
  werewolf,
  hundredQuestions,
  tenOutOfTen,
  circa,
}

class GameIconGlyph extends StatelessWidget {
  const GameIconGlyph({super.key, required this.type, required this.color, this.size = 26});

  final GameIconType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GameIconPainter(type: type, color: color)),
    );
  }
}

class _GameIconPainter extends CustomPainter {
  _GameIconPainter({required this.type, required this.color});

  final GameIconType type;
  final Color color;

  /// Alpha of the filled body. High enough to read as a shape, low enough
  /// that the contour on top still separates from it.
  static const _bodyAlpha = 0.30;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final body = Paint()..color = color.withValues(alpha: _bodyAlpha);
    final solid = Paint()..color = color;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final hair = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final center = Offset(s / 2, s / 2);

    Offset at(double x, double y) => Offset(s * x, s * y);

    switch (type) {
      // Masked face — the notch along the lower edge keeps the band from
      // reading as a no-entry sign.
      case GameIconType.impostor:
        canvas.drawCircle(center, s * 0.42, body);
        canvas.drawCircle(center, s * 0.42, line);
        final mask = Path()
          ..moveTo(s * 0.15, s * 0.40)
          ..quadraticBezierTo(s * 0.15, s * 0.34, s * 0.22, s * 0.34)
          ..lineTo(s * 0.78, s * 0.34)
          ..quadraticBezierTo(s * 0.85, s * 0.34, s * 0.85, s * 0.40)
          ..lineTo(s * 0.85, s * 0.46)
          ..quadraticBezierTo(s * 0.85, s * 0.58, s * 0.71, s * 0.58)
          ..quadraticBezierTo(s * 0.58, s * 0.58, s * 0.50, s * 0.45)
          ..quadraticBezierTo(s * 0.42, s * 0.58, s * 0.29, s * 0.58)
          ..quadraticBezierTo(s * 0.15, s * 0.58, s * 0.15, s * 0.46)
          ..close();
        canvas.drawPath(mask, solid);
        break;

      // A coin mid-flip: one circle, two halves, one of them committed.
      case GameIconType.truthOrDare:
        final r = s * 0.42;
        canvas.drawCircle(center, r, body);
        final half = Path()
          ..moveTo(center.dx, center.dy - r)
          ..arcToPoint(Offset(center.dx, center.dy + r), radius: Radius.circular(r), clockwise: false)
          ..close();
        canvas.drawPath(half, solid);
        canvas.drawCircle(center, r, line);
        break;

      // Three heads with the group's finger aimed at the middle one.
      case GameIconType.wouldRather:
        const y = 0.68;
        for (final x in const [0.16, 0.84]) {
          canvas.drawCircle(at(x, y), s * 0.125, body);
          canvas.drawCircle(at(x, y), s * 0.125, hair);
        }
        canvas.drawCircle(at(0.50, y), s * 0.165, solid);
        final chevron = Path()
          ..moveTo(s * 0.34, s * 0.16)
          ..lineTo(s * 0.50, s * 0.38)
          ..lineTo(s * 0.66, s * 0.16);
        canvas.drawPath(chevron, line);
        break;

      // A glass filled to the line — who has done it, drinks.
      case GameIconType.neverHaveIEver:
        final glass = Path()
          ..moveTo(s * 0.24, s * 0.16)
          ..lineTo(s * 0.76, s * 0.16)
          ..lineTo(s * 0.63, s * 0.86)
          ..lineTo(s * 0.37, s * 0.86)
          ..close();
        final fill = Path()
          ..moveTo(s * 0.305, s * 0.46)
          ..lineTo(s * 0.695, s * 0.46)
          ..lineTo(s * 0.63, s * 0.86)
          ..lineTo(s * 0.37, s * 0.86)
          ..close();
        canvas.drawPath(fill, body);
        canvas.drawPath(glass, line);
        canvas.drawLine(at(0.305, 0.46), at(0.695, 0.46), hair);
        break;

      // Round body, screw cap, curling fuse, spark.
      case GameIconType.bomb:
        canvas.drawCircle(at(0.42, 0.66), s * 0.30, body);
        canvas.drawCircle(at(0.42, 0.66), s * 0.30, line);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.32, s * 0.27, s * 0.20, s * 0.11),
            Radius.circular(s * 0.035),
          ),
          solid,
        );
        final fuse = Path()
          ..moveTo(s * 0.52, s * 0.31)
          ..quadraticBezierTo(s * 0.72, s * 0.30, s * 0.74, s * 0.15);
        canvas.drawPath(fuse, hair);
        for (var i = 0; i < 5; i++) {
          final a = (2 * math.pi / 5) * i - math.pi / 2;
          canvas.drawLine(
            at(0.76 + math.cos(a) * 0.05, 0.12 + math.sin(a) * 0.05),
            at(0.76 + math.cos(a) * 0.12, 0.12 + math.sin(a) * 0.12),
            hair,
          );
        }
        break;

      // Wheel with spokes and the ball resting on the rim.
      case GameIconType.roulette:
        final r = s * 0.42;
        canvas.drawCircle(center, r, body);
        canvas.drawCircle(center, r, line);
        for (var i = 0; i < 4; i++) {
          final a = (math.pi / 4) * (2 * i + 1);
          canvas.drawLine(
            Offset(center.dx + math.cos(a) * r * 0.24, center.dy + math.sin(a) * r * 0.24),
            Offset(center.dx + math.cos(a) * r * 0.94, center.dy + math.sin(a) * r * 0.94),
            hair,
          );
        }
        canvas.drawCircle(Offset(center.dx, center.dy - r * 0.60), s * 0.085, solid);
        break;

      // A figure mid-gesture: acting, not talking.
      case GameIconType.charade:
        canvas.drawCircle(at(0.50, 0.24), s * 0.155, body);
        canvas.drawCircle(at(0.50, 0.24), s * 0.155, line);
        final figure = Path()
          ..moveTo(s * 0.50, s * 0.41)
          ..lineTo(s * 0.50, s * 0.70)
          ..moveTo(s * 0.50, s * 0.70)
          ..lineTo(s * 0.32, s * 0.91)
          ..moveTo(s * 0.50, s * 0.70)
          ..lineTo(s * 0.68, s * 0.91)
          ..moveTo(s * 0.20, s * 0.44)
          ..lineTo(s * 0.50, s * 0.53)
          ..lineTo(s * 0.82, s * 0.35);
        canvas.drawPath(figure, line);
        break;

      // Two contenders, one bolt between them.
      case GameIconType.duel:
        for (final x in const [0.17, 0.83]) {
          canvas.drawCircle(at(x, 0.5), s * 0.15, body);
          canvas.drawCircle(at(x, 0.5), s * 0.15, line);
        }
        final bolt = Path()
          ..moveTo(s * 0.60, s * 0.10)
          ..lineTo(s * 0.39, s * 0.53)
          ..lineTo(s * 0.50, s * 0.53)
          ..lineTo(s * 0.40, s * 0.90)
          ..lineTo(s * 0.62, s * 0.45)
          ..lineTo(s * 0.51, s * 0.45)
          ..close();
        canvas.drawPath(bolt, solid);
        break;

      // Buzzer card with a question mark punched into it.
      case GameIconType.quiz:
        final card = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.13, s * 0.08, s * 0.74, s * 0.84),
          Radius.circular(s * 0.22),
        );
        canvas.drawRRect(card, body);
        canvas.drawRRect(card, line);
        final hook = Path()
          ..moveTo(s * 0.34, s * 0.36)
          ..arcToPoint(Offset(s * 0.63, s * 0.43), radius: Radius.circular(s * 0.16), clockwise: true)
          ..quadraticBezierTo(s * 0.63, s * 0.54, s * 0.50, s * 0.60)
          ..lineTo(s * 0.50, s * 0.67);
        canvas.drawPath(hook, line);
        canvas.drawCircle(at(0.50, 0.79), s * 0.058, solid);
        break;

      // Speech bubble, struck through — the words you may not say.
      case GameIconType.taboo:
        final bubble = Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.10, s * 0.18, s * 0.80, s * 0.52),
            Radius.circular(s * 0.16),
          ))
          ..moveTo(s * 0.30, s * 0.70)
          ..lineTo(s * 0.30, s * 0.90)
          ..lineTo(s * 0.48, s * 0.70);
        canvas.drawPath(bubble, body);
        canvas.drawPath(bubble, line);
        canvas.drawLine(at(0.20, 0.64), at(0.80, 0.24), line);
        break;

      // Magnifier with someone caught in the lens.
      case GameIconType.liar:
        final lens = at(0.42, 0.42);
        canvas.drawCircle(lens, s * 0.30, body);
        canvas.drawCircle(lens, s * 0.30, line);
        canvas.drawCircle(lens, s * 0.115, solid);
        canvas.drawLine(at(0.64, 0.64), at(0.89, 0.89), line);
        break;

      // True next to false, each on its own card.
      case GameIconType.fakeFact:
        final left = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.04, s * 0.22, s * 0.42, s * 0.56),
          Radius.circular(s * 0.13),
        );
        final right = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.54, s * 0.22, s * 0.42, s * 0.56),
          Radius.circular(s * 0.13),
        );
        canvas.drawRRect(left, body);
        canvas.drawRRect(left, hair);
        canvas.drawRRect(right, hair);
        final check = Path()
          ..moveTo(s * 0.13, s * 0.50)
          ..lineTo(s * 0.22, s * 0.61)
          ..lineTo(s * 0.37, s * 0.38);
        canvas.drawPath(check, line);
        canvas.drawLine(at(0.63, 0.38), at(0.87, 0.62), line);
        canvas.drawLine(at(0.87, 0.38), at(0.63, 0.62), line);
        break;

      // A stack of chips and the direction the bidding goes.
      case GameIconType.bet:
        for (final y in const [0.82, 0.59, 0.36]) {
          final chip = Rect.fromCenter(center: at(0.33, y), width: s * 0.56, height: s * 0.15);
          canvas.drawOval(chip, body);
          canvas.drawOval(chip, hair);
        }
        final arrow = Path()
          ..moveTo(s * 0.82, s * 0.80)
          ..lineTo(s * 0.82, s * 0.22)
          ..moveTo(s * 0.71, s * 0.35)
          ..lineTo(s * 0.82, s * 0.20)
          ..lineTo(s * 0.93, s * 0.35);
        canvas.drawPath(arrow, line);
        break;

      // Wolf head. Tall pointed ears and a tapered snout, plus angled brows —
      // without the brows a symmetrical animal head reads as a house cat.
      case GameIconType.werewolf:
        final head = Path()
          ..moveTo(s * 0.08, s * 0.02)
          ..lineTo(s * 0.28, s * 0.34)
          ..lineTo(s * 0.72, s * 0.34)
          ..lineTo(s * 0.92, s * 0.02)
          ..lineTo(s * 0.88, s * 0.48)
          ..cubicTo(s * 0.88, s * 0.66, s * 0.72, s * 0.74, s * 0.62, s * 0.80)
          ..lineTo(s * 0.50, s * 0.97)
          ..lineTo(s * 0.38, s * 0.80)
          ..cubicTo(s * 0.28, s * 0.74, s * 0.12, s * 0.66, s * 0.12, s * 0.48)
          ..close();
        canvas.drawPath(head, body);
        canvas.drawPath(head, line);
        canvas.drawCircle(at(0.35, 0.55), s * 0.06, solid);
        canvas.drawCircle(at(0.65, 0.55), s * 0.06, solid);
        canvas.drawLine(at(0.24, 0.44), at(0.43, 0.51), hair);
        canvas.drawLine(at(0.76, 0.44), at(0.57, 0.51), hair);
        final snout = Path()
          ..moveTo(s * 0.44, s * 0.74)
          ..lineTo(s * 0.56, s * 0.74)
          ..lineTo(s * 0.50, s * 0.83)
          ..close();
        canvas.drawPath(snout, solid);
        break;

      // Two bubbles talking back and forth.
      case GameIconType.hundredQuestions:
        final back = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.30, s * 0.06, s * 0.64, s * 0.42),
          Radius.circular(s * 0.14),
        );
        canvas.drawRRect(back, body);
        canvas.drawRRect(back, hair);
        final front = Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.06, s * 0.38, s * 0.64, s * 0.42),
            Radius.circular(s * 0.14),
          ))
          ..moveTo(s * 0.22, s * 0.80)
          ..lineTo(s * 0.22, s * 0.96)
          ..lineTo(s * 0.38, s * 0.80);
        canvas.drawPath(front, body);
        canvas.drawPath(front, line);
        for (final x in const [0.22, 0.38, 0.54]) {
          canvas.drawCircle(at(x, 0.59), s * 0.045, solid);
        }
        break;

      // A rating star.
      case GameIconType.tenOutOfTen:
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final a = -math.pi / 2 + i * math.pi / 5;
          final r = i.isEven ? 0.46 : 0.19;
          final point = Offset(center.dx + math.cos(a) * s * r, center.dy + math.sin(a) * s * r);
          if (i == 0) {
            star.moveTo(point.dx, point.dy);
          } else {
            star.lineTo(point.dx, point.dy);
          }
        }
        star.close();
        canvas.drawPath(star, body);
        canvas.drawPath(star, line);
        break;

      // "≈" — close enough is the whole point of the game. No disc behind it:
      // the waves need the full width to stay readable at tile size.
      case GameIconType.circa:
        final wavePaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.105
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        for (final y in const [0.34, 0.66]) {
          final wave = Path()
            ..moveTo(s * 0.07, s * y)
            ..cubicTo(s * 0.21, s * (y - 0.17), s * 0.35, s * (y + 0.17), s * 0.50, s * y)
            ..cubicTo(s * 0.65, s * (y - 0.17), s * 0.79, s * (y + 0.17), s * 0.93, s * y);
          canvas.drawPath(wave, wavePaint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GameIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
