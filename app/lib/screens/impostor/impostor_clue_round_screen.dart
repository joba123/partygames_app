import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/impostor_session.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/round_timer.dart';

/// Screen 07 — whoever's turn it is fills half the height, readable from
/// two metres away. Pause sits on the left because the phone often lands
/// mid-round.
class ImpostorClueRoundScreen extends StatefulWidget {
  const ImpostorClueRoundScreen({super.key, required this.onAllCluesDone});

  final VoidCallback onAllCluesDone;

  @override
  State<ImpostorClueRoundScreen> createState() => _ImpostorClueRoundScreenState();
}

class _ImpostorClueRoundScreenState extends State<ImpostorClueRoundScreen> {
  bool _timerStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.read<ImpostorSession>();
    session.onAllCluesDone = widget.onAllCluesDone;
    if (!_timerStarted) {
      _timerStarted = true;
      session.startClueTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final session = context.watch<ImpostorSession>();
    final current = session.currentCluePlayer;
    final fraction = session.secondsLeft / ImpostorSession.clueTurnSeconds;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HINWEISRUNDE ${session.clueRoundNumber} VON ${ImpostorSession.clueRoundsTotal}', style: AppText.labelMono(p.textMuted, size: 11)),
                  const SizedBox(height: 6),
                  Text('Reihum ein Wort', style: AppText.headline(p.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [p.warning.withValues(alpha: .16), p.warning.withValues(alpha: .06)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: p.warning.withValues(alpha: .35)),
                    ),
                    child: Column(
                      children: [
                        Text('JETZT AM ZUG', style: AppText.labelMono(p.warning, size: 11).copyWith(letterSpacing: 11 * 0.18)),
                        const SizedBox(height: 16),
                        AvatarCircleRound(initial: current.initial, colorIndex: session.clueTurnIndex, size: 88, fontSize: 36),
                        const SizedBox(height: 16),
                        Text(current.name, style: AppText.headline(p.textPrimary)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: p.warning, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Text('${formatMmSs(session.secondsLeft)} ÜBRIG', style: AppText.monoValue(p.warning, size: 12)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        RoundTimerBar(fraction: fraction, color: p.warning),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (var i = 0; i < session.players.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PlayerStatusRow(
                        name: session.players[i].name,
                        colorIndex: i,
                        done: session.isClueDoneAt(i),
                        active: i == session.clueTurnIndex,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 30),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Material(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: session.togglePauseClueTimer,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: p.outline)),
                          alignment: Alignment.center,
                          child: Icon(session.timerPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: p.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: '${current.name} hat gesagt',
                      size: AppButtonSize.large,
                      color: p.warning,
                      onColor: p.onWarning,
                      onPressed: () => session.markCurrentClueDone(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerStatusRow extends StatelessWidget {
  const _PlayerStatusRow({required this.name, required this.colorIndex, required this.done, required this.active});

  final String name;
  final int colorIndex;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: active ? p.surface : p.surface.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: active ? p.outline : p.outlineVariant, style: active ? BorderStyle.solid : BorderStyle.solid),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: done || active ? 1 : .6,
            child: AvatarCircle(initial: name.isEmpty ? '?' : name[0].toUpperCase(), colorIndex: colorIndex, size: 32, fontSize: 14),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(name, style: AppText.nameLabel(done || active ? p.textPrimary : p.textFaint))),
          Text(done ? 'FERTIG' : (active ? 'AM ZUG' : 'WARTET'),
              style: AppText.monoValue(done ? p.accentSafe : (active ? p.warning : p.textDim), size: 12)),
        ],
      ),
    );
  }
}
