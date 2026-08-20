import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/models/werewolf_round.dart';

import 'harness.dart';

WerewolfRound roundOf(int players) => WerewolfRound(testPlayers(players), random: Random(7));

void main() {
  group('Rollenverteilung', () {
    test('scales the pack with the village', () {
      expect(WerewolfRound.wolfCount(5), 1);
      expect(WerewolfRound.wolfCount(6), 1);
      expect(WerewolfRound.wolfCount(7), 2);
      expect(WerewolfRound.wolfCount(11), 2);
      expect(WerewolfRound.wolfCount(12), 3);
    });

    test('deals exactly one role per player', () {
      for (final count in [5, 6, 8, 12, 16]) {
        final round = roundOf(count);
        expect(round.roles, hasLength(count), reason: '$count players');
        expect(round.roles.where((r) => r == WolfRole.werwolf), hasLength(WerewolfRound.wolfCount(count)));
        expect(round.roles.where((r) => r == WolfRole.seher), hasLength(1));
      }
    });

    test('the witch only joins once the village can absorb her', () {
      expect(roundOf(5).roles.contains(WolfRole.hexe), isFalse);
      expect(roundOf(6).roles.contains(WolfRole.hexe), isTrue);
    });
  });

  group('Nachtauflösung', () {
    test('the wolves kill the player they picked', () {
      final round = roundOf(6);
      final victim = round.aliveVillagers.first;

      round.wolfVictim = victim;
      round.resolveNight();

      expect(round.alive[victim], isFalse);
      expect(round.lastDeaths, [victim]);
    });

    test('the heal cancels the kill', () {
      final round = roundOf(6);
      final victim = round.aliveVillagers.first;

      round.wolfVictim = victim;
      round.healed = true;
      round.resolveNight();

      expect(round.alive[victim], isTrue);
      expect(round.lastDeaths, isEmpty);
    });

    test('the poison lands even when the heal is used', () {
      final round = roundOf(8);
      final victim = round.aliveVillagers[0];
      final poisoned = round.aliveVillagers[1];

      round.wolfVictim = victim;
      round.healed = true;
      round.poisoned = poisoned;
      round.resolveNight();

      expect(round.alive[victim], isTrue);
      expect(round.alive[poisoned], isFalse);
    });

    test('choices do not carry over into the next night', () {
      final round = roundOf(6);
      round.wolfVictim = round.aliveVillagers.first;
      round.healed = true;
      round.resolveNight();

      expect(round.wolfVictim, isNull);
      expect(round.poisoned, isNull);
      expect(round.healed, isFalse);
    });
  });

  group('Siegbedingungen', () {
    test('the game runs on while both sides have numbers', () {
      expect(roundOf(8).outcome, isNull);
    });

    test('the village wins once the last wolf is gone', () {
      final round = roundOf(6);
      for (final wolf in round.aliveWolves) {
        round.lynch(wolf);
      }

      expect(round.outcome, WerewolfOutcome.village);
    });

    test('the wolves win once they match the rest', () {
      final round = roundOf(6);
      // Kill villagers until one wolf faces one villager.
      while (round.aliveVillagers.length > round.aliveWolves.length) {
        round.lynch(round.aliveVillagers.first);
      }

      expect(round.outcome, WerewolfOutcome.wolves);
    });

    test('a seer that dies is no longer woken', () {
      final round = roundOf(6);
      final seer = round.seerIndex!;
      round.lynch(seer);

      expect(round.seerIndex, isNull);
    });
  });
}
