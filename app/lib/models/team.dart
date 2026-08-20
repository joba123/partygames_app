import 'player.dart';

/// Two fixed teams for Charade, Tabu and Quiz-Battle. Kept deliberately
/// simple: the roster is split down the middle, the group can re-shuffle,
/// and scores live here for the round engine to bump.
class Team {
  Team({required this.name, required this.members, this.score = 0});

  final String name;
  final List<Player> members;
  int score;

  /// Whose turn it is inside the team — Charade and Tabu rotate the
  /// explainer so the same person does not perform every round.
  int _turn = 0;

  Player? get currentMember => members.isEmpty ? null : members[_turn % members.length];

  void advanceTurn() => _turn++;
}

/// Alternating split (1st, 3rd, 5th … vs 2nd, 4th …) so a roster entered in
/// friend-pairs does not end up with both halves of every pair on one side.
List<Team> splitIntoTeams(List<Player> players) {
  final a = <Player>[];
  final b = <Player>[];
  for (var i = 0; i < players.length; i++) {
    (i.isEven ? a : b).add(players[i]);
  }
  return [
    Team(name: 'Team Rot', members: a),
    Team(name: 'Team Blau', members: b),
  ];
}
