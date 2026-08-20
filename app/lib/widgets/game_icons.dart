import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The five base shapes from the handoff's icon system: 2px contours on a
/// 24-grid, circle/square/triangle/line only — colour carries the category.
enum GameIconType { impostor, truthOrDare, wouldRather, bomb, neverHaveIEver }

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

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.077
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case GameIconType.impostor:
        final r = size.width * 0.46;
        canvas.drawCircle(center, r, stroke);
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(45 * math.pi / 180);
        canvas.drawLine(Offset(0, -r), Offset(0, r), stroke);
        canvas.restore();
        break;

      case GameIconType.truthOrDare:
        final rect = Rect.fromCenter(center: center, width: size.width * 0.92, height: size.height * 0.92);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.2)), stroke);
        canvas.drawLine(
          Offset(center.dx, center.dy - size.height * 0.2),
          Offset(center.dx, center.dy + size.height * 0.2),
          stroke,
        );
        break;

      case GameIconType.wouldRather:
        final barWidth = size.width * 0.2;
        final gap = size.width * 0.13;
        final heights = [size.height * 0.4, size.height * 0.78, size.height * 0.56];
        var x = 0.0;
        for (final h in heights) {
          final rect = Rect.fromLTWH(x, size.height - h, barWidth, h);
          canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(barWidth * 0.3)), fill);
          x += barWidth + gap;
        }
        break;

      case GameIconType.bomb:
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(-30 * math.pi / 180);
        final r = size.width * 0.46;
        canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r), 0.5, 2 * math.pi - 1.0, false, stroke);
        canvas.restore();
        break;

      case GameIconType.neverHaveIEver:
        final path = Path()
          ..moveTo(center.dx, size.height * 0.06)
          ..lineTo(size.width * 0.95, size.height * 0.94)
          ..lineTo(size.width * 0.05, size.height * 0.94)
          ..close();
        canvas.drawPath(path, fill);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GameIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
