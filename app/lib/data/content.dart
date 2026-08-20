/// Content model shared by every prompt-driven game.
///
/// The settings screen splits content three ways plus one hard filter:
/// Harmlos / Flirty / Für Mutige decide *which* cards may show up,
/// "Alkoholfrei" removes every card that tells someone to drink. Both are
/// applied here so no game screen has to re-implement the rules.
library;

enum Spice { harmlos, flirty, fuerMutige }

extension SpiceLabel on Spice {
  String get label => switch (this) {
        Spice.harmlos => 'Harmlos',
        Spice.flirty => 'Flirty',
        Spice.fuerMutige => 'Für Mutige',
      };
}

class Prompt {
  const Prompt(this.text, {this.spice = Spice.harmlos, this.alcohol = false, this.premium = false});

  final String text;
  final Spice spice;

  /// Card asks someone to drink — hidden while "Alkoholfrei" is on.
  final bool alcohol;

  /// Part of the Plus pack.
  final bool premium;
}

/// Which cards the current settings allow.
class ContentFilter {
  const ContentFilter({required this.spices, required this.noAlcohol, required this.premium});

  final Set<Spice> spices;
  final bool noAlcohol;
  final bool premium;

  /// Everything on, used by tests and by games that carry no spicy content.
  static const all = ContentFilter(spices: {Spice.harmlos, Spice.flirty, Spice.fuerMutige}, noAlcohol: false, premium: true);

  bool allows(Prompt p) {
    if (!spices.contains(p.spice)) return false;
    if (noAlcohol && p.alcohol) return false;
    if (p.premium && !premium) return false;
    return true;
  }

  /// Filtered pool. Never returns empty: if the settings filter everything
  /// away, harmless non-alcohol cards come back as the floor, so a game can
  /// always deal a card instead of dead-ending on a blank screen.
  List<Prompt> apply(List<Prompt> pool) {
    final kept = pool.where(allows).toList();
    if (kept.isNotEmpty) return kept;
    final floor = pool.where((p) => p.spice == Spice.harmlos && !p.alcohol && !p.premium).toList();
    return floor.isNotEmpty ? floor : pool;
  }
}
