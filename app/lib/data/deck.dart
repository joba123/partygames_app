import 'dart:math';

/// A shuffled bag. Cards come out in random order but none repeats until the
/// whole pool has been dealt — a plain `random.nextInt` would hand the same
/// card out twice within five rounds often enough to be noticed.
class Deck<T> {
  Deck(List<T> items, {Random? random})
      : _items = List.of(items),
        _random = random ?? Random() {
    _refill();
  }

  final List<T> _items;
  final Random _random;
  final List<T> _remaining = [];

  bool get isEmpty => _items.isEmpty;

  /// How many cards are left before the bag reshuffles.
  int get remaining => _remaining.length;

  int get size => _items.length;

  void _refill() {
    _remaining
      ..clear()
      ..addAll(_items)
      ..shuffle(_random);
  }

  /// Next card, or null for an empty pool.
  T? draw() {
    if (_items.isEmpty) return null;
    if (_remaining.isEmpty) _refill();
    return _remaining.removeLast();
  }
}
