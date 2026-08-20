import 'package:flutter/material.dart';

/// The retro-arcade grid texture used behind splash / handoff / card
/// screens — faint 1px lines on a ~26px grid.
class GridBackground extends StatelessWidget {
  const GridBackground({super.key, required this.child, this.lineColor, this.spacing = 26});

  final Widget child;
  final Color? lineColor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final color = lineColor ?? Colors.white.withValues(alpha: 0.03);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter(color: color, spacing: spacing))),
        child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color, required this.spacing});

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}
