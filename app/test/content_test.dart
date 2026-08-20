import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/card_counts.dart';
import 'package:imposter_party/data/content.dart';
import 'package:imposter_party/data/prompts_truth_dare.dart';
import 'package:imposter_party/state/app_state.dart';

const _pool = [
  Prompt('harmlos'),
  Prompt('trinken', alcohol: true),
  Prompt('flirty', spice: Spice.flirty),
  Prompt('mutig', spice: Spice.fuerMutige),
  Prompt('plus', premium: true),
];

void main() {
  test('spice toggles decide which cards are dealt', () {
    const filter = ContentFilter(spices: {Spice.harmlos}, noAlcohol: false, premium: false);

    expect(filter.apply(_pool).map((p) => p.text), ['harmlos', 'trinken']);
  });

  test('alkoholfrei removes drinking cards', () {
    const filter = ContentFilter(spices: {Spice.harmlos}, noAlcohol: true, premium: false);

    expect(filter.apply(_pool).map((p) => p.text), ['harmlos']);
  });

  test('premium cards stay locked without plus', () {
    const locked = ContentFilter(spices: {Spice.harmlos}, noAlcohol: false, premium: false);
    const unlocked = ContentFilter(spices: {Spice.harmlos}, noAlcohol: false, premium: true);

    expect(locked.apply(_pool).any((p) => p.premium), isFalse);
    expect(unlocked.apply(_pool).any((p) => p.premium), isTrue);
  });

  test('a filter that excludes everything still yields a playable card', () {
    const filter = ContentFilter(spices: {}, noAlcohol: true, premium: false);

    expect(filter.apply(_pool), isNotEmpty);
  });

  test('every shipped prompt survives the default settings', () {
    final filter = AppState().contentFilter;

    expect(filter.apply(truthPrompts), isNotEmpty);
    expect(filter.apply(darePrompts), isNotEmpty);
  });

  test('card counts are real numbers, and plus adds to them', () {
    final state = AppState();
    final free = activeCardCount(state.contentFilter);
    final locked = lockedPremiumCardCount(state.contentFilter);

    expect(free, greaterThan(0));
    expect(locked, greaterThan(0));

    state.unlockPremium();
    expect(activeCardCount(state.contentFilter), free + locked);
    expect(lockedPremiumCardCount(state.contentFilter), 0);
  });
}
