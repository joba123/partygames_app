import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/data/games.dart';
import 'package:imposter_party/monetization/promo_policy.dart';
import 'package:imposter_party/monetization/purchase_gateway.dart';
import 'package:imposter_party/screens/loading_screen.dart';
import 'package:imposter_party/screens/hub_screen.dart';
import 'package:imposter_party/state/app_state.dart';
import 'package:imposter_party/widgets/rate_app_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'harness.dart';

Future<AppState> loadedState([Map<String, Object> initial = const {}]) async {
  useFakePreferences(initial);
  final state = AppState(await SharedPreferences.getInstance());
  await state.load();
  return state;
}

void main() {
  setUp(useFakePreferences);

  group('Persistenz', () {
    test('roster, settings and Pro survive a restart', () async {
      final first = await loadedState();
      first.addPlayer('Yara');
      first.toggleContentCategory(ContentCategory.flirty);
      first.setDesignMode(DesignMode.light);
      first.unlockPremium();
      first.markPlayed(GameId.werwoelfe);

      final second = AppState(await SharedPreferences.getInstance());
      await second.load();

      expect(second.players.map((p) => p.name), contains('Yara'));
      expect(second.contentCategories[ContentCategory.flirty], isFalse);
      expect(second.designMode, DesignMode.light);
      expect(second.isPremium, isTrue);
      expect(second.lastPlayed, GameId.werwoelfe);
    });

    test('a fresh install starts on the documented defaults', () async {
      final state = await loadedState();

      expect(state.isPremium, isFalse);
      expect(state.roundsFinished, 0);
      expect(state.players, hasLength(4));
      expect(state.contentCategories[ContentCategory.harmlos], isTrue);
    });
  });

  group('Pro-Gating', () {
    test('Für Mutige stays inert until Pro is bought', () async {
      final state = await loadedState();
      state.contentCategories[ContentCategory.fuerMutige] = true;

      expect(state.isCategoryLocked(ContentCategory.fuerMutige), isTrue);
      expect(state.contentFilter.spices.contains(Spice.fuerMutige), isFalse);

      state.unlockPremium();

      expect(state.isCategoryLocked(ContentCategory.fuerMutige), isFalse);
      expect(state.contentFilter.spices.contains(Spice.fuerMutige), isTrue);
    });

    test('the other categories are never locked', () async {
      final state = await loadedState();

      for (final category in [ContentCategory.harmlos, ContentCategory.flirty, ContentCategory.alkoholfrei]) {
        expect(state.isCategoryLocked(category), isFalse, reason: '$category');
      }
    });

    test('the purchase seam grants and reports ownership', () async {
      final state = await loadedState();
      final gateway = LocalUnlockGateway(state);

      expect(await gateway.restore(), isFalse);
      expect(await gateway.buyLifetime(), isTrue);
      expect(state.isPremium, isTrue);
      expect(await gateway.restore(), isTrue);
    });
  });

  group('Taktung', () {
    test('nothing interrupts before the group has played', () async {
      final state = await loadedState();

      expect(PromoPolicy.nextInterruption(state), Interruption.none);

      state.markRoundFinished();
      expect(PromoPolicy.nextInterruption(state), Interruption.none);
    });

    test('the promo appears, then goes quiet for two rounds', () async {
      final state = await loadedState();
      // Settle the rating question first — it outranks the promo, and this
      // test is about the promo's own spacing.
      state.setRatingState(2);
      for (var i = 0; i < PromoPolicy.roundsBetweenAds; i++) {
        state.markRoundFinished();
      }

      expect(PromoPolicy.nextInterruption(state), Interruption.housePromo);

      state.markAdShown();
      expect(PromoPolicy.nextInterruption(state), Interruption.none);

      state.markRoundFinished();
      expect(PromoPolicy.nextInterruption(state), Interruption.none, reason: 'one round is not enough');

      state.markRoundFinished();
      state.markRoundFinished();
      expect(PromoPolicy.nextInterruption(state), Interruption.housePromo);
    });

    test('Pro never sees a promo, however long the evening runs', () async {
      final state = await loadedState();
      state.unlockPremium();
      for (var i = 0; i < 50; i++) {
        state.markRoundFinished();
      }

      expect(PromoPolicy.shouldShowHousePromo(state), isFalse);
    });

    test('the rating ask wins over the promo when both are due', () async {
      final state = await loadedState();
      for (var i = 0; i < PromoPolicy.roundsBeforeRatingAsk; i++) {
        state.markRoundFinished();
      }

      expect(PromoPolicy.shouldShowHousePromo(state), isTrue);
      expect(PromoPolicy.nextInterruption(state), Interruption.rating);
    });

    test('"Später" buys ten rounds of silence, "Nicht fragen" is final', () async {
      final state = await loadedState();
      for (var i = 0; i < PromoPolicy.roundsBeforeRatingAsk; i++) {
        state.markRoundFinished();
      }

      state.setRatingState(1);
      expect(PromoPolicy.shouldAskForRating(state), isFalse);

      for (var i = 0; i < PromoPolicy.ratingSnoozeRounds; i++) {
        state.markRoundFinished();
      }
      expect(PromoPolicy.shouldAskForRating(state), isTrue);

      state.setRatingState(2);
      for (var i = 0; i < 100; i++) {
        state.markRoundFinished();
      }
      expect(PromoPolicy.shouldAskForRating(state), isFalse);
    });
  });

  group('Bewertungs-Aufforderung', () {
    testWidgets('rating opens the store and never asks again', (tester) async {
      final state = await loadedState();
      Uri? opened;

      await tester.pumpWidget(harness(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => RateAppSheet.present(context, onOpenStore: (uri) async {
                  opened = uri;
                  return true;
                }),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        state: state,
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Läuft es gut?'), findsOneWidget);

      await tester.tap(find.text('Klar, bewerten'));
      await tester.pumpAndSettle();

      expect(opened, storeListing);
      expect(state.ratingState, 2);
    });

    testWidgets('"Später" only snoozes', (tester) async {
      final state = await loadedState();

      await tester.pumpWidget(harness(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => RateAppSheet.present(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        state: state,
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Später'));
      await tester.pumpAndSettle();

      expect(state.ratingState, 1);
    });
  });

  group('Ladescreen', () {
    testWidgets('reads what was stored before handing over to the hub', (tester) async {
      useFakePreferences({'players': <String>['Ada', 'Grace', 'Linus']});

      await tester.pumpWidget(harness(const LoadingScreen(minimumDuration: Duration(milliseconds: 50))));
      await tester.pump();
      expect(find.text('Imposter'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(HubScreen), findsOneWidget);
      expect(find.text('3 SPIELER BEREIT'), findsOneWidget);
    });
  });
}
