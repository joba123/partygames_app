import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/games.dart';
import 'package:imposter_party/screens/hub_screen.dart';
import 'package:imposter_party/state/app_state.dart';
import 'package:imposter_party/widgets/game_icons.dart';
import 'package:imposter_party/widgets/game_tile.dart';

import 'harness.dart';

void main() {
  test('no two games share an icon', () {
    final used = games.map((g) => g.icon).toList();

    expect(used.toSet().length, games.length, reason: 'an icon is doing double duty');
  });

  test('every glyph in the icon set belongs to a game', () {
    expect(games.map((g) => g.icon).toSet(), GameIconType.values.toSet());
  });

  test('team games ask for enough players to fill two teams', () {
    for (final game in games.where((g) => g.needsTeams)) {
      expect(game.minPlayers, greaterThanOrEqualTo(4), reason: '${game.title} cannot form two teams');
    }
  });

  testWidgets('the hub lists every game exactly once', (tester) async {
    await tester.pumpWidget(harness(const HubScreen(), state: AppState()));
    await tester.pump();

    // One game is featured in the hero card, the rest sit in the grid.
    expect(find.byType(HeroGameCard), findsOneWidget);

    for (final game in games) {
      expect(find.text(game.title), findsOneWidget, reason: '${game.title} missing from the hub');
    }
  });

  testWidgets('the category filter narrows the grid', (tester) async {
    final state = AppState();
    await tester.pumpWidget(harness(const HubScreen(), state: state));
    await tester.pump();

    state.setHubFilter(games.firstWhere((g) => g.title == 'Tabu').category);
    await tester.pump();

    expect(find.text('Tabu'), findsOneWidget);
    expect(find.text('Quiz-Battle'), findsNothing, reason: 'a different category should be filtered out');
  });
}
