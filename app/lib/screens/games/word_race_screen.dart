import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/deck.dart';
import '../../data/word_games.dart';
import '../../models/team.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/round_timer.dart';
import '../shared/game_result_screen.dart';

enum WordRaceVariant {
  /// Charade — act it out, no talking. A skip is free.
  charade,

  /// Tabu — explain it, but five words are off limits. A slip costs a point.
  taboo,
}

class _RaceCard {
  const _RaceCard(this.term, {this.hint, this.forbidden = const []});

  final String term;
  final String? hint;
  final List<String> forbidden;
}

enum _RacePhase { brief, playing, summary }

/// Charade and Tabu are the same round underneath: one team, one clock, as
/// many terms as they can land. Only the card face and the penalty rule
/// differ, so both run through this engine.
class WordRaceScreen extends StatefulWidget {
  const WordRaceScreen({
    super.key,
    required this.teams,
    required this.variant,
    this.turnsPerTeam = 2,
  });

  final List<Team> teams;
  final WordRaceVariant variant;

  /// How often each team is up before the podium.
  final int turnsPerTeam;

  @override
  State<WordRaceScreen> createState() => _WordRaceScreenState();
}

class _WordRaceScreenState extends State<WordRaceScreen> {
  late Deck<_RaceCard> _deck;

  Timer? _timer;
  _RacePhase _phase = _RacePhase.brief;
  _RaceCard? _card;

  int _teamIndex = 0;
  int _turn = 1;
  int _duration = 60;
  int _secondsLeft = 60;
  int _roundScore = 0;
  int _roundHits = 0;

  bool get _isTaboo => widget.variant == WordRaceVariant.taboo;

  Team get _team => widget.teams[_teamIndex];

  @override
  void initState() {
    super.initState();
    _deck = _buildDeck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Deck<_RaceCard> _buildDeck() => Deck(
        _isTaboo
            ? tabooWords.map((w) => _RaceCard(w.term, forbidden: w.forbidden)).toList()
            : charadeWords.map((w) => _RaceCard(w.term, hint: w.hint)).toList(),
      );

  void _startTurn() {
    setState(() {
      _phase = _RacePhase.playing;
      _secondsLeft = _duration;
      _roundScore = 0;
      _roundHits = 0;
      _card = _deck.draw();
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        _endTurn();
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _score(int delta, {required bool hit}) {
    setState(() {
      _roundScore += delta;
      if (hit) _roundHits += 1;
      _card = _deck.draw();
    });
  }

  void _endTurn() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 0;
      _team.score += _roundScore;
      _team.advanceTurn();
      _phase = _RacePhase.summary;
    });
  }

  bool get _isLastTurn => _turn >= widget.turnsPerTeam * widget.teams.length;

  void _nextTurn() {
    if (_isLastTurn) {
      _finish();
      return;
    }
    setState(() {
      _turn += 1;
      _teamIndex = (_teamIndex + 1) % widget.teams.length;
      _phase = _RacePhase.brief;
    });
  }

  void _restart() {
    _timer?.cancel();
    setState(() {
      for (final t in widget.teams) {
        t.score = 0;
      }
      _deck = _buildDeck();
      _teamIndex = 0;
      _turn = 1;
      _phase = _RacePhase.brief;
    });
  }

  void _finish() {
    _timer?.cancel();
    final entries = widget.teams
        .map((t) => ScoreEntry(name: t.name, score: t.score, detail: t.members.map((m) => m.name).join(', ')))
        .toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: 'Abgepfiffen',
        entries: entries,
        scoreUnit: 'Punkte',
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
    final accent = _teamIndex == 0 ? p.danger : p.secondary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: 'Zug $_turn von ${widget.turnsPerTeam * widget.teams.length}',
              trailingLabel: _team.name,
              trailingColor: accent,
              onBack: () {
                _timer?.cancel();
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: switch (_phase) {
                  _RacePhase.brief => _briefView(context, accent),
                  _RacePhase.playing => _playingView(context, accent),
                  _RacePhase.summary => _summaryView(context, accent),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: switch (_phase) {
                _RacePhase.brief => AppButton(
                    label: 'Start',
                    size: AppButtonSize.large,
                    color: accent,
                    onColor: _teamIndex == 0 ? p.onDanger : p.onSecondary,
                    onPressed: _startTurn,
                  ),
                _RacePhase.playing => Column(
                    children: [
                      AppButton(
                        label: 'Erraten',
                        size: AppButtonSize.large,
                        color: p.accentSafe,
                        onColor: p.onAccentSafe,
                        onPressed: () => _score(1, hit: true),
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        label: _isTaboo ? 'Verbotenes Wort — Punkt weg' : 'Überspringen',
                        filled: false,
                        onPressed: () => _score(_isTaboo ? -1 : 0, hit: false),
                      ),
                    ],
                  ),
                _RacePhase.summary => Column(
                    children: [
                      AppButton(
                        label: _isLastTurn ? 'Endstand ansehen' : 'Weiter an ${widget.teams[(_teamIndex + 1) % widget.teams.length].name}',
                        size: AppButtonSize.large,
                        onPressed: _nextTurn,
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

  Widget _briefView(BuildContext context, Color accent) {
    final p = context.palette;
    final explainer = _team.currentMember;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(germanUpper(_team.name), style: AppText.labelMono(accent, size: 12)),
            const SizedBox(height: 14),
            Text(
              explainer == null ? 'Team ist dran' : '${explainer.name} ${_isTaboo ? 'erklärt' : 'spielt vor'}',
              textAlign: TextAlign.center,
              style: AppText.headline(p.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              _isTaboo
                  ? 'Erklär den Begriff, ohne eines der fünf Wörter zu sagen. Jeder Ausrutscher kostet einen Punkt.'
                  : 'Nur vormachen — kein Wort, kein Geräusch. Das eigene Team rät.',
              textAlign: TextAlign.center,
              style: AppText.bodySmall(p.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('ZEIT', style: AppText.labelMono(p.textMuted, size: 11)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final seconds in const [45, 60, 90]) ...[
                  AppChip(
                    label: '$seconds S',
                    mono: true,
                    selected: _duration == seconds,
                    onTap: () => setState(() => _duration = seconds),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _ScoreLine(teams: widget.teams),
          ],
        ),
      ),
    );
  }

  Widget _playingView(BuildContext context, Color accent) {
    final p = context.palette;
    final card = _card;
    return Column(
      children: [
        const SizedBox(height: 6),
        RoundTimerBar(fraction: _duration == 0 ? 0 : _secondsLeft / _duration, color: accent),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatMmSs(_secondsLeft), style: AppText.monoValue(p.textPrimary, size: 20, weight: FontWeight.w700)),
            Text('$_roundHits GETROFFEN · $_roundScore PUNKTE', style: AppText.labelMono(p.textMuted, size: 11)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sheet),
                  border: Border.all(color: p.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isTaboo ? 'ERKLÄR DAS' : 'SPIEL DAS VOR', style: AppText.labelMono(accent, size: 11)),
                    const SizedBox(height: 14),
                    Text(card?.term ?? '—', style: AppText.display(p.textPrimary).copyWith(fontSize: 34, height: 1.15)),
                    if (_isTaboo && (card?.forbidden.isNotEmpty ?? false)) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Container(height: 1, color: p.outlineVariant),
                      const SizedBox(height: AppSpacing.lg),
                      Text('VERBOTEN', style: AppText.labelMono(p.danger, size: 11)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final word in card!.forbidden)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: p.danger.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(word, style: AppText.caption(p.danger).copyWith(fontSize: 14)),
                            ),
                        ],
                      ),
                    ],
                    if (!_isTaboo && card?.hint != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(card!.hint!, style: AppText.caption(p.textMuted).copyWith(fontSize: 14)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryView(BuildContext context, Color accent) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ZEIT UM', style: AppText.labelMono(p.danger, size: 12)),
          const SizedBox(height: 14),
          Text('$_roundScore ${_roundScore == 1 ? 'Punkt' : 'Punkte'} für ${_team.name}',
              textAlign: TextAlign.center, style: AppText.headline(p.textPrimary)),
          const SizedBox(height: 10),
          Text('$_roundHits Begriffe getroffen.', style: AppText.bodySmall(p.textSecondary)),
          const SizedBox(height: AppSpacing.xxl),
          _ScoreLine(teams: widget.teams),
        ],
      ),
    );
  }
}

class _ScoreLine extends StatelessWidget {
  const _ScoreLine({required this.teams});

  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < teams.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(':', style: AppText.monoValue(p.textFaint, size: 20)),
            ),
          Column(
            children: [
              Text('${teams[i].score}', style: AppText.monoDisplay(p.textPrimary, size: 34)),
              const SizedBox(height: 6),
              Text(germanUpper(teams[i].name),
                  style: AppText.labelMono(i == 0 ? p.danger : p.secondary, size: 10)),
            ],
          ),
        ],
      ],
    );
  }
}
