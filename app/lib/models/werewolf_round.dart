import 'dart:math';
import 'player.dart';

enum WolfRole { werwolf, seher, hexe, dorfbewohner }

extension WolfRoleLabel on WolfRole {
  String get label => switch (this) {
        WolfRole.werwolf => 'Werwolf',
        WolfRole.seher => 'Seherin',
        WolfRole.hexe => 'Hexe',
        WolfRole.dorfbewohner => 'Dorfbewohner',
      };

  String get blurb => switch (this) {
        WolfRole.werwolf => 'Nachts wählst du mit den anderen Wölfen ein Opfer. Tagsüber tust du ahnungslos.',
        WolfRole.seher => 'Jede Nacht darfst du die Rolle einer Person erfahren — verrate dich nicht zu früh.',
        WolfRole.hexe => 'Du hast einen Heiltrank und einen Gifttrank. Jeden genau einmal, das ganze Spiel.',
        WolfRole.dorfbewohner => 'Du hast keine Sonderfähigkeit. Nur Augen, Ohren und ein Misstrauen.',
      };
}

enum WerewolfOutcome { village, wolves }

/// The rules of one Werwölfe game, separated from the screen so the win
/// conditions and the night resolution can be tested without pumping widgets.
class WerewolfRound {
  WerewolfRound(List<Player> players, {Random? random})
      : players = List.of(players),
        alive = List.filled(players.length, true),
        _random = random ?? Random() {
    roles = _dealRoles();
  }

  final List<Player> players;
  final List<bool> alive;
  final Random _random;

  late List<WolfRole> roles;

  int night = 1;
  bool healUsed = false;
  bool poisonUsed = false;

  /// Set during the wolves' turn, consumed when the night resolves.
  int? wolfVictim;
  int? poisoned;
  bool healed = false;

  List<int> lastDeaths = [];

  /// One wolf in a small round, two in a mid-size one, three from twelve up —
  /// the village needs a majority large enough to survive a lynch mistake.
  static int wolfCount(int playerCount) =>
      playerCount <= 6 ? 1 : (playerCount <= 11 ? 2 : 3);

  /// The witch only makes the round better once there are enough villagers to
  /// absorb her mistakes.
  bool get hasWitch => players.length >= 6;

  List<WolfRole> _dealRoles() {
    final deck = <WolfRole>[
      ...List.filled(wolfCount(players.length), WolfRole.werwolf),
      WolfRole.seher,
      if (hasWitch) WolfRole.hexe,
    ];
    while (deck.length < players.length) {
      deck.add(WolfRole.dorfbewohner);
    }
    return deck..shuffle(_random);
  }

  List<int> get aliveIndices =>
      [for (var i = 0; i < players.length; i++) if (alive[i]) i];

  List<int> get aliveWolves =>
      aliveIndices.where((i) => roles[i] == WolfRole.werwolf).toList();

  List<int> get aliveVillagers =>
      aliveIndices.where((i) => roles[i] != WolfRole.werwolf).toList();

  int? _aliveHolderOf(WolfRole role) {
    for (final i in aliveIndices) {
      if (roles[i] == role) return i;
    }
    return null;
  }

  int? get seerIndex => _aliveHolderOf(WolfRole.seher);

  int? get witchIndex => _aliveHolderOf(WolfRole.hexe);

  /// Turns the night's choices into deaths. The heal cancels the wolves'
  /// victim; the poison always lands.
  void resolveNight() {
    final deaths = <int>{};
    if (wolfVictim != null && !healed) deaths.add(wolfVictim!);
    if (poisoned != null) deaths.add(poisoned!);

    for (final i in deaths) {
      alive[i] = false;
    }
    lastDeaths = deaths.toList()..sort();

    wolfVictim = null;
    poisoned = null;
    healed = false;
  }

  void lynch(int index) {
    alive[index] = false;
  }

  void nextNight() {
    night += 1;
  }

  /// Null while the game is still running.
  WerewolfOutcome? get outcome {
    if (aliveWolves.isEmpty) return WerewolfOutcome.village;
    // Once the wolves match the rest, no vote can save the village.
    if (aliveWolves.length >= aliveVillagers.length) return WerewolfOutcome.wolves;
    return null;
  }
}
