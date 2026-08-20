import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/circa_questions.dart';
import 'package:imposter_party/screens/games/circa_screen.dart';
import 'package:imposter_party/screens/games/hundred_questions_screen.dart';
import 'package:imposter_party/screens/games/ten_out_of_ten_screen.dart';
import 'package:imposter_party/screens/games/werewolf_screen.dart';
import 'package:imposter_party/screens/shared/game_result_screen.dart';

import 'harness.dart';

/// The candidate lists differ by role, so a test cannot know which name will
/// be on screen — it picks whichever is offered.
Future<String> tapFirstPlayerRow(WidgetTester tester, int playerCount) async {
  for (var i = 1; i <= playerCount; i++) {
    final name = 'Spieler$i';
    if (find.text(name).evaluate().isNotEmpty) {
      await tapText(tester, name);
      return name;
    }
  }
  fail('no player offered to pick');
}

void main() {
  group('Werwölfe', () {
    testWidgets('deals a role to everyone and plays a full night and day', (tester) async {
      await tester.pumpWidget(harness(WerewolfScreen(players: testPlayers(6))));
      await tester.pump();

      // Role handout.
      for (var i = 1; i <= 6; i++) {
        await tapText(tester, 'Ich bin Spieler$i');
        expect(find.textContaining('Spieler$i, du bist'.toUpperCase()), findsOneWidget);
        await tapText(tester, i < 6 ? 'Gemerkt — weiter an Spieler${i + 1}' : 'Alle haben ihre Rolle');
      }

      expect(find.text('Nacht 1'), findsOneWidget);
      await tapText(tester, 'Werwölfe aufwecken');
      await tapText(tester, 'Wir sind wach');

      await tapFirstPlayerRow(tester, 6);
      await tapText(tester, 'Opfer bestätigen');

      // Seer.
      await tapText(tester, 'Ich bin wach');
      await tapFirstPlayerRow(tester, 6);
      await tapText(tester, 'Hineinschauen');
      expect(find.textContaining('ist '), findsWidgets, reason: 'the seer must be told a role');
      await tapText(tester, 'Gemerkt — weiterschlafen');

      // Witch — present from six players up.
      await tapText(tester, 'Ich bin wach');
      await tapText(tester, 'Nichts tun — weiterschlafen');

      expect(find.text('DER MORGEN DANACH'), findsOneWidget);
      await tapText(tester, 'Das Dorf berät');

      expect(find.text('Wen hängt das Dorf?'), findsOneWidget);
      await tapFirstPlayerRow(tester, 6);
      await tapText(tester, 'Urteil vollstrecken');

      expect(find.textContaining('hängt'), findsOneWidget);
      expect(find.textContaining('war '), findsOneWidget, reason: 'the lynched role is revealed');
    });

    testWidgets('the heal keeps the victim alive through the morning', (tester) async {
      await tester.pumpWidget(harness(WerewolfScreen(players: testPlayers(6))));
      await tester.pump();

      for (var i = 1; i <= 6; i++) {
        await tapText(tester, 'Ich bin Spieler$i');
        await tapText(tester, i < 6 ? 'Gemerkt — weiter an Spieler${i + 1}' : 'Alle haben ihre Rolle');
      }

      await tapText(tester, 'Werwölfe aufwecken');
      await tapText(tester, 'Wir sind wach');
      await tapFirstPlayerRow(tester, 6);
      await tapText(tester, 'Opfer bestätigen');

      await tapText(tester, 'Ich bin wach');
      await tapFirstPlayerRow(tester, 6);
      await tapText(tester, 'Hineinschauen');
      await tapText(tester, 'Gemerkt — weiterschlafen');

      await tapText(tester, 'Ich bin wach');
      await tapText(tester, 'Heiltrank einsetzen');

      expect(find.text('Alle leben noch'), findsOneWidget);
    });
  });

  group('Circa', () {
    testWidgets('the closest guess takes the point', (tester) async {
      await tester.pumpWidget(harness(CircaScreen(players: testPlayers(3))));
      await tester.pump();

      await tapText(tester, 'Ich bin Spieler1');
      final question = circaQuestions.firstWhere((q) => find.text(q.question).evaluate().isNotEmpty);

      // Spieler2 lands exactly, so the point can only be theirs.
      final guesses = [question.answer - 100, question.answer, question.answer + 40];
      for (var i = 0; i < 3; i++) {
        if (i > 0) await tapText(tester, 'Ich bin Spieler${i + 1}');
        await tester.enterText(find.byType(TextField), '${guesses[i]}');
        await tester.pump();
        await tapText(tester, i < 2 ? 'Getippt — weiter an Spieler${i + 2}' : 'Getippt — auflösen');
      }

      expect(find.text('${question.answer}'), findsWidgets);
      expect(find.text('näher war keiner'), findsOneWidget);
      expect(find.text('100 daneben'), findsOneWidget);
      expect(find.text('40 daneben'), findsOneWidget);

      await tapText(tester, 'Runde beenden');
      await settleRoute(tester);
      expect(find.text('Spieler2 gewinnt'), findsOneWidget);
    });

    testWidgets('an equally close pair shares the point', (tester) async {
      await tester.pumpWidget(harness(CircaScreen(players: testPlayers(3))));
      await tester.pump();

      await tapText(tester, 'Ich bin Spieler1');
      final question = circaQuestions.firstWhere((q) => find.text(q.question).evaluate().isNotEmpty);

      final guesses = [question.answer - 5, question.answer + 5, question.answer + 60];
      for (var i = 0; i < 3; i++) {
        if (i > 0) await tapText(tester, 'Ich bin Spieler${i + 1}');
        await tester.enterText(find.byType(TextField), '${guesses[i]}');
        await tester.pump();
        await tapText(tester, i < 2 ? 'Getippt — weiter an Spieler${i + 2}' : 'Getippt — auflösen');
      }

      expect(find.text('näher war keiner'), findsNWidgets(2));
    });
  });

  group('Er/Sie ist eine 10/10', () {
    testWidgets('never points the card at the person filling it in', (tester) async {
      await tester.pumpWidget(harness(TenOutOfTenScreen(players: testPlayers(4))));
      await tester.pump();

      for (var round = 1; round <= 8; round++) {
        final speaker = 'Spieler${(round - 1) % 4 + 1}';
        expect(find.text('RUNDE $round · ${speaker.toUpperCase()}'), findsOneWidget);
        expect(
          find.textContaining('$speaker ist eine'),
          findsNothing,
          reason: '$speaker must not have to complete a card about themselves',
        );
        await tapText(tester, 'Weiter');
      }
    });

    testWidgets('the point goes to whoever landed the line', (tester) async {
      await tester.pumpWidget(harness(TenOutOfTenScreen(players: testPlayers(3))));
      await tester.pump();

      await tapText(tester, 'Das saß — Punkt für Spieler1');
      await tapText(tester, 'Weiter');
      await tapText(tester, 'Beenden');
      await settleRoute(tester);

      expect(find.byType(GameResultScreen), findsOneWidget);
      expect(find.text('Spieler1 gewinnt'), findsOneWidget);
    });
  });

  group('100 Fragen', () {
    testWidgets('counts answered questions and rotates, swapping is free', (tester) async {
      await tester.pumpWidget(harness(HundredQuestionsScreen(players: testPlayers(3))));
      await tester.pump();

      expect(find.text('FRAGE 1'), findsOneWidget);
      expect(find.text('SPIELER1, AN DICH'), findsOneWidget);

      await tapText(tester, 'Andere Frage');
      expect(find.text('FRAGE 1'), findsOneWidget, reason: 'swapping a card must not count as answered');

      await tapText(tester, 'Beantwortet — weiter an Spieler2');
      expect(find.text('FRAGE 2'), findsOneWidget);
      expect(find.text('SPIELER2, AN DICH'), findsOneWidget);
    });
  });
}
