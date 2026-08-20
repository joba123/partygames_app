import 'dart:async';
import 'dart:math';
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
import '../../widgets/game_icons.dart';
import '../shared/game_result_screen.dart';

enum _BombPhase { ready, running, exploded }

/// Bombe. Hot potato with a category: whoever holds the phone names one
/// thing that fits and passes on. The fuse length is random and deliberately
/// never shown — a visible countdown turns the whole game into "wait for
/// 0:03, then pass".
class BombScreen extends StatefulWidget {
  const BombScreen({super.key, required this.players});

  final List<Player> players;

  static const startingLives = 2;

  @override
  State<BombScreen> createState() => _BombScreenState();
}

class _BombScreenState extends State<BombScreen> with SingleTickerProviderStateMixin {
  final _random = Random();

  late Deck<Prompt> _deck;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  Timer? _timer;
  _BombPhase _phase = _BombPhase.ready;
  Prompt? _category;
  int _holderIndex = 0;
  int _round = 1;
  int _fuseTicks = 0;

  late final Map<String, int> _lives = {
    for (final p in widget.players) p.id: BombScreen.startingLives,
  };

  @override
  void initState() {
    super.initState();
    _deck = Deck(context.read<AppState>().contentFilter.apply(bombCategories));
    _category = _deck.draw();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  List<Player> get _alive => widget.players.where((p) => (_lives[p.id] ?? 0) > 0).toList();

  Player get _holder => widget.players[_holderIndex];

  int _nextAliveIndex(int from) {
    for (var step = 1; step <= widget.players.length; step++) {
      final i = (from + step) % widget.players.length;
      if ((_lives[widget.players[i].id] ?? 0) > 0) return i;
    }
    return from;
  }

  void _startRound() {
    // 18–42 s, drawn fresh every round so nobody can time it by feel.
    _fuseTicks = 18 + _random.nextInt(25);
    setState(() => _phase = _BombPhase.running);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fuseTicks -= 1;
      if (_fuseTicks <= 0) _explode();
    });
  }

  void _pass() {
    if (_phase != _BombPhase.running) return;
    setState(() => _holderIndex = _nextAliveIndex(_holderIndex));
  }

  void _explode() {
    _timer?.cancel();
    setState(() {
      _lives[_holder.id] = (_lives[_holder.id] ?? 1) - 1;
      _phase = _BombPhase.exploded;
    });
  }

  void _continueAfterExplosion() {
    if (_alive.length <= 1) {
      _finish();
      return;
    }
    setState(() {
      _round += 1;
      _category = _deck.draw();
      _holderIndex = _nextAliveIndex(_holderIndex);
      _phase = _BombPhase.ready;
    });
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      for (final p in widget.players) {
        _lives[p.id] = BombScreen.startingLives;
      }
      _deck = Deck(context.read<AppState>().contentFilter.apply(bombCategories));
      _category = _deck.draw();
      _round = 1;
      _holderIndex = 0;
      _phase = _BombPhase.ready;
    });
  }

  void _finish() {
    _timer?.cancel();
    final survivors = _alive;
    final entries = widget.players
        .map((p) => ScoreEntry(
              name: p.name,
              score: _lives[p.id] ?? 0,
              detail: (_lives[p.id] ?? 0) == 0 ? 'rausgeflogen' : null,
            ))
        .toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: survivors.isEmpty ? 'Alle rausgeflogen' : 'Überlebt',
        subtitle: 'Wer noch Leben übrig hat, hat die Bombe nie festgehalten.',
        entries: entries,
        scoreUnit: 'Leben',
        onRematch: () {
          Navigator.of(context).pop();
          _restart();
        },
        onExit: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final next = widget.players[_nextAliveIndex(_holderIndex)];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: 'Runde $_round · ${_alive.length} im Spiel',
              trailingLabel: _phase == _BombPhase.running ? 'Läuft' : null,
              trailingColor: p.danger,
              onBack: () {
                _timer?.cancel();
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: switch (_phase) {
                  _BombPhase.ready => _readyView(context),
                  _BombPhase.running => _runningView(context),
                  _BombPhase.exploded => _explodedView(context),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: switch (_phase) {
                _BombPhase.ready => AppButton(
                    label: '${_holder.name} startet',
                    size: AppButtonSize.large,
                    color: p.warning,
                    onColor: p.onWarning,
                    onPressed: _startRound,
                  ),
                _BombPhase.running => AppButton(
                    label: 'Genannt — weiter an ${next.name}',
                    size: AppButtonSize.large,
                    color: p.danger,
                    onColor: p.onDanger,
                    onPressed: _pass,
                  ),
                _BombPhase.exploded => Column(
                    children: [
                      AppButton(
                        label: _alive.length <= 1 ? 'Endstand ansehen' : 'Nächste Runde',
                        size: AppButtonSize.large,
                        onPressed: _continueAfterExplosion,
                      ),
                      const SizedBox(height: 10),
                      AppButton(label: 'Spiel beenden', filled: false, onPressed: _finish),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _readyView(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameIconGlyph(type: GameIconType.bomb, color: p.warning, size: 96),
          const SizedBox(height: AppSpacing.xl),
          Text('KATEGORIE', style: AppText.labelMono(p.textMuted, size: 11)),
          const SizedBox(height: 10),
          Text(_category?.text ?? '', textAlign: TextAlign.center, style: AppText.headline(p.textPrimary)),
          const SizedBox(height: 14),
          Text(
            'Reihum ein passender Begriff, dann sofort weitergeben. '
            'Wann es knallt, weiß niemand.',
            textAlign: TextAlign.center,
            style: AppText.bodySmall(p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          _LivesRow(players: widget.players, lives: _lives),
        ],
      ),
    );
  }

  Widget _runningView(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Constant-rate pulse: it signals "live", it does not leak the fuse.
          ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.08).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                color: p.danger.withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: GameIconGlyph(type: GameIconType.bomb, color: p.danger, size: 84),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(germanUpper(_holder.name), style: AppText.labelMono(p.danger, size: 12)),
          const SizedBox(height: 10),
          Text(_category?.text ?? '', textAlign: TextAlign.center, style: AppText.headline(p.textPrimary)),
          const SizedBox(height: 14),
          Text('Ein Begriff, dann weitergeben.', textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
        ],
      ),
    );
  }

  Widget _explodedView(BuildContext context) {
    final p = context.palette;
    final out = (_lives[_holder.id] ?? 0) <= 0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(color: p.danger, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('BOOM', style: AppText.labelMono(p.onDanger, size: 22)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('${_holder.name} hatte sie in der Hand',
              textAlign: TextAlign.center, style: AppText.headline(p.textPrimary)),
          const SizedBox(height: 12),
          Text(
            out ? '${_holder.name} ist raus.' : 'Ein Leben weniger — ${_lives[_holder.id]} übrig.',
            textAlign: TextAlign.center,
            style: AppText.bodySmall(p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          _LivesRow(players: widget.players, lives: _lives),
        ],
      ),
    );
  }
}

class _LivesRow extends StatelessWidget {
  const _LivesRow({required this.players, required this.lives});

  final List<Player> players;
  final Map<String, int> lives;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final player in players)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.name,
                  style: AppText.caption((lives[player.id] ?? 0) > 0 ? p.textSecondary : p.textDim)
                      .copyWith(decoration: (lives[player.id] ?? 0) > 0 ? null : TextDecoration.lineThrough),
                ),
                const SizedBox(width: 8),
                for (var i = 0; i < BombScreen.startingLives; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i < (lives[player.id] ?? 0) ? p.danger : p.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
