import 'package:flutter/material.dart';
import '../../data/games.dart';
import '../../models/player.dart';
import '../../theme/app_colors.dart' show GameCategoryLabel;
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/prompt_card.dart';

const _promptsByGame = {
  GameId.wahrheitOderPflicht: [
    ('WAHRHEIT', 'Was ist die peinlichste Nachricht in deinem Postfach?'),
    ('PFLICHT', 'Ruf die dritte Person in deiner Anrufliste an und sing ihr ein Ständchen.'),
    ('WAHRHEIT', 'Wen hier würdest du am ehesten vermissen, wenn du umziehst?'),
  ],
  GameId.werWuerdeEher: [
    ('WER WÜRDE EHER', 'auf einer einsamen Insel überleben?'),
    ('WER WÜRDE EHER', 'als Erstes berühmt werden?'),
    ('WER WÜRDE EHER', 'mitten in der Nacht anrufen?'),
  ],
  GameId.ichHabNochNie: [
    ('ICH HAB NOCH NIE', 'einen Roadtrip ohne Plan gemacht.'),
    ('ICH HAB NOCH NIE', 'in der Öffentlichkeit geschlafen.'),
    ('ICH HAB NOCH NIE', 'jemanden aus Versehen geghostet.'),
  ],
  GameId.charade: [
    ('PANTOMIME', 'Stelle einen Astronauten beim Frühstück dar.'),
    ('PANTOMIME', 'Stelle einen Pinguin im Fitnessstudio dar.'),
  ],
  GameId.mostLikelyToDuell: [
    ('DUELL', 'Wer würde eher ein Startup gründen?'),
    ('DUELL', 'Wer würde eher im Dschungelcamp landen?'),
  ],
  GameId.quizBattle: [
    ('QUIZ', 'In welchem Jahr fiel die Berliner Mauer?'),
    ('QUIZ', 'Wie viele Bundesländer hat Deutschland?'),
  ],
};

/// Screen 11 — one card component behind Wahrheit oder Pflicht, Wer würde
/// eher, Ich hab noch nie, Tabu etc.: category chips, task 36px, primary
/// action always names the next player.
class PromptDemoScreen extends StatefulWidget {
  const PromptDemoScreen({super.key, required this.game, required this.players});

  final GameInfo game;
  final List<Player> players;

  @override
  State<PromptDemoScreen> createState() => _PromptDemoScreenState();
}

class _PromptDemoScreenState extends State<PromptDemoScreen> {
  int _playerIndex = 0;
  int _cardIndex = 1;

  List<(String, String)> get _prompts =>
      _promptsByGame[widget.game.id] ?? const [('AUFGABE', 'Erzähl der Gruppe deinen letzten Traum.')];

  void _advance() {
    setState(() {
      _playerIndex = (_playerIndex + 1) % widget.players.length;
      _cardIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final prompt = _prompts[_cardIndex % _prompts.length];
    final current = widget.players[_playerIndex];
    final next = widget.players[(_playerIndex + 1) % widget.players.length];

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
                  Text('KARTE $_cardIndex', style: AppText.labelMono(p.textMuted, size: 11)),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
                child: PromptCardView(
                  chips: [prompt.$1, widget.game.category.label],
                  playerLine: '${current.name}, du bist dran',
                  text: prompt.$2,
                  footnote: widget.game.description,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 18, AppSpacing.screenPadding, 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: AppButton(label: 'Verweigert', filled: false, onPressed: _advance)),
                      const SizedBox(width: 10),
                      Expanded(child: AppButton(label: 'Überspringen', filled: false, onPressed: _advance)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Gemacht — weiter an ${next.name}',
                    size: AppButtonSize.large,
                    color: p.secondary,
                    onColor: p.onSecondary,
                    onPressed: _advance,
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
