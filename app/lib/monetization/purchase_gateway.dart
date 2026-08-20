import '../state/app_state.dart';

/// The seam where a real store purchase belongs.
///
/// ⚠️ The shipped implementation unlocks Pro locally without charging anyone.
/// That is fine for testing the gating end to end and it is **not** shippable:
/// before release this has to be swapped for `in_app_purchase` wired to a
/// product in the Play Console, with server-side receipt validation. Nothing
/// else in the app needs to change — the gating all keys off
/// [AppState.isPremium].
abstract class PurchaseGateway {
  /// Returns true when the user now owns Pro.
  Future<bool> buyLifetime();

  Future<bool> buyMonthly();

  /// Re-grants a purchase made on another device or before a reinstall.
  Future<bool> restore();
}

/// Local stand-in: flips the flag, no money changes hands.
class LocalUnlockGateway implements PurchaseGateway {
  const LocalUnlockGateway(this.state);

  final AppState state;

  @override
  Future<bool> buyLifetime() async {
    state.unlockPremium();
    return true;
  }

  @override
  Future<bool> buyMonthly() async {
    state.unlockPremium();
    return true;
  }

  @override
  Future<bool> restore() async {
    // With no store behind it there is nothing to restore; a real gateway
    // queries past purchases here.
    return state.isPremium;
  }
}
