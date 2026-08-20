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
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/prompt_card.dart';
import '../shared/game_result_screen.dart';

/// Ich hab noch nie. One card at a time, everyone who has done it taps their
/// own name before the card is turned — so the tally at the end is the
/// group's own bookkeeping, not a guess.
class NeverHaveIEverScreen extends StatefulWidget {
  const NeverHaveIEverScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<NeverHaveIEverScreen> createState() => _NeverHaveIEverScreenState();
}

class _NeverHaveIEverScreenState extends State<NeverHaveIEverScreen> {
  late Deck<Prompt> _deck;
  Prompt? _card;

  int _round = 1;
  final Set<String> _admitted = {};
  final Map<String, int> _tally = {};

  @override
  void initState() {
    super.initState();
    _deck = Deck(context.read<AppState>().contentFilter.apply(neverHaveIEverPrompts));
    _card = _deck.draw();
  }

  void _next() {
    setState(() {
      for (final id in _admitted) {
        _tally[id] = (_tally[id] ?? 0) + 1;
      }
      _admitted.clear();
      _round += 1;
      _card = _deck.draw();
    });
  }

  void _restart() {
    setState(() {
      _deck = Deck(context.read<AppState>().contentFilter.apply(neverHaveIEverPrompts));
      _card = _deck.draw();
      _round = 1;
      _admitted.clear();
      _tally.clear();
    });
  }

  void _finish() {
    final entries = widget.players
        .map((p) => ScoreEntry(name: p.name, score: _tally[p.id] ?? 0))
        .toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: 'Alles rausgelassen',
        subtitle: 'Wer am meisten zugegeben hat, führt.',
        entries: entries,
        scoreUnit: 'Treffer',
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
              status: 'Karte $_round',
              trailingLabel: '${_admitted.length}/${widget.players.length}',
              trailingColor: p.accentSafe,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
                children: [
                  PromptCardView(
                    chips: const ['Ich hab noch nie'],
                    playerLine: 'Alle gleichzeitig',
                    text: card?.text ?? 'Keine Karten übrig.',
                    footnote: 'Wer es getan hat, tippt unten auf seinen Namen.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('WER SCHON?', style: AppText.labelMono(p.textMuted, size: 11)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final player in widget.players)
                        _AdmitChip(
                          name: player.name,
                          count: _tally[player.id] ?? 0,
                          selected: _admitted.contains(player.id),
                          onTap: () => setState(() {
                            if (!_admitted.remove(player.id)) _admitted.add(player.id);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: Column(
                children: [
                  AppButton(
                    label: _admitted.isEmpty ? 'Keiner — nächste Karte' : 'Übernehmen und weiter',
                    size: AppButtonSize.large,
                    onPressed: _next,
                  ),
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
}

class _AdmitChip extends StatelessWidget {
  const _AdmitChip({required this.name, required this.count, required this.selected, required this.onTap});

  final String name;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = selected ? p.accentSafe : p.surface;
    final fg = selected ? p.onAccentSafe : p.textSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: onTap,
        child: Container(
          height: AppSpacing.minTouchTarget,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: selected ? null : Border.all(color: p.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: AppText.nameLabel(fg).copyWith(fontSize: 15)),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Text('$count', style: AppText.monoValue(selected ? fg : p.textFaint, size: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
