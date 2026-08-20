import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/content.dart';
import '../../data/deck.dart';
import '../../data/games.dart';
import '../../data/prompts_truth_dare.dart';
import '../../models/player.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/prompt_card.dart';
import '../shared/game_result_screen.dart';

enum _Choice { truth, dare }

/// Wahrheit oder Pflicht. The phone goes round the circle; the player on
/// turn picks a side, gets a card from the filtered pool, and the group
/// decides whether it counted. Refusals are tracked separately so the
/// scoreboard can name the person who chickened out most.
class TruthOrDareScreen extends StatefulWidget {
  const TruthOrDareScreen({super.key, required this.game, required this.players});

  final GameInfo game;
  final List<Player> players;

  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen> {
  late Deck<Prompt> _truths;
  late Deck<Prompt> _dares;

  int _playerIndex = 0;
  int _round = 1;
  _Choice? _choice;
  Prompt? _card;

  final Map<String, int> _done = {};
  final Map<String, int> _refused = {};

  @override
  void initState() {
    super.initState();
    _buildDecks();
  }

  void _buildDecks() {
    final filter = context.read<AppState>().contentFilter;
    _truths = Deck(filter.apply(truthPrompts));
    _dares = Deck(filter.apply(darePrompts));
  }

  Player get _current => widget.players[_playerIndex % widget.players.length];

  void _pick(_Choice choice) {
    setState(() {
      _choice = choice;
      _card = (choice == _Choice.truth ? _truths : _dares).draw();
    });
  }

  void _resolve({required bool completed}) {
    final id = _current.id;
    setState(() {
      if (completed) {
        _done[id] = (_done[id] ?? 0) + 1;
      } else {
        _refused[id] = (_refused[id] ?? 0) + 1;
      }
      _playerIndex = (_playerIndex + 1) % widget.players.length;
      if (_playerIndex == 0) _round += 1;
      _choice = null;
      _card = null;
    });
  }

  void _restart() {
    setState(() {
      _buildDecks();
      _playerIndex = 0;
      _round = 1;
      _choice = null;
      _card = null;
      _done.clear();
      _refused.clear();
    });
  }

  void _finish() {
    final entries = widget.players
        .map((p) => ScoreEntry(
              name: p.name,
              score: _done[p.id] ?? 0,
              detail: (_refused[p.id] ?? 0) > 0 ? '${_refused[p.id]}× gekniffen' : null,
            ))
        .toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: 'Runde vorbei',
        subtitle: 'Gezählt wird, wer wirklich geliefert hat.',
        entries: entries,
        scoreUnit: 'Karten',
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
              status: 'Runde $_round · ${_current.name}',
              trailingLabel: _choice == null ? null : (_choice == _Choice.truth ? 'Wahrheit' : 'Pflicht'),
              trailingColor: _choice == _Choice.truth ? p.accentSafe : p.danger,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
                child: card == null ? _chooser(context) : _cardView(context, card),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 24),
              child: card == null ? _chooseActions(context) : _resolveActions(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chooser(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${_current.name.toUpperCase()}, DU BIST DRAN', style: AppText.labelMono(p.textMuted, size: 12)),
          const SizedBox(height: 18),
          Text('Wahrheit\noder Pflicht?', textAlign: TextAlign.center, style: AppText.display(p.textPrimary)),
          const SizedBox(height: 18),
          Text(
            'Wähl selbst. Danach entscheidet die Gruppe, ob es zählt.',
            textAlign: TextAlign.center,
            style: AppText.bodySmall(p.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _cardView(BuildContext context, Prompt card) {
    return SingleChildScrollView(
      child: PromptCardView(
        chips: [_choice == _Choice.truth ? 'Wahrheit' : 'Pflicht', card.spice.label],
        playerLine: '${_current.name}, los geht’s',
        text: card.text,
        footnote: _choice == _Choice.truth
            ? 'Ausweichen kostet — die Gruppe merkt sich das.'
            : 'Nicht gemacht heißt nicht gezählt.',
      ),
    );
  }

  Widget _chooseActions(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Wahrheit',
                size: AppButtonSize.large,
                color: p.accentSafe,
                onColor: p.onAccentSafe,
                onPressed: () => _pick(_Choice.truth),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                label: 'Pflicht',
                size: AppButtonSize.large,
                color: p.danger,
                onColor: p.onDanger,
                onPressed: () => _pick(_Choice.dare),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppButton(label: 'Runde beenden', filled: false, onPressed: _finish),
      ],
    );
  }

  Widget _resolveActions(BuildContext context) {
    final p = context.palette;
    final next = widget.players[(_playerIndex + 1) % widget.players.length];
    return Column(
      children: [
        AppButton(
          label: 'Gemacht — weiter an ${next.name}',
          size: AppButtonSize.large,
          color: p.secondary,
          onColor: p.onSecondary,
          onPressed: () => _resolve(completed: true),
        ),
        const SizedBox(height: 10),
        AppButton(label: 'Verweigert', filled: false, onPressed: () => _resolve(completed: false)),
      ],
    );
  }
}
