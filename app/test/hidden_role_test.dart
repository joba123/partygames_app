import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/fact_cards.dart';
import 'package:imposter_party/data/liar_questions.dart';
import 'package:imposter_party/models/team.dart';
import 'package:imposter_party/screens/games/bet_buddy_screen.dart';
import 'package:imposter_party/screens/games/fake_fact_screen.dart';
import 'package:imposter_party/screens/games/liar_screen.dart';
import 'package:imposter_party/screens/shared/game_result_screen.dart';

import 'harness.dart';

void main() {
  group('Finde den Lügner', () {
    /// Which of the two questions of a pair is currently on screen.
    String questionOnScreen() {
      for (final q in liarQuestions) {
        if (find.text(q.real).evaluate().isNotEmpty) return 'real::${q.real}';
        if (find.text(q.decoy).evaluate().isNotEmpty) return 'decoy::${q.decoy}';
      }
      fail('no question rendered');
    }

    testWidgets('exactly one player is handed the decoy question', (tester) async {
      await tester.pumpWidget(harness(LiarScreen(players: testPlayers(4))));
      await tester.pump();

      final seen = <String>[];
      for (var i = 1; i <= 4; i++) {
        await tapText(tester, 'Ich bin Spieler$i');
        seen.add(questionOnScreen());
        await tester.enterText(find.byType(TextField), 'Antwort$i');
        await tester.pump();
        await tapText(tester, i < 4 ? 'Fertig — weiter an Spieler${i + 1}' : 'Fertig — alle Antworten zeigen');
      }

      final decoys = seen.where((s) => s.startsWith('decoy::')).toList();
      final reals = seen.where((s) => s.startsWith('real::')).toSet();

      expect(decoys, hasLength(1), reason: 'there must be exactly one liar');
      expect(reals, hasLength(1), reason: 'everyone else must get the same question');
    });

    testWidgets('the reveal shows every answer and the real question', (tester) async {
      await tester.pumpWidget(harness(LiarScreen(players: testPlayers(3))));
      await tester.pump();

      var liarTurn = -1;
      for (var i = 1; i <= 3; i++) {
        await tapText(tester, 'Ich bin Spieler$i');
        if (questionOnScreen().startsWith('decoy::')) liarTurn = i;
        await tester.enterText(find.byType(TextField), 'Antwort$i');
        await tester.pump();
        await tapText(tester, i < 3 ? 'Fertig — weiter an Spieler${i + 1}' : 'Fertig — alle Antworten zeigen');
      }

      expect(find.text('DIE ECHTE FRAGE WAR'), findsOneWidget);
      for (var i = 1; i <= 3; i++) {
        expect(find.text('Antwort$i'), findsOneWidget);
      }

      await tapText(tester, 'Abstimmen');
      await tapText(tester, 'Antwort$liarTurn');
      await tapText(tester, 'Auflösen');

      expect(find.text('ERWISCHT'), findsOneWidget);
      expect(find.text('Spieler$liarTurn hat gelogen'), findsOneWidget);
      expect(find.text('1 : 0'), findsOneWidget, reason: 'the group scored');
    });

    testWidgets('accusing the wrong player scores for the liar', (tester) async {
      await tester.pumpWidget(harness(LiarScreen(players: testPlayers(3))));
      await tester.pump();

      var liarTurn = -1;
      for (var i = 1; i <= 3; i++) {
        await tapText(tester, 'Ich bin Spieler$i');
        if (questionOnScreen().startsWith('decoy::')) liarTurn = i;
        await tester.enterText(find.byType(TextField), 'Antwort$i');
        await tester.pump();
        await tapText(tester, i < 3 ? 'Fertig — weiter an Spieler${i + 1}' : 'Fertig — alle Antworten zeigen');
      }

      final innocent = [1, 2, 3].firstWhere((i) => i != liarTurn);
      await tapText(tester, 'Abstimmen');
      await tapText(tester, 'Antwort$innocent');
      await tapText(tester, 'Auflösen');

      expect(find.text('DURCHGERUTSCHT'), findsOneWidget);
      expect(find.text('0 : 1'), findsOneWidget, reason: 'the liar scored');
    });
  });

  group('Fake oder Fakt', () {
    testWidgets('one player gets only the topic, the rest share one true fact', (tester) async {
      await tester.pumpWidget(harness(FakeFactScreen(players: testPlayers(4))));
      await tester.pump();

      var fakeTurn = -1;
      final factsSeen = <String>{};

      for (var i = 1; i <= 4; i++) {
        await tapText(tester, 'Ich bin Spieler$i');

        if (find.text('DU BIST DER FAKE').evaluate().isNotEmpty) {
          fakeTurn = i;
          expect(find.text('Denk dir einen Fakt aus, der zu diesem Thema passt.'), findsOneWidget);
        } else {
          expect(find.text('DEIN FAKT'), findsOneWidget);
          factsSeen.add(factCards.firstWhere((c) => find.text(c.fact).evaluate().isNotEmpty).fact);
        }

        await tapText(tester, i < 4 ? 'Gemerkt — weiter an Spieler${i + 1}' : 'Gemerkt — los geht’s');
      }

      expect(fakeTurn, isNot(-1), reason: 'somebody has to be the fake');
      expect(factsSeen, hasLength(1), reason: 'the honest players must share one fact');

      await tapText(tester, 'Alle durch — abstimmen');
      await tapText(tester, 'Spieler$fakeTurn');
      await tapText(tester, 'Auflösen');

      expect(find.text('ERWISCHT'), findsOneWidget);
      expect(find.text('Spieler$fakeTurn war der Fake'), findsOneWidget);
      // The round should leave the group knowing the real fact.
      expect(find.text(factsSeen.single), findsOneWidget);
    });
  });

  group('Bet Buddy', () {
    testWidgets('the team that wins the bidding has to deliver it', (tester) async {
      final teams = splitIntoTeams(testPlayers(4));
      await tester.pumpWidget(harness(BetBuddyScreen(teams: teams, roundsTotal: 2)));
      await tester.pump();

      await tapText(tester, 'Team Rot eröffnet');
      expect(find.text('${BetBuddyScreen.openingBid}'), findsOneWidget);

      await tapText(tester, '5 bieten — weiter an Team Blau');
      // Team Blau raises 6 -> 8 and commits.
      await tapText(tester, '+2');
      await tapText(tester, '8 bieten — weiter an Team Rot');

      await tapText(tester, 'Zeig’s uns! — Team Blau muss 8 liefern');
      expect(find.text('TEAM BLAU LIEFERT'), findsOneWidget);
      expect(find.text(' / 8'), findsOneWidget);

      for (var i = 0; i < 8; i++) {
        await tapText(tester, 'Zählt! +1');
      }

      expect(find.text('GELIEFERT'), findsOneWidget);
      expect(teams[1].score, 1, reason: 'delivering your own bid scores');
      expect(teams[0].score, 0);
    });

    testWidgets('running out of time hands the point to the challenger', (tester) async {
      final teams = splitIntoTeams(testPlayers(4));
      await tester.pumpWidget(harness(BetBuddyScreen(teams: teams, roundsTotal: 2)));
      await tester.pump();

      await tapText(tester, 'Team Rot eröffnet');
      await tapText(tester, '5 bieten — weiter an Team Blau');
      await tapText(tester, 'Zeig’s uns! — Team Rot muss 5 liefern');

      await tapText(tester, 'Zählt! +1');
      await tester.pump(const Duration(seconds: 91));
      await tester.pump();

      expect(find.text('NICHT GESCHAFFT'), findsOneWidget);
      expect(find.text('Team Rot kam nur auf 1 von 5'), findsOneWidget);
      expect(teams[1].score, 1, reason: 'the challenger takes the point');
    });

    testWidgets('the last round leads to the podium', (tester) async {
      final teams = splitIntoTeams(testPlayers(4));
      await tester.pumpWidget(harness(BetBuddyScreen(teams: teams, roundsTotal: 1)));
      await tester.pump();

      await tapText(tester, 'Team Rot eröffnet');
      await tapText(tester, '5 bieten — weiter an Team Blau');
      await tapText(tester, 'Zeig’s uns! — Team Rot muss 5 liefern');
      await tapText(tester, 'Aufgeben');

      await tapText(tester, 'Endstand ansehen');
      await settleRoute(tester);

      expect(find.byType(GameResultScreen), findsOneWidget);
      expect(find.text('Team Blau gewinnt'), findsOneWidget);
    });
  });
}
