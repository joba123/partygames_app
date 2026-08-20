import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/content.dart';
import '../../data/deck.dart';
import '../../data/hundred_questions.dart';
import '../../models/player.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../../widgets/prompt_card.dart';

/// 100 Fragen. No timer, no score — the card is only the opener, the round
/// happens in the conversation. Skipping is a first-class action here:
/// a question you do not want to answer should cost nothing.
class HundredQuestionsScreen extends StatefulWidget {
  const HundredQuestionsScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<HundredQuestionsScreen> createState() => _HundredQuestionsScreenState();
}

class _HundredQuestionsScreenState extends State<HundredQuestionsScreen> {
  late Deck<Prompt> _deck;
  Prompt? _card;
  int _playerIndex = 0;
  int _number = 1;

  @override
  void initState() {
    super.initState();
    _deck = Deck(context.read<AppState>().contentFilter.apply(hundredQuestions));
    _card = _deck.draw();
  }

  void _advance({required bool counted}) {
    setState(() {
      if (counted) _number += 1;
      _playerIndex = (_playerIndex + 1) % widget.players.length;
      _card = _deck.draw();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final current = widget.players[_playerIndex];
    final next = widget.players[(_playerIndex + 1) % widget.players.length];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(
              status: 'Frage $_number',
              trailingLabel: _card?.spice.label,
              trailingColor: p.secondary,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 0),
                child: PromptCardView(
                  chips: const ['100 Fragen'],
                  playerLine: '${current.name}, an dich',
                  text: _card?.text ?? '',
                  footnote: 'Ehrlich oder gar nicht. Nachfragen sind erlaubt.',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 24),
              child: Column(
                children: [
                  AppButton(
                    label: 'Beantwortet — weiter an ${next.name}',
                    size: AppButtonSize.large,
                    color: p.secondary,
                    onColor: p.onSecondary,
                    onPressed: () => _advance(counted: true),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Andere Frage',
                    filled: false,
                    onPressed: () => setState(() => _card = _deck.draw()),
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
