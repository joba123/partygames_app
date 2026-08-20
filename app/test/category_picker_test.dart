import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/card_counts.dart';
import 'package:imposter_party/data/games.dart';
import 'package:imposter_party/screens/premium_screen.dart';
import 'package:imposter_party/screens/shared/category_picker_screen.dart';
import 'package:imposter_party/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'harness.dart';

Future<AppState> loadedState() async {
  useFakePreferences();
  final state = AppState(await SharedPreferences.getInstance());
  await state.load();
  return state;
}

void main() {
  setUp(() {
    useFakePreferences();
    // The default 800x600 test viewport cuts off the card counter below the
    // category list, and a ListView does not build what it does not show.
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = const Size(390 * 3, 1000 * 3);
    view.devicePixelRatio = 3;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  test('only games with a rated deck offer the picker', () {
    for (final game in games) {
      expect(
        game.picksCategories,
        poolForGame(game.id).isNotEmpty,
        reason: '${game.title} advertises a category step it cannot use',
      );
    }
  });

  test('every picker game has cards in more than one spice level', () {
    for (final game in games.where((g) => g.picksCategories)) {
      final spices = poolForGame(game.id).map((c) => c.spice).toSet();
      expect(spices.length, greaterThan(1), reason: '${game.title} would show a pointless choice');
    }
  });

  testWidgets('the pick applies to the round without rewriting the defaults', (tester) async {
    final state = await loadedState();
    final game = gameById(GameId.wahrheitOderPflicht);

    await tester.pumpWidget(harness(
      CategoryPickerScreen(game: game, stepLabel: 'Schritt 2 von 2', onStart: () => const _Started()),
      state: state,
    ));
    await tester.pump();

    expect(state.contentCategories[ContentCategory.flirty], isTrue);

    await tester.tap(find.text('Flirty'));
    await tester.pump();
    await tester.tap(find.text('Runde starten'));
    await settleRoute(tester);

    expect(find.byType(_Started), findsOneWidget);
    expect(state.activeCategories[ContentCategory.flirty], isFalse, reason: 'the round runs without flirty');
    expect(state.contentCategories[ContentCategory.flirty], isTrue, reason: 'the default must be untouched');
    expect(state.contentFilter.spices.contains(Spice.flirty), isFalse);
  });

  testWidgets('the card count follows the selection', (tester) async {
    final state = await loadedState();
    final game = gameById(GameId.wahrheitOderPflicht);

    await tester.pumpWidget(harness(
      CategoryPickerScreen(game: game, stepLabel: 'Schritt 2 von 2', onStart: () => const _Started()),
      state: state,
    ));
    await tester.pump();

    // The picker's selection is local until "Runde starten", so the expected
    // numbers are built here rather than read back off the state.
    final pool = poolForGame(game.id);
    const both = ContentFilter(spices: {Spice.harmlos, Spice.flirty}, noAlcohol: false, premium: false);
    const harmlessOnly = ContentFilter(spices: {Spice.harmlos}, noAlcohol: false, premium: false);

    final withFlirty = pool.where(both.allows).length;
    final withoutFlirty = pool.where(harmlessOnly.allows).length;
    expect(withoutFlirty, lessThan(withFlirty), reason: 'the pool needs flirty cards for this to mean anything');

    expect(find.text('$withFlirty'), findsOneWidget);

    await tester.tap(find.text('Flirty'));
    await tester.pump();

    expect(find.text('$withoutFlirty'), findsOneWidget);
  });

  testWidgets('Für Mutige is a paywall, not a toggle, without Pro', (tester) async {
    final state = await loadedState();

    await tester.pumpWidget(harness(
      CategoryPickerScreen(
        game: gameById(GameId.ichHabNochNie),
        stepLabel: 'Schritt 2 von 2',
        onStart: () => const _Started(),
      ),
      state: state,
    ));
    await tester.pump();

    expect(find.text('Mit Pro freischalten'), findsOneWidget);

    await tester.tap(find.text('Für Mutige'));
    await tester.pumpAndSettle();

    expect(find.byType(PremiumScreen), findsOneWidget, reason: 'the locked row should sell, not toggle');
    expect(state.activeCategories[ContentCategory.fuerMutige] ?? false, isFalse);
  });

  testWidgets('with Pro it toggles like any other category', (tester) async {
    final state = await loadedState();
    state.unlockPremium();

    await tester.pumpWidget(harness(
      CategoryPickerScreen(
        game: gameById(GameId.ichHabNochNie),
        stepLabel: 'Schritt 2 von 2',
        onStart: () => const _Started(),
      ),
      state: state,
    ));
    await tester.pump();

    expect(find.text('18+, kann eskalieren'), findsOneWidget);

    await tester.tap(find.text('Für Mutige'));
    await tester.pump();
    await tester.tap(find.text('Runde starten'));
    await settleRoute(tester);

    expect(state.contentFilter.spices.contains(Spice.fuerMutige), isTrue);
  });

  testWidgets('deselecting everything still deals a playable deck', (tester) async {
    final state = await loadedState();
    final game = gameById(GameId.hundertFragen);

    await tester.pumpWidget(harness(
      CategoryPickerScreen(game: game, stepLabel: 'Schritt 2 von 2', onStart: () => const _Started()),
      state: state,
    ));
    await tester.pump();

    await tester.tap(find.text('Harmlos'));
    await tester.pump();
    await tester.tap(find.text('Flirty'));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.textContaining('läuft dann mit den harmlosen Karten'), findsOneWidget);

    await tester.tap(find.text('Runde starten'));
    await settleRoute(tester);

    expect(state.contentFilter.apply(poolForGame(game.id)), isNotEmpty);
  });
}

/// Stand-in for the game screen the picker hands over to.
class _Started extends StatelessWidget {
  const _Started();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
