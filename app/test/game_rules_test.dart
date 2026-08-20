import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/games.dart';
import 'package:imposter_party/data/quiz_questions.dart';
import 'package:imposter_party/models/team.dart';
import 'package:imposter_party/screens/games/bomb_screen.dart';
import 'package:imposter_party/screens/games/never_have_i_ever_screen.dart';
import 'package:imposter_party/screens/games/point_vote_screen.dart';
import 'package:imposter_party/screens/games/quiz_battle_screen.dart';
import 'package:imposter_party/screens/games/roulette_screen.dart';
import 'package:imposter_party/screens/games/truth_or_dare_screen.dart';
import 'package:imposter_party/screens/games/word_race_screen.dart';
import 'package:imposter_party/screens/shared/game_result_screen.dart';

import 'harness.dart';

void main() {
  group('Wahrheit oder Pflicht', () {
    testWidgets('deals a card, counts it and passes the phone on', (tester) async {
      await tester.pumpWidget(harness(
        TruthOrDareScreen(game: gameById(GameId.wahrheitOderPflicht), players: testPlayers(3)),
      ));
      await tester.pump();

      expect(find.text('RUNDE 1 · SPIELER1'), findsOneWidget);

      await tester.tap(find.widgetWithText(InkWell, 'Wahrheit').first);
      await tester.pump();
      expect(find.text('SPIELER1, LOS GEHT’S'), findsOneWidget);

      await tester.tap(find.text('Gemacht — weiter an Spieler2'));
      await tester.pump();
      expect(find.text('RUNDE 1 · SPIELER2'), findsOneWidget);
    });

    testWidgets('only completed cards score', (tester) async {
      await tester.pumpWidget(harness(
        TruthOrDareScreen(game: gameById(GameId.wahrheitOderPflicht), players: testPlayers(3)),
      ));
      await tester.pump();

      // Spieler1 delivers, the other two chicken out.
      await tester.tap(find.widgetWithText(InkWell, 'Pflicht').first);
      await tester.pump();
      await tester.tap(find.text('Gemacht — weiter an Spieler2'));
      await tester.pump();

      for (var i = 0; i < 2; i++) {
        await tester.tap(find.widgetWithText(InkWell, 'Wahrheit').first);
        await tester.pump();
        await tester.tap(find.text('Verweigert'));
        await tester.pump();
      }

      await tester.tap(find.text('Runde beenden'));
      await settleRoute(tester);

      expect(find.byType(GameResultScreen), findsOneWidget);
      expect(find.text('Spieler1 gewinnt'), findsOneWidget);
      expect(find.text('1× gekniffen'), findsNWidgets(2));
    });
  });

  group('Ich hab noch nie', () {
    testWidgets('tallies only the players who admitted it', (tester) async {
      await tester.pumpWidget(harness(NeverHaveIEverScreen(players: testPlayers(3))));
      await tester.pump();

      expect(find.text('KARTE 1'), findsOneWidget);

      await tapText(tester, 'Spieler2');
      expect(find.text('1/3'), findsOneWidget);

      await tapText(tester, 'Übernehmen und weiter');
      expect(find.text('KARTE 2'), findsOneWidget);
      expect(find.text('0/3'), findsOneWidget, reason: 'selection must reset for the new card');

      await tapText(tester, 'Runde beenden');
      await settleRoute(tester);

      expect(find.text('Spieler2 gewinnt'), findsOneWidget);
    });
  });

  group('Wer würde eher / Duell', () {
    testWidgets('a vote scores the player it was cast on', (tester) async {
      await tester.pumpWidget(harness(
        PointVoteScreen(players: testPlayers(3), mode: PointVoteMode.everyone),
      ));
      await tester.pump();

      expect(find.text('FRAGE 1'), findsOneWidget);

      await tapText(tester, 'Spieler3');
      expect(find.text('FRAGE 2'), findsOneWidget);

      await tapText(tester, 'Runde beenden');
      await settleRoute(tester);

      expect(find.text('Spieler3 gewinnt'), findsOneWidget);
    });

    testWidgets('the duel puts exactly two players on the ballot', (tester) async {
      await tester.pumpWidget(harness(
        PointVoteScreen(players: testPlayers(6), mode: PointVoteMode.duel),
      ));
      await tester.pump();

      final onBallot = testPlayers(6)
          .map((p) => p.name)
          .where((name) => find.text(name).evaluate().isNotEmpty)
          .length;

      expect(onBallot, 2);
      expect(find.text('VS'), findsOneWidget);
    });
  });

  group('Bombe', () {
    testWidgets('passing moves the bomb to the next player', (tester) async {
      await tester.pumpWidget(harness(BombScreen(players: testPlayers(3))));
      await tester.pump();

      await tester.tap(find.text('Spieler1 startet'));
      await tester.pump();
      expect(find.text('SPIELER1'), findsOneWidget);

      await tester.tap(find.text('Genannt — weiter an Spieler2'));
      await tester.pump();
      expect(find.text('SPIELER2'), findsOneWidget);
    });

    testWidgets('the fuse runs out on whoever is holding it and costs a life', (tester) async {
      await tester.pumpWidget(harness(BombScreen(players: testPlayers(3))));
      await tester.pump();

      await tester.tap(find.text('Spieler1 startet'));
      await tester.pump();

      // The fuse is random but capped at 42 s, so this always covers it.
      await tester.pump(const Duration(seconds: 45));
      await tester.pump();

      expect(find.text('Spieler1 hatte sie in der Hand'), findsOneWidget);
      expect(find.text('Ein Leben weniger — 1 übrig.'), findsOneWidget);
      expect(find.text('Nächste Runde'), findsOneWidget);
    });
  });

  group('Charade / Tabu', () {
    testWidgets('a hit scores for the team on turn, then play switches', (tester) async {
      final teams = splitIntoTeams(testPlayers(4));
      await tester.pumpWidget(harness(
        WordRaceScreen(teams: teams, variant: WordRaceVariant.charade, turnsPerTeam: 1),
      ));
      await tester.pump();

      expect(find.text('Spieler1 spielt vor'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pump();
      await tester.tap(find.text('Erraten'));
      await tester.pump();
      await tester.tap(find.text('Erraten'));
      await tester.pump();

      await tester.pump(const Duration(seconds: 61));
      await tester.pump();

      expect(find.text('2 Punkte für Team Rot'), findsOneWidget);
      expect(teams[0].score, 2);

      await tester.tap(find.text('Weiter an Team Blau'));
      await tester.pump();
      expect(find.text('Spieler2 spielt vor'), findsOneWidget);
    });

    testWidgets('Tabu shows the forbidden words and a slip costs a point', (tester) async {
      final teams = splitIntoTeams(testPlayers(4));
      await tester.pumpWidget(harness(
        WordRaceScreen(teams: teams, variant: WordRaceVariant.taboo, turnsPerTeam: 1),
      ));
      await tester.pump();

      await tester.tap(find.text('Start'));
      await tester.pump();

      expect(find.text('VERBOTEN'), findsOneWidget);

      await tester.tap(find.text('Erraten'));
      await tester.pump();
      await tester.tap(find.text('Verbotenes Wort — Punkt weg'));
      await tester.pump();

      await tester.pump(const Duration(seconds: 61));
      await tester.pump();

      expect(teams[0].score, 0, reason: 'one hit and one foul cancel out');
    });
  });

  group('Quiz-Battle', () {
    testWidgets('the right answer scores, the wrong one does not', (tester) async {
      final teams = splitIntoTeams(testPlayers(4));
      await tester.pumpWidget(harness(QuizBattleScreen(teams: teams, questionsPerTeam: 1)));
      await tester.pump();

      QuizQuestion onScreen() => quizQuestions.firstWhere(
            (q) => find.text(q.question).evaluate().isNotEmpty,
          );

      final first = onScreen();
      // Scope the tap to the answer button: several options are bare numbers
      // that also appear in the scoreboard above, and a raw text finder would
      // match both.
      await tester.tap(find.widgetWithText(InkWell, first.correctAnswer));
      await tester.pump();
      expect(teams[0].score, 1);

      await tester.tap(find.text('Weiter an Team Blau'));
      await tester.pump();

      final second = onScreen();
      final wrong = second.options.firstWhere((o) => o != second.correctAnswer);
      await tester.tap(find.widgetWithText(InkWell, wrong));
      await tester.pump();
      expect(teams[1].score, 0);

      await tester.tap(find.text('Endstand ansehen'));
      await settleRoute(tester);
      expect(find.text('Team Rot gewinnt'), findsOneWidget);
    });
  });

  group('Trinkspiel-Roulette', () {
    testWidgets('the wheel lands on a player and fills their name into the rule', (tester) async {
      await tester.pumpWidget(harness(RouletteScreen(players: testPlayers(4))));
      await tester.pump();

      await tester.tap(find.text('Rad drehen'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      final landed = testPlayers(4)
          .map((p) => p.name.toUpperCase())
          .where((name) => find.text(name).evaluate().isNotEmpty)
          .toList();

      expect(landed, hasLength(1), reason: 'exactly one player should be picked');
      expect(find.textContaining('%s'), findsNothing, reason: 'the placeholder must be substituted');
      expect(find.textContaining(landed.single.substring(0, 1)), findsWidgets);
    });
  });
}
