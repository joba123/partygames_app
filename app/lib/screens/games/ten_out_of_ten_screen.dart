import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/content.dart';
import '../../data/deck.dart';
import '../../data/hundred_questions.dart';
import '../../models/player.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../shared/game_result_screen.dart';

/// Er/Sie ist eine 10/10, aber …
///
/// Reihum bekommt jemand den Satzanfang über eine ausgeloste Zielperson und
/// vervollständigt ihn laut. Der Punkt für die beste Antwort ist eine
/// Zugabe von uns — ohne ihn hätte die Runde kein Ende und keinen Sieger.
class TenOutOfTenScreen extends StatefulWidget {
  const TenOutOfTenScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<TenOutOfTenScreen> createState() => _TenOutOfTenScreenState();
}

class _TenOutOfTenScreenState extends State<TenOutOfTenScreen> {
  final _random = Random();

  late Deck<Prompt> _deck;
  Prompt? _opener;
  int _speakerIndex = 0;
  int _targetIndex = 0;
  int _round = 1;

  final Map<String, int> _points = {};

  @override
  void initState() {
    super.initState();
    _deck = Deck(context.read<AppState>().contentFilter.apply(tenOutOfTenOpeners));
    _deal();
  }

  void _deal() {
    _opener = _deck.draw();
    // Never point the card at the person who has to fill it in.
    final others = [
      for (var i = 0; i < widget.players.length; i++)
        if (i != _speakerIndex) i,
    ];
    _targetIndex = others[_random.nextInt(others.length)];
  }

  void _advance({bool awardSpeaker = false}) {
    setState(() {
      if (awardSpeaker) {
        final id = widget.players[_speakerIndex].id;
        _points[id] = (_points[id] ?? 0) + 1;
      }
      _speakerIndex = (_speakerIndex + 1) % widget.players.length;
      _round += 1;
      _deal();
    });
  }

  void _finish() {
    final entries = widget.players
        .map((p) => ScoreEntry(name: p.name, score: _points[p.id] ?? 0))
        .toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => GameResultScreen(
        title: 'Abgerechnet',
        subtitle: 'Ein Punkt je Antwort, die die Runde zerlegt hat.',
        entries: entries,
        scoreUnit: 'Punkte',
        onRematch: () {
          Navigator.of(context).pop();
          setState(() {
            _points.clear();
            _round = 1;
            _speakerIndex = 0;
            _deal();
          });
        },
        onExit: () => Navigator.of(context).popUntil((r) => r.isFirst),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final speaker = widget.players[_speakerIndex];
    final target = widget.players[_targetIndex];
    final text = (_opener?.text ?? '').replaceAll('%s', target.name);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(status: 'Runde $_round · ${speaker.name}', trailingLabel: '10/10', trailingColor: p.primary),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    AvatarCircleRound(initial: target.initial, colorIndex: _targetIndex, size: 96, fontSize: 40),
                    const SizedBox(height: AppSpacing.xl),
                    Text(germanUpper('${speaker.name} vervollständigt'),
                        style: AppText.labelMono(p.textMuted, size: 11)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(AppRadius.sheet),
                        border: Border.all(color: p.outlineVariant),
                      ),
                      child: Text(text, style: AppText.headline(p.textPrimary).copyWith(fontSize: 27, height: 1.25)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Satz zu Ende bringen. Kein Nachdenken, erster Impuls.',
                        textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 24),
              child: Column(
                children: [
                  AppButton(
                    label: 'Das saß — Punkt für ${speaker.name}',
                    size: AppButtonSize.large,
                    onPressed: () => _advance(awardSpeaker: true),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: AppButton(label: 'Weiter', filled: false, onPressed: () => _advance())),
                      const SizedBox(width: 10),
                      Expanded(child: AppButton(label: 'Beenden', filled: false, onPressed: _finish)),
                    ],
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
