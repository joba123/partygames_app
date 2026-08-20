import '../state/app_state.dart';

/// When the app is allowed to interrupt.
///
/// Both prompts are paced by finished rounds, never by wall-clock time: a
/// group that plays for three hours should be asked exactly as often as one
/// that plays for twenty minutes and the same number of rounds. Nothing ever
/// appears mid-round — the phone is being passed around and an interstitial
/// between two players' cards would leak the round or lose the phone.
class PromoPolicy {
  PromoPolicy._();

  /// No promo at all until the group has actually played. The first
  /// impression is the product, not the upsell.
  static const roundsBeforeFirstAd = 2;

  /// Two full rounds in between. With a typical round of five minutes that is
  /// roughly one promo per quarter hour, and never twice in a row.
  static const roundsBetweenAds = 3;

  static const roundsBeforeRatingAsk = 5;

  /// A "not now" buys this many rounds of silence.
  static const ratingSnoozeRounds = 10;

  static bool shouldShowHousePromo(AppState state) {
    if (state.isPremium) return false;
    if (state.roundsFinished < roundsBeforeFirstAd) return false;
    return state.roundsFinished - state.roundsAtLastAd >= roundsBetweenAds;
  }

  static bool shouldAskForRating(AppState state) {
    // 2 = rated or declined for good.
    if (state.ratingState == 2) return false;
    if (state.ratingState == 0) return state.roundsFinished >= roundsBeforeRatingAsk;
    return state.roundsFinished - state.roundsAtRatingAsk >= ratingSnoozeRounds;
  }

  /// What to do when the group lands back on the hub. Only ever one thing:
  /// asking for a rating and pitching Pro in the same breath is how an app
  /// earns a one-star review.
  static Interruption nextInterruption(AppState state) {
    if (shouldAskForRating(state)) return Interruption.rating;
    if (shouldShowHousePromo(state)) return Interruption.housePromo;
    return Interruption.none;
  }
}

enum Interruption { none, rating, housePromo }
