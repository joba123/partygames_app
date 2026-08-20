import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/impostor_session.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/grid_background.dart';

/// Screens 05+06 — press-and-hold instead of tap-toggle so nothing stays
/// visible unattended: hold to reveal the role card, release to hide it.
class ImpostorRevealScreen extends StatefulWidget {
  const ImpostorRevealScreen({super.key, required this.onContinue, required this.onExit});

  final VoidCallback onContinue;
  final VoidCallback onExit;

  @override
  State<ImpostorRevealScreen> createState() => _ImpostorRevealScreenState();
}

class _ImpostorRevealScreenState extends State<ImpostorRevealScreen> {
  bool _held = false;
  bool _everRevealed = false;

  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Runde abbrechen?'),
        content: const Text('Die aktuelle Rollenverteilung geht verloren.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Weiter spielen')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Abbrechen')),
        ],
      ),
    );
    if (leave == true) widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final session = context.watch<ImpostorSession>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isImpostor = session.isImpostor(session.distributionIndex);
    final isLast = session.distributionIndex == session.players.length - 1;
    final nextLabel = isLast ? 'zur Hinweisrunde' : 'weiter an ${session.players[session.distributionIndex + 1].name}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ROLLENVERTEILUNG · ${session.distributionIndex + 1}/${session.players.length}',
                      style: AppText.labelMono(p.textMuted, size: 11)),
                  _held
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isImpostor ? p.danger : p.accentSafe).withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(isImpostor ? 'IMPOSTOR' : 'TEAM WORT',
                              style: AppText.labelMono(isImpostor ? p.danger : p.accentSafe, size: 11)),
                        )
                      : AppIconButton(icon: Icons.close_rounded, onTap: _confirmExit),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Listener(
                        onPointerDown: (_) => setState(() {
                          _held = true;
                          _everRevealed = true;
                        }),
                        onPointerUp: (_) => setState(() => _held = false),
                        onPointerCancel: (_) => setState(() => _held = false),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _held
                              ? _RoleCard(key: const ValueKey('role'), isImpostor: isImpostor, word: session.word)
                              : _FacedownCard(key: const ValueKey('facedown'), dark: dark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_held)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: p.outlineVariant)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: p.danger, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Text('Loslassen versteckt die Karte', style: AppText.caption(p.textSecondary)),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Halte gedrückt zum Aufdecken. Loslassen versteckt sie wieder — falls jemand über die Schulter schaut.',
                        textAlign: TextAlign.center,
                        style: AppText.bodySmall(p.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 30),
              child: AppButton(
                label: _everRevealed ? 'Gesehen — $nextLabel' : 'Erst aufdecken',
                size: AppButtonSize.large,
                color: _everRevealed ? (isImpostor ? p.danger : p.accentSafe) : null,
                onColor: _everRevealed ? (isImpostor ? p.onDanger : p.onAccentSafe) : null,
                onPressed: _everRevealed && !_held ? widget.onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacedownCard extends StatelessWidget {
  const _FacedownCard({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GridBackground(
      lineColor: Colors.white.withValues(alpha: .02),
      spacing: 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: dark ? const [Color(0xFF2A2020), Color(0xFF1A1615)] : const [Color(0xFFFFEFE3), Color(0xFFFFF7F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          border: Border.all(color: p.outline),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: p.surfaceContainer, borderRadius: BorderRadius.circular(32), border: Border.all(color: p.outline)),
              alignment: Alignment.center,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(painter: _NoSignPainter(color: p.primary)),
              ),
            ),
            const SizedBox(height: 22),
            Text('Deine Karte', style: AppText.title(p.textPrimary)),
            const SizedBox(height: 8),
            Text('GEDRÜCKT HALTEN', style: AppText.labelMono(p.textFaint, size: 12)),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({super.key, required this.isImpostor, required this.word});

  final bool isImpostor;
  final String word;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = isImpostor ? p.danger : p.accentSafe;
    final gradient = isImpostor
        ? const [Color(0xFF3A1A16), Color(0xFF2A1210)]
        : const [Color(0xFF123830), Color(0xFF0E2A25)];
    final border = isImpostor ? const Color(0xFF6B3229) : const Color(0xFF1F5F52);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isImpostor ? 'Deine Rolle' : 'Dein Wort', style: AppText.labelMono(accent, size: 12).copyWith(letterSpacing: 12 * 0.2)),
          const SizedBox(height: 18),
          Text(
            isImpostor ? 'Impostor' : word,
            textAlign: TextAlign.center,
            style: AppText.headline(p.textPrimary).copyWith(fontSize: isImpostor ? 34 : 44, letterSpacing: -1),
          ),
          Container(margin: const EdgeInsets.symmetric(vertical: 18), width: 56, height: 1, color: border),
          Text(
            isImpostor ? 'Du kennst das Wort nicht. Hör zu und bluffe mit.' : 'Beschreibe es, ohne es zu verraten. Ein Wort pro Runde.',
            textAlign: TextAlign.center,
            style: AppText.bodySmall(isImpostor ? const Color(0xFFE0A79C) : const Color(0xFF8FD3C4)),
          ),
        ],
      ),
    );
  }
}

class _NoSignPainter extends CustomPainter {
  _NoSignPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.46, stroke);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(45 * 3.14159265 / 180);
    canvas.drawLine(Offset(0, -size.height * 0.46), Offset(0, size.height * 0.46), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NoSignPainter oldDelegate) => oldDelegate.color != color;
}
