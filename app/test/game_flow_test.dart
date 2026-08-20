import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/games.dart';
import 'package:imposter_party/screens/games/bet_buddy_screen.dart';
import 'package:imposter_party/screens/games/circa_screen.dart';
import 'package:imposter_party/screens/games/bomb_screen.dart';
import 'package:imposter_party/screens/games/fake_fact_screen.dart';
import 'package:imposter_party/screens/games/hundred_questions_screen.dart';
import 'package:imposter_party/screens/games/liar_screen.dart';
import 'package:imposter_party/screens/games/never_have_i_ever_screen.dart';
import 'package:imposter_party/screens/games/point_vote_screen.dart';
import 'package:imposter_party/screens/games/quiz_battle_screen.dart';
import 'package:imposter_party/screens/games/roulette_screen.dart';
import 'package:imposter_party/screens/games/ten_out_of_ten_screen.dart';
import 'package:imposter_party/screens/games/truth_or_dare_screen.dart';
import 'package:imposter_party/screens/games/werewolf_screen.dart';
import 'package:imposter_party/screens/games/word_race_screen.dart';
import 'package:imposter_party/screens/impostor/impostor_flow_screen.dart';
import 'package:imposter_party/screens/player_setup_screen.dart';
import 'package:imposter_party/screens/shared/category_picker_screen.dart';
import 'package:imposter_party/screens/shared/team_setup_screen.dart';
import 'package:imposter_party/state/app_state.dart';

import 'harness.dart';

/// Which screen each catalogue entry must actually land on. If a game is ever
/// wired back to a placeholder, this map is what fails.
const _expectedScreen = <GamePlayKind, Type>{
  GamePlayKind.impostor: ImpostorFlowScreen,
  GamePlayKind.truthOrDare: TruthOrDareScreen,
  GamePlayKind.neverHaveIEver: NeverHaveIEverScreen,
  GamePlayKind.pointVote: PointVoteScreen,
  GamePlayKind.duel: PointVoteScreen,
  GamePlayKind.bomb: BombScreen,
  GamePlayKind.roulette: RouletteScreen,
  GamePlayKind.charade: WordRaceScreen,
  GamePlayKind.taboo: WordRaceScreen,
  GamePlayKind.quiz: QuizBattleScreen,
  GamePlayKind.liar: LiarScreen,
  GamePlayKind.fakeFact: FakeFactScreen,
  GamePlayKind.bet: BetBuddyScreen,
  GamePlayKind.werewolf: WerewolfScreen,
  GamePlayKind.hundredQuestions: HundredQuestionsScreen,
  GamePlayKind.tenOutOfTen: TenOutOfTenScreen,
  GamePlayKind.circa: CircaScreen,
};

void main() {
  setUp(useFakePreferences);

  test('the catalogue has no unmapped play kind', () {
    expect(_expectedScreen.keys.toSet(), GamePlayKind.values.toSet());
    for (final game in games) {
      expect(_expectedScreen.containsKey(game.playKind), isTrue, reason: '${game.title} has no screen');
    }
  });

  for (final game in games) {
    testWidgets('${game.title} starts a real round from the setup screen', (tester) async {
      final state = AppState();
      // The catalogue's own floor, so a 4-player game is not started with 3.
      while (state.players.length < game.minPlayers) {
        state.addPlayer('Extra${state.players.length}');
      }

      await tester.pumpWidget(harness(PlayerSetupScreen(game: game), state: state));
      await tester.pump();

      final start = find.byWidgetPredicate(
        (w) => w is Text && (w.data?.startsWith('Weiter') ?? false),
      );
      expect(start, findsOneWidget, reason: 'no continue button on the setup screen');
      await tester.tap(start);
      await settleRoute(tester);

      if (game.picksCategories) {
        expect(find.byType(CategoryPickerScreen), findsOneWidget);
        expect(find.text('Womit spielt ihr?'), findsOneWidget);
        await tester.tap(find.text('Runde starten'));
        await settleRoute(tester);
      }

      if (game.needsTeams) {
        expect(find.byType(TeamSetupScreen), findsOneWidget);
        await tester.tap(find.text('Los geht’s'));
        await settleRoute(tester);
      }

      expect(find.byType(_expectedScreen[game.playKind]!), findsOneWidget);
      expect(state.lastPlayed, game.id, reason: 'the hub hero should follow what was played');
    });
  }
}
