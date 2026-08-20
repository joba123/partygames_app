import 'package:flutter/material.dart';
import '../../data/circa_questions.dart';
import '../../data/deck.dart';
import '../../models/player.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/pass_phone.dart';
import '../shared/game_result_screen.dart';

enum _CircaPhase { handoff, guessing, reveal }

/// Circa. Every question has exactly one number as its answer; the phone goes
/// round once, everyone types a guess, and whoever lands closest takes the
/// point. Ties share the point — two people equally close both earned it.
class CircaScreen extends StatefulWidget {
  const CircaScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<CircaScreen> createState() => _CircaScreenState();
}

class _CircaScreenState extends State<CircaScreen> {
  final _controller = TextEditingController();
  late final Deck<CircaQuestion> _deck = Deck(circaQuestions);

  late CircaQuestion _question;
  _CircaPhase _phase = _CircaPhase.handoff;
  int _turn = 0;
  int _round = 1;

  final Map<String, int> _guesses = {};
  final Map<String, int> _points = {};

  @override
  void initState() {
    super.initState();
    _question = _deck.draw() ?? circaQuestions.first;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Player get _current => widget.players[_turn];

  void _submitGuess() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null) return;
    setState(() {
      _guesses[_current.id] = value;
      _controller.clear();
      if (_turn < widget.players.length - 1) {
        _turn += 1;
        _phase = _CircaPhase.handoff;
      } else {
        _awardPoints();
        _phase = _CircaPhase.reveal;
      }
    });
  }

  int _distance(Player p) => ((_guesses[p.id] ?? 0) - _question.answer).abs();

  void _awardPoints() {
    final scored = widget.players.where((p) => _guesses.containsKey(p.id)).toList();
    if (scored.isEmpty) return;
    final best = scored.map(_distance).reduce((a, b) => a < b ? a : b);
    for (final p in scored.where((p) => _distance(p) == best)) {
      _points[p.id] = (_points[p.id] ?? 0) + 1;
    }
  }

  void _nextRound() {
    setState(() {
      _round += 1;
      _question = _deck.draw() ?? circaQuestions.first;
      _guesses.clear();
      _turn = 0;
      _phase = _CircaPhase.handoff;
    });
  }

  void _finish() {
    final entries = widget.players
        .map((p) => ScoreEntry(name: p.name, score: _points[p.id] ?? 0))
        .toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: 'Ausgeschätzt',
        subtitle: 'Ein Punkt je Frage, bei der niemand näher dran war.',
        entries: entries,
        scoreUnit: 'Punkte',
        onRematch: () {
          Navigator.of(context).pop();
          setState(() {
            _points.clear();
            _round = 1;
            _guesses.clear();
            _turn = 0;
            _question = _deck.draw() ?? circaQuestions.first;
            _phase = _CircaPhase.handoff;
          });
        },
        onExit: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _CircaPhase.handoff) {
      return PassPhoneView(
        player: _current,
        index: _turn,
        total: widget.players.length,
        subtitle: 'Tipp deine Schätzung ein, ohne dass jemand mitliest.',
        onConfirm: () => setState(() => _phase = _CircaPhase.guessing),
      );
    }

    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: _phase == _CircaPhase.guessing
                  ? '${_turn + 1} von ${widget.players.length}'
                  : 'Runde $_round · Auflösung',
              trailingLabel: 'Circa',
              trailingColor: p.accentSafe,
            ),
            Expanded(
              child: _phase == _CircaPhase.guessing ? _guessView(context) : _revealView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guessView(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(germanUpper('${_current.name}, wie viele?'),
                    style: AppText.labelMono(p.textMuted, size: 12)),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sheet),
                    border: Border.all(color: p.outlineVariant),
                  ),
                  child: Text(_question.question,
                      style: AppText.headline(p.textPrimary).copyWith(fontSize: 25, height: 1.25)),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(germanUpper('Dein Tipp in ${_question.unit}'),
                    style: AppText.labelMono(p.textMuted, size: 11)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    border: Border.all(color: p.accentSafe, width: 2),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: AppText.monoValue(p.textPrimary, size: 30, weight: FontWeight.w700),
                    cursorColor: p.accentSafe,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: AppText.monoValue(p.textFaint, size: 30, weight: FontWeight.w700),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onSubmitted: (_) => _submitGuess(),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Nur ganze Zahlen. Näher dran gewinnt — genau treffen muss niemand.',
                    style: AppText.caption(p.textFaint)),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
          child: AppButton(
            label: _turn < widget.players.length - 1
                ? 'Getippt — weiter an ${widget.players[_turn + 1].name}'
                : 'Getippt — auflösen',
            size: AppButtonSize.large,
            color: p.accentSafe,
            onColor: p.onAccentSafe,
            onPressed: _submitGuess,
          ),
        ),
      ],
    );
  }

  Widget _revealView(BuildContext context) {
    final p = context.palette;
    final ranked = List.of(widget.players)..sort((a, b) => _distance(a).compareTo(_distance(b)));
    final best = ranked.isEmpty ? 0 : _distance(ranked.first);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
            children: [
              Text(_question.question, style: AppText.bodySmall(p.textSecondary).copyWith(fontSize: 16)),
              const SizedBox(height: 18),
              Center(
                child: Column(
                  children: [
                    Text('${_question.answer}', style: AppText.monoDisplay(p.accentSafe, size: 64)),
                    const SizedBox(height: 8),
                    Text(germanUpper(_question.unit), style: AppText.labelMono(p.textMuted, size: 11)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < ranked.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GuessRow(
                    player: ranked[i],
                    colorIndex: widget.players.indexOf(ranked[i]),
                    guess: _guesses[ranked[i].id],
                    distance: _distance(ranked[i]),
                    winner: _distance(ranked[i]) == best,
                    total: _points[ranked[i].id] ?? 0,
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 24),
          child: Column(
            children: [
              AppButton(label: 'Nächste Frage', size: AppButtonSize.large, onPressed: _nextRound),
              const SizedBox(height: 10),
              AppButton(label: 'Runde beenden', filled: false, onPressed: _finish),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuessRow extends StatelessWidget {
  const _GuessRow({
    required this.player,
    required this.colorIndex,
    required this.guess,
    required this.distance,
    required this.winner,
    required this.total,
  });

  final Player player;
  final int colorIndex;
  final int? guess;
  final int distance;
  final bool winner;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: winner ? p.accentSafe.withValues(alpha: .12) : p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: winner ? p.accentSafe : p.outlineVariant, width: winner ? 2 : 1),
      ),
      child: Row(
        children: [
          AvatarCircle(initial: player.initial, colorIndex: colorIndex, size: 40, fontSize: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.nameLabel(p.textPrimary)),
                const SizedBox(height: 4),
                Text(winner ? 'näher war keiner' : '$distance daneben',
                    style: AppText.caption(winner ? p.accentSafe : p.textMuted).copyWith(fontSize: 12)),
              ],
            ),
          ),
          Text('${guess ?? '—'}', style: AppText.monoValue(p.textPrimary, size: 20, weight: FontWeight.w700)),
          if (total > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(color: p.primary.withValues(alpha: .16), borderRadius: BorderRadius.circular(999)),
              child: Text('$total', style: AppText.monoValue(p.primary, size: 12, weight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
