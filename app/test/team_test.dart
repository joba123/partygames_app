import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/models/team.dart';

import 'harness.dart';

void main() {
  test('splits the roster alternately so pairs get separated', () {
    final teams = splitIntoTeams(testPlayers(5));

    expect(teams[0].members.map((p) => p.name), ['Spieler1', 'Spieler3', 'Spieler5']);
    expect(teams[1].members.map((p) => p.name), ['Spieler2', 'Spieler4']);
  });

  test('rotates the member on turn instead of always picking the first', () {
    final team = splitIntoTeams(testPlayers(4))[0];

    expect(team.currentMember?.name, 'Spieler1');
    team.advanceTurn();
    expect(team.currentMember?.name, 'Spieler3');
    team.advanceTurn();
    expect(team.currentMember?.name, 'Spieler1', reason: 'should wrap around');
  });
}
