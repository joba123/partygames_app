import 'package:flutter/material.dart';
import '../../data/games.dart';
import '../../models/player.dart';
import '../../models/team.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';

/// Step 2 for the three team games. The roster is split automatically;
/// tapping a player moves them across, because in practice the group always
/// wants to fix exactly one placement.
class TeamSetupScreen extends StatefulWidget {
  const TeamSetupScreen({
    super.key,
    required this.game,
    required this.players,
    required this.gameBuilder,
    this.stepLabel = 'Schritt 2 von 2',
  });

  /// e.g. "Schritt 3 von 3" once a category step precedes this one.
  final String stepLabel;

  final GameInfo game;
  final List<Player> players;

  /// Builds the game screen once the split is confirmed. The setup screen
  /// replaces itself with it, so Back from the game lands on the roster
  /// rather than on the team split again.
  final Widget Function(List<Team> teams) gameBuilder;

  @override
  State<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  late List<List<Player>> _sides;

  @override
  void initState() {
    super.initState();
    _sides = splitIntoTeams(widget.players).map((t) => t.members).toList();
  }

  void _move(Player player, int from) {
    setState(() {
      _sides[from].remove(player);
      _sides[1 - from].add(player);
    });
  }

  void _shuffle() {
    final all = [..._sides[0], ..._sides[1]]..shuffle();
    setState(() => _sides = splitIntoTeams(all).map((t) => t.members).toList());
  }

  bool get _playable => _sides[0].isNotEmpty && _sides[1].isNotEmpty;

  void _start() {
    final teams = [
      Team(name: 'Team Rot', members: List.of(_sides[0])),
      Team(name: 'Team Blau', members: List.of(_sides[1])),
    ];
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.gameBuilder(teams)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameHeader(status: '${widget.stepLabel} · ${widget.game.title}'),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 6, AppSpacing.screenPadding, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zwei Teams', style: AppText.headline(p.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Tippt auf einen Namen, um ihn ins andere Team zu schieben.',
                      style: AppText.bodySmall(p.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                children: [
                  _TeamCard(
                    title: 'Team Rot',
                    accent: p.danger,
                    members: _sides[0],
                    allPlayers: widget.players,
                    onTapMember: (player) => _move(player, 0),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _TeamCard(
                    title: 'Team Blau',
                    accent: p.secondary,
                    members: _sides[1],
                    allPlayers: widget.players,
                    onTapMember: (player) => _move(player, 1),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppChip(label: 'NEU MISCHEN', mono: true, onTap: _shuffle),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 28),
              child: Column(
                children: [
                  AppButton(
                    label: 'Los geht’s',
                    size: AppButtonSize.large,
                    onPressed: _playable ? _start : null,
                  ),
                  if (!_playable) ...[
                    const SizedBox(height: 10),
                    Text('Beide Teams brauchen mindestens einen Spieler.',
                        style: AppText.caption(p.textFaint).copyWith(fontSize: 12)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.title,
    required this.accent,
    required this.members,
    required this.allPlayers,
    required this.onTapMember,
  });

  final String title;
  final Color accent;
  final List<Player> members;
  final List<Player> allPlayers;
  final ValueChanged<Player> onTapMember;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: p.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(germanUpper(title), style: AppText.labelMono(accent, size: 12)),
              const Spacer(),
              Text('${members.length}', style: AppText.monoValue(p.textFaint, size: 13)),
            ],
          ),
          const SizedBox(height: 14),
          if (members.isEmpty)
            Text('Leer — schieb jemanden rüber.', style: AppText.caption(p.textFaint))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final player in members)
                  Material(
                    color: p.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => onTapMember(player),
                      child: Container(
                        height: AppSpacing.minTouchTarget,
                        padding: const EdgeInsets.fromLTRB(6, 0, 14, 0),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AvatarCircle(
                              initial: player.initial,
                              colorIndex: allPlayers.indexOf(player),
                              size: 34,
                              fontSize: 14,
                            ),
                            const SizedBox(width: 10),
                            Text(player.name, style: AppText.nameLabel(p.textPrimary).copyWith(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
