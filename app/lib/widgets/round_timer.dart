import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_text.dart';

String formatMmSs(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// One widget for all games: ring + mono digits. Colour switches to danger
/// under 25%; the ring itself never needs a haptic — callers pulse on tick.
class RoundTimerRing extends StatelessWidget {
  const RoundTimerRing({
    super.key,
    required this.totalSeconds,
    required this.secondsLeft,
    this.size = 260,
    this.label,
  });

  final int totalSeconds;
  final int secondsLeft;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fraction = totalSeconds == 0 ? 0.0 : secondsLeft / totalSeconds;
    final urgent = fraction <= 0.25;
    final ringColor = urgent ? p.danger : p.warning;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(fraction: fraction, trackColor: p.surfaceContainer, ringColor: ringColor, strokeWidth: size * 0.09),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(formatMmSs(secondsLeft), style: AppText.monoDisplay(p.textPrimary, size: size * 0.26)),
              const SizedBox(height: 6),
              Text('VON ${formatMmSs(totalSeconds)}', style: AppText.labelMono(p.textFaint, size: 11)),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(label!, style: AppText.labelMono(ringColor, size: 11)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.trackColor, required this.ringColor, required this.strokeWidth});

  final double fraction;
  final Color trackColor;
  final Color ringColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, track);

    final ring = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * math.pi * fraction.clamp(0.0, 1.0);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, ring);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.ringColor != ringColor;
}

/// Slim linear progress bar variant (used inline in cards, e.g. clue turn).
class RoundTimerBar extends StatelessWidget {
  const RoundTimerBar({super.key, required this.fraction, this.color});

  final double fraction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: p.surfaceContainer,
        valueColor: AlwaysStoppedAnimation(color ?? p.warning),
      ),
    );
  }
}
