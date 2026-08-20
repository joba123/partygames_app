import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/deck.dart';

void main() {
  test('deals every card before repeating one', () {
    final deck = Deck<int>(List.generate(8, (i) => i), random: Random(1));
    final firstPass = List.generate(8, (_) => deck.draw());

    expect(firstPass.toSet().length, 8, reason: 'a card came up twice inside one pass');
  });

  test('reshuffles instead of running dry', () {
    final deck = Deck<int>([1, 2, 3], random: Random(1));
    final drawn = List.generate(12, (_) => deck.draw());

    expect(drawn.whereType<int>().length, 12);
  });

  test('an empty pool draws null instead of throwing', () {
    final deck = Deck<int>(const []);

    expect(deck.draw(), isNull);
    expect(deck.isEmpty, isTrue);
  });
}
