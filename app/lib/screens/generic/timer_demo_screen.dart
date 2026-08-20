import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/games.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/round_timer.dart';

const _tasksByGame = {
  GameId.bombe: ['Nennt Städte mit M', 'Nennt Marken von Schuhen', 'Nennt Filme mit Tom Hanks'],
  GameId.trinkspielRoulette: ['Alle mit Ohrringen trinken', 'Der Jüngste bestimmt eine Regel', 'Reihum ein Schluck, wer zuerst lacht trinkt doppelt'],
  GameId.tabu: ['Erkläre "Strand" ohne Meer, Sand, Urlaub', 'Erkläre "Kaffee" ohne Koffein, Tasse, morgens'],
};

/// Screen 10 — one widget for every timed game: ring + mono digits,
/// colour flips to danger under 25%. Duration chips belong to the
/// component itself.
class TimerDemoScreen extends StatefulWidget {
  const TimerDemoScreen({super.key, required this.game});

  final GameInfo game;

  @override
  State<TimerDemoScreen> createState() => _TimerDemoScreenState();
}

class _TimerDemoScreenState extends State<TimerDemoScreen> {
  int _round = 1;
  int _total = 60;
  late int _secondsLeft = _total;
  Timer? _timer;
  bool _running = false;
  int _taskIndex = 0;

  List<String> get _tasks => _tasksByGame[widget.game.id] ?? const ['Handy weitergeben, bevor die Zeit abläuft.'];

  void _setDuration(int seconds) {
    if (_running) return;
    setState(() {
      _total = seconds;
      _secondsLeft = seconds;
    });
  }

  void _toggleRunning() {
    if (_secondsLeft == 0) {
      setState(() {
        _round += 1;
        _taskIndex = (_taskIndex + 1) % _tasks.length;
        _secondsLeft = _total;
      });
      return;
    }
    setState(() => _running = !_running);
    if (_running) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft <= 1) {
          setState(() {
            _secondsLeft = 0;
            _running = false;
          });
          _timer?.cancel();
        } else {
          setState(() => _secondsLeft -= 1);
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _secondsLeft = _total;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = AppColors.category(widget.game.category, Theme.of(context).brightness);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
                  Text('${widget.game.title.toUpperCase()} · RUNDE $_round', style: AppText.labelMono(p.textMuted, size: 11)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: accent.withValues(alpha: .14), borderRadius: BorderRadius.circular(999)),
                    child: Text(widget.game.category.label.toUpperCase(), style: AppText.labelMono(accent, size: 11)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RoundTimerRing(totalSeconds: _total, secondsLeft: _secondsLeft),
                    const SizedBox(height: 34),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Text(_tasks[_taskIndex], textAlign: TextAlign.center, style: AppText.title(p.textPrimary)),
                          const SizedBox(height: 10),
                          Text('Wer zu lang braucht, ist raus. Handy weitergeben nach jeder Antwort.',
                              textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppChip(label: '30 S', mono: true, selected: _total == 30, onTap: () => _setDuration(30)),
                        const SizedBox(width: 8),
                        AppChip(label: '60 S', mono: true, selected: _total == 60, color: p.warning, onColor: p.onWarning, onTap: () => _setDuration(60)),
                        const SizedBox(width: 8),
                        AppChip(label: '90 S', mono: true, selected: _total == 90, onTap: () => _setDuration(90)),
                      ],
                    ),
                  ],
                ),
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
                        onTap: _reset,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: p.outline)),
                          alignment: Alignment.center,
                          child: Icon(Icons.refresh_rounded, color: p.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: _secondsLeft == 0 ? 'Nächste Runde' : (_running ? 'Pause' : 'Start'),
                      size: AppButtonSize.large,
                      color: p.warning,
                      onColor: p.onWarning,
                      onPressed: _toggleRunning,
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
