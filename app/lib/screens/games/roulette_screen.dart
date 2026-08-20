import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/content.dart';
import '../../data/deck.dart';
import '../../data/prompts_rounds.dart';
import '../../models/player.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';

/// Trinkspiel-Roulette. The wheel picks the person, the deck picks the rule.
/// Rules are written with a `%s` placeholder so the same card reads naturally
/// for whoever the wheel lands on.
class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> with SingleTickerProviderStateMixin {
  final _random = math.Random();

  late Deck<Prompt> _deck;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() => _spinning = false);
    });

  late Animation<double> _rotation = const AlwaysStoppedAnimation(0);

  double _angle = 0;
  bool _spinning = false;
  int? _targetIndex;
  Prompt? _rule;
  int _spins = 0;

  @override
  void initState() {
    super.initState();
    _deck = Deck(context.read<AppState>().contentFilter.apply(rouletteRules));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning || widget.players.isEmpty) return;

    final target = _random.nextInt(widget.players.length);
    final segment = 2 * math.pi / widget.players.length;

    // Land the target segment's centre under the fixed pointer at the top,
    // after four full turns so it reads as a spin and not a jump cut.
    final normalized = _angle % (2 * math.pi);
    final landing = (2 * math.pi - (target + 0.5) * segment) % (2 * math.pi);
    final end = _angle - normalized + landing + 4 * 2 * math.pi;

    setState(() {
      _spinning = true;
      _targetIndex = target;
      _rule = _deck.draw();
      _spins += 1;
      _rotation = Tween(begin: _angle, end: end)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _angle = end;
    });
    _controller.forward(from: 0);
  }

  String get _resolvedRule {
    final rule = _rule;
    final index = _targetIndex;
    if (rule == null || index == null) return '';
    return rule.text.replaceAll('%s', widget.players[index].name);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final showResult = !_spinning && _targetIndex != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: _spins == 0 ? 'Bereit' : 'Dreh $_spins',
              trailingLabel: 'Roulette',
              trailingColor: p.warning,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _rotation,
                            builder: (context, child) => Transform.rotate(angle: _rotation.value, child: child),
                            child: CustomPaint(
                              size: const Size(272, 272),
                              painter: _WheelPainter(
                                players: widget.players,
                                brightness: Theme.of(context).brightness,
                                trackColor: p.background,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 2,
                            child: CustomPaint(
                              size: const Size(26, 20),
                              painter: _PointerPainter(color: p.textPrimary),
                            ),
                          ),
                          Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              color: p.background,
                              shape: BoxShape.circle,
                              border: Border.all(color: p.outline, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _spinning ? '···' : 'DREH',
                              style: AppText.labelMono(p.textSecondary, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (showResult) ...[
                      Text(widget.players[_targetIndex!].name.toUpperCase(),
                          style: AppText.labelMono(p.warning, size: 12)),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: p.outlineVariant),
                        ),
                        child: Text(_resolvedRule,
                            textAlign: TextAlign.center,
                            style: AppText.title(p.textPrimary).copyWith(fontSize: 21, height: 1.35)),
                      ),
                    ] else
                      Text(
                        _spinning ? 'Und jetzt …' : 'Rad drehen, Regel kassieren.',
                        textAlign: TextAlign.center,
                        style: AppText.bodySmall(p.textSecondary),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: AppButton(
                label: _spins == 0 ? 'Rad drehen' : 'Nochmal drehen',
                size: AppButtonSize.large,
                color: p.warning,
                onColor: p.onWarning,
                onPressed: _spinning ? null : _spin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.players, required this.brightness, required this.trackColor});

  final List<Player> players;
  final Brightness brightness;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (players.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segment = 2 * math.pi / players.length;

    for (var i = 0; i < players.length; i++) {
      // -pi/2 puts segment 0 at the top, where the pointer sits.
      final start = -math.pi / 2 + i * segment;
      final paint = Paint()..color = AvatarPalette.fill(i, brightness);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, segment, true, paint);

      final divider = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, segment, true, divider);

      // Names beat initials — half a party has two people starting with the
      // same letter. Past eight players there is no room, so initials return.
      final crowded = players.length > 8;
      final name = players[i].name;
      final text = crowded
          ? players[i].initial
          : (name.length > 9 ? '${name.substring(0, 8)}…' : name);

      final label = TextPainter(
        text: TextSpan(
          text: text,
          style: AppText.monoValue(
            AvatarPalette.onFill(i, brightness),
            size: crowded ? 18 : 13,
            weight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final mid = start + segment / 2;
      final pos = Offset(
        center.dx + math.cos(mid) * radius * 0.64,
        center.dy + math.sin(mid) * radius * 0.64,
      );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(mid + math.pi / 2);
      label.paint(canvas, Offset(-label.width / 2, -label.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      !listEquals(oldDelegate.players.map((p) => p.name).toList(), players.map((p) => p.name).toList()) ||
      oldDelegate.brightness != brightness ||
      oldDelegate.trackColor != trackColor;
}

class _PointerPainter extends CustomPainter {
  _PointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => oldDelegate.color != color;
}
