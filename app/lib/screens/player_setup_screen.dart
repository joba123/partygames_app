import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/games.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../widgets/buttons.dart';
import '../widgets/player_list_tile.dart';
import 'impostor/impostor_flow_screen.dart';
import 'generic/prompt_demo_screen.dart';
import 'generic/timer_demo_screen.dart';

/// Screen 03 — shared player-setup module for every game. Names persist
/// across games (kept in [AppState]). `game == null` opens it in
/// roster-management mode from the Hub's "Gruppe" tab.
class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key, required this.game});

  final GameInfo? game;

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(AppState appState) {
    if (_controller.text.trim().isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    if (appState.players.length >= 12) return;
    appState.addPlayer(_controller.text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _continue(AppState appState) {
    final game = widget.game;
    if (game == null) {
      Navigator.of(context).pop();
      return;
    }
    switch (game.playKind) {
      case GamePlayKind.impostor:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ImpostorFlowScreen(players: List.of(appState.players)),
        ));
        break;
      case GamePlayKind.timerDemo:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TimerDemoScreen(game: game)));
        break;
      case GamePlayKind.promptDemo:
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PromptDemoScreen(game: game, players: appState.players)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();
    final canContinue = appState.players.length >= 3;
    final game = widget.game;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 14),
                      Text(game == null ? 'GRUPPE VERWALTEN' : 'SCHRITT 1 VON 2', style: AppText.labelMono(p.textMuted, size: 11)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Wer spielt mit?', style: AppText.headline(p.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Mindestens 3. Namen bleiben für alle Spiele gespeichert.', style: AppText.bodySmall(p.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                children: [
                  for (var i = 0; i < appState.players.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PlayerListTile(
                        name: appState.players[i].name,
                        colorIndex: i,
                        onRemove: () => appState.removePlayer(appState.players[i].id),
                      ),
                    ),
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.primary, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(color: p.surfaceContainer, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text('?', style: AppText.nameLabel(p.textFaint).copyWith(fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: AppText.nameLabel(p.primary),
                            cursorColor: p.primary,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Name eingeben',
                              hintStyle: AppText.nameLabel(p.primary),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _submit(appState),
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        Text('${appState.players.length}/12', style: AppText.labelMono(p.textFaint, size: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _submit(appState),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: p.outline, style: BorderStyle.solid),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, size: 18, color: p.textMuted),
                            const SizedBox(width: 10),
                            Text('Spieler hinzufügen', style: AppText.buttonLabel(p.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      AppChip(
                        label: 'LETZTE RUNDE LADEN',
                        mono: true,
                        onTap: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Keine gespeicherte Runde gefunden'))),
                      ),
                      const SizedBox(width: 8),
                      AppChip(label: 'MISCHEN', mono: true, onTap: appState.shufflePlayers),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 30),
              child: Column(
                children: [
                  AppButton(
                    label: game == null
                        ? 'Fertig'
                        : (game.playKind == GamePlayKind.impostor ? 'Weiter zu den Rollen' : 'Weiter zum Spiel'),
                    size: AppButtonSize.large,
                    onPressed: canContinue ? () => _continue(appState) : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    canContinue ? (game == null ? '' : 'Handy wird gleich herumgegeben') : 'Noch ${3 - appState.players.length} Spieler nötig',
                    style: AppText.caption(p.textFaint).copyWith(fontSize: 12),
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
