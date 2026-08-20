import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/content.dart';
import '../../data/deck.dart';
import '../../data/prompts_social.dart';
import '../../models/player.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/prompt_card.dart';
import '../shared/game_result_screen.dart';

enum PointVoteMode {
  /// Wer würde eher — the whole circle is up for election.
  everyone,

  /// Duell — two players are nominated, the rest decide between them.
  duel,
}

/// Shared engine for the two games where the group points at a person. The
/// only real difference is the size of the ballot, so the loop, the tally
/// and the podium are the same code.
class PointVoteScreen extends StatefulWidget {
  const PointVoteScreen({super.key, required this.players, required this.mode});

  final List<Player> players;
  final PointVoteMode mode;

  @override
  State<PointVoteScreen> createState() => _PointVoteScreenState();
}

class _PointVoteScreenState extends State<PointVoteScreen> {
  final _random = Random();

  late Deck<Prompt> _deck;
  Prompt? _card;
  List<Player> _candidates = [];

  int _round = 1;
  final Map<String, int> _points = {};

  bool get _isDuel => widget.mode == PointVoteMode.duel;

  @override
  void initState() {
    super.initState();
    _deck = Deck(context.read<AppState>().contentFilter.apply(_isDuel ? duelPrompts : wouldRatherPrompts));
    _dealRound();
  }

  void _dealRound() {
    _card = _deck.draw();
    if (_isDuel) {
      final pool = List.of(widget.players)..shuffle(_random);
      _candidates = pool.take(2).toList();
    } else {
      _candidates = widget.players;
    }
  }

  void _award(Player? winner) {
    setState(() {
      if (winner != null) {
        _points[winner.id] = (_points[winner.id] ?? 0) + 1;
      }
      _round += 1;
      _dealRound();
    });
  }

  void _restart() {
    setState(() {
      _deck = Deck(context.read<AppState>().contentFilter.apply(_isDuel ? duelPrompts : wouldRatherPrompts));
      _round = 1;
      _points.clear();
      _dealRound();
    });
  }

  void _finish() {
    final entries = widget.players.map((p) => ScoreEntry(name: p.name, score: _points[p.id] ?? 0)).toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: 'Die Gruppe hat gesprochen',
        subtitle: _isDuel
            ? 'Jeder Punkt ist ein gewonnenes Duell.'
            : 'Jeder Punkt ist ein "ja, genau der".',
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
    final card = _card;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: 'Frage $_round',
              trailingLabel: _isDuel ? 'Duell' : 'Alle',
              trailingColor: _isDuel ? p.danger : p.primary,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
                children: [
                  PromptCardView(
                    chips: [_isDuel ? 'Duell' : 'Wer würde eher'],
                    playerLine: _isDuel ? 'Zwei gegen den Rest' : 'Auf drei zeigen alle',
                    text: _isDuel ? (card?.text ?? '') : 'Wer würde eher ${card?.text ?? ''}',
                    footnote: _isDuel
                        ? 'Nur diese zwei stehen zur Wahl.'
                        : 'Einigt euch, dann tippt auf den Namen.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_isDuel) _duelBallot(context) else _fullBallot(context),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: Column(
                children: [
                  AppButton(label: 'Frage überspringen', filled: false, onPressed: () => _award(null)),
                  const SizedBox(height: 10),
                  AppButton(label: 'Runde beenden', filled: false, onPressed: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fullBallot(BuildContext context) {
    return Column(
      children: [
        for (final player in _candidates)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CandidateRow(
              player: player,
              colorIndex: widget.players.indexOf(player),
              points: _points[player.id] ?? 0,
              onTap: () => _award(player),
            ),
          ),
      ],
    );
  }

  Widget _duelBallot(BuildContext context) {
    final p = context.palette;
    if (_candidates.length < 2) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _DuelCard(player: _candidates[0], colorIndex: widget.players.indexOf(_candidates[0]), points: _points[_candidates[0].id] ?? 0, onTap: () => _award(_candidates[0]))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('VS', style: AppText.labelMono(p.textFaint, size: 13)),
        ),
        Expanded(child: _DuelCard(player: _candidates[1], colorIndex: widget.players.indexOf(_candidates[1]), points: _points[_candidates[1].id] ?? 0, onTap: () => _award(_candidates[1]))),
      ],
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({required this.player, required this.colorIndex, required this.points, required this.onTap});

  final Player player;
  final int colorIndex;
  final int points;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: p.outlineVariant),
          ),
          child: Row(
            children: [
              AvatarCircle(initial: player.initial, colorIndex: colorIndex, size: 42, fontSize: 17),
              const SizedBox(width: 14),
              Expanded(
                child: Text(player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title(p.textPrimary).copyWith(fontSize: 19)),
              ),
              if (points > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(color: p.primary.withValues(alpha: .16), borderRadius: BorderRadius.circular(999)),
                  child: Text('$points', style: AppText.monoValue(p.primary, size: 14, weight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DuelCard extends StatelessWidget {
  const _DuelCard({required this.player, required this.colorIndex, required this.points, required this.onTap});

  final Player player;
  final int colorIndex;
  final int points;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: p.outlineVariant),
          ),
          child: Column(
            children: [
              AvatarCircleRound(initial: player.initial, colorIndex: colorIndex, size: 68, fontSize: 28),
              const SizedBox(height: 12),
              Text(player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppText.title(p.textPrimary).copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text('$points', style: AppText.monoValue(p.textFaint, size: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
