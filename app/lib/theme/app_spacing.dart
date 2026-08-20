/// Spacing / radius scale — base 4, straight from the handoff's
/// "Abstände, Radien, Grid" card.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  static const screenPadding = 20.0;
  static const cardGap = 12.0;
  static const sectionGap = 32.0;

  /// No touch target under this.
  static const minTouchTarget = 48.0;
  /// Primary in-game actions.
  static const primaryActionHeight = 64.0;
}

class AppRadius {
  AppRadius._();

  static const chip = 999.0;
  static const card = 24.0;
  static const sheet = 32.0;
  static const button = 20.0;
}
