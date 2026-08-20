import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One glyph per game. The handoff's icon system asks for 2px contours on a
/// 24-grid built from circles, rounded rects, triangles and lines — colour
/// carries the category, the silhouette carries the game. Every glyph below
/// stays inside that vocabulary so the set still reads as one family, but no
/// two games share a shape any more.
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
      child: CustomPaint(
        painter: _GameIconPainter(type: type, color: color),
        // Semantics live on the tile, not the glyph — the icon is decorative.
        isComplex: false,
      ),
    );
  }
}

class _GameIconPainter extends CustomPainter {
  _GameIconPainter({required this.type, required this.color});

  final GameIconType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.077
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final thin = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    final center = Offset(s / 2, s / 2);

    switch (type) {
      // Masked face — the one player whose identity is hidden. The notch at
      // the bottom edge is what keeps it from reading as a no-entry sign.
      case GameIconType.impostor:
        canvas.drawCircle(center, s * 0.42, stroke);
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
        canvas.drawPath(mask, fill);
        break;

      // A coin mid-flip: one circle, two halves, one of them committed.
      case GameIconType.truthOrDare:
        final r = s * 0.42;
        canvas.drawCircle(center, r, stroke);
        final half = Path()
          ..moveTo(center.dx, center.dy - r)
          ..arcToPoint(Offset(center.dx, center.dy + r), radius: Radius.circular(r), clockwise: false)
          ..close();
        canvas.drawPath(half, fill);
        break;

      // Three heads with the group's finger aimed at the middle one.
      case GameIconType.wouldRather:
        const y = 0.68;
        canvas.drawCircle(Offset(s * 0.16, s * y), s * 0.115, thin);
        canvas.drawCircle(Offset(s * 0.84, s * y), s * 0.115, thin);
        canvas.drawCircle(Offset(s * 0.50, s * y), s * 0.155, fill);
        final chevron = Path()
          ..moveTo(s * 0.34, s * 0.16)
          ..lineTo(s * 0.50, s * 0.38)
          ..lineTo(s * 0.66, s * 0.16);
        canvas.drawPath(chevron, stroke);
        break;

      // A glass with a fill line — who has done it, drinks.
      case GameIconType.neverHaveIEver:
        final glass = Path()
          ..moveTo(s * 0.24, s * 0.16)
          ..lineTo(s * 0.76, s * 0.16)
          ..lineTo(s * 0.63, s * 0.86)
          ..lineTo(s * 0.37, s * 0.86)
          ..close();
        canvas.drawPath(glass, stroke);
        canvas.drawLine(Offset(s * 0.31, s * 0.46), Offset(s * 0.69, s * 0.46), thin);
        break;

      // Round body, screw cap, curling fuse, spark.
      case GameIconType.bomb:
        canvas.drawCircle(Offset(s * 0.42, s * 0.66), s * 0.30, stroke);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(s * 0.32, s * 0.27, s * 0.20, s * 0.11),
            Radius.circular(s * 0.035),
          ),
          thin,
        );
        final fuse = Path()
          ..moveTo(s * 0.52, s * 0.31)
          ..quadraticBezierTo(s * 0.72, s * 0.30, s * 0.74, s * 0.15);
        canvas.drawPath(fuse, thin);
        const spark = Offset(0.76, 0.12);
        for (var i = 0; i < 5; i++) {
          final a = (2 * math.pi / 5) * i - math.pi / 2;
          canvas.drawLine(
            Offset(s * spark.dx + math.cos(a) * s * 0.05, s * spark.dy + math.sin(a) * s * 0.05),
            Offset(s * spark.dx + math.cos(a) * s * 0.12, s * spark.dy + math.sin(a) * s * 0.12),
            thin,
          );
        }
        break;

      // Wheel with spokes and the ball resting on the rim.
      case GameIconType.roulette:
        final r = s * 0.42;
        canvas.drawCircle(center, r, stroke);
        for (var i = 0; i < 4; i++) {
          final a = (math.pi / 4) * (2 * i + 1);
          canvas.drawLine(
            Offset(center.dx + math.cos(a) * r * 0.28, center.dy + math.sin(a) * r * 0.28),
            Offset(center.dx + math.cos(a) * r * 0.92, center.dy + math.sin(a) * r * 0.92),
            thin,
          );
        }
        canvas.drawCircle(Offset(center.dx, center.dy - r * 0.62), s * 0.075, fill);
        break;

      // A figure mid-gesture: head plus motion arcs. Acting, not talking.
      case GameIconType.charade:
        canvas.drawCircle(Offset(s * 0.5, s * 0.26), s * 0.15, stroke);
        final body = Path()
          ..moveTo(s * 0.5, s * 0.43)
          ..lineTo(s * 0.5, s * 0.70)
          ..moveTo(s * 0.5, s * 0.70)
          ..lineTo(s * 0.33, s * 0.90)
          ..moveTo(s * 0.5, s * 0.70)
          ..lineTo(s * 0.67, s * 0.90)
          ..moveTo(s * 0.22, s * 0.44)
          ..lineTo(s * 0.5, s * 0.52)
          ..lineTo(s * 0.80, s * 0.36);
        canvas.drawPath(body, thin);
        break;

      // Two contenders, one bolt between them.
      case GameIconType.duel:
        canvas.drawCircle(Offset(s * 0.17, s * 0.5), s * 0.15, stroke);
        canvas.drawCircle(Offset(s * 0.83, s * 0.5), s * 0.15, stroke);
        final bolt = Path()
          ..moveTo(s * 0.60, s * 0.10)
          ..lineTo(s * 0.39, s * 0.53)
          ..lineTo(s * 0.50, s * 0.53)
          ..lineTo(s * 0.40, s * 0.90)
          ..lineTo(s * 0.62, s * 0.45)
          ..lineTo(s * 0.51, s * 0.45)
          ..close();
        canvas.drawPath(bolt, fill);
        break;

      // A question mark, drawn as arc + stem + dot.
      case GameIconType.quiz:
        final hook = Path()
          ..moveTo(s * 0.29, s * 0.34)
          ..arcToPoint(Offset(s * 0.62, s * 0.42), radius: Radius.circular(s * 0.19), clockwise: true)
          ..quadraticBezierTo(s * 0.62, s * 0.55, s * 0.5, s * 0.62)
          ..lineTo(s * 0.5, s * 0.70);
        canvas.drawPath(hook, stroke);
        canvas.drawCircle(Offset(s * 0.5, s * 0.86), s * 0.065, fill);
        break;

      // Magnifier with someone caught in the lens.
      case GameIconType.liar:
        final lens = Offset(s * 0.42, s * 0.42);
        canvas.drawCircle(lens, s * 0.30, stroke);
        canvas.drawCircle(lens, s * 0.11, fill);
        canvas.drawLine(Offset(s * 0.64, s * 0.64), Offset(s * 0.88, s * 0.88), stroke);
        break;

      // True next to false — the whole decision in one glyph.
      case GameIconType.fakeFact:
        final check = Path()
          ..moveTo(s * 0.05, s * 0.52)
          ..lineTo(s * 0.19, s * 0.68)
          ..lineTo(s * 0.43, s * 0.30);
        canvas.drawPath(check, stroke);
        canvas.drawLine(Offset(s * 0.59, s * 0.32), Offset(s * 0.91, s * 0.68), stroke);
        canvas.drawLine(Offset(s * 0.91, s * 0.32), Offset(s * 0.59, s * 0.68), stroke);
        break;

      // A stack of chips and the direction the bidding goes. The gaps have
      // to stay wider than the stroke or the three rings merge into a blob.
      case GameIconType.bet:
        for (final y in const [0.82, 0.59, 0.36]) {
          canvas.drawOval(
            Rect.fromCenter(center: Offset(s * 0.33, s * y), width: s * 0.56, height: s * 0.15),
            thin,
          );
        }
        final arrow = Path()
          ..moveTo(s * 0.82, s * 0.80)
          ..lineTo(s * 0.82, s * 0.22)
          ..moveTo(s * 0.71, s * 0.35)
          ..lineTo(s * 0.82, s * 0.20)
          ..lineTo(s * 0.93, s * 0.35);
        canvas.drawPath(arrow, stroke);
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
        canvas.drawPath(bubble, stroke);
        canvas.drawLine(Offset(s * 0.22, s * 0.62), Offset(s * 0.78, s * 0.26), stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GameIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
