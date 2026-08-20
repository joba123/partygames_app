import '../theme/app_colors.dart';
import '../widgets/game_icons.dart';

enum GameId {
  impostor,
  wahrheitOderPflicht,
  werWuerdeEher,
  bombe,
  ichHabNochNie,
  trinkspielRoulette,
  charade,
  mostLikelyToDuell,
  quizBattle,
  tabu,
  findeDenLuegner,
  fakeOderFakt,
  betBuddy,
}

/// Which screen a game opens once the roster is set. Every entry has a real
/// implementation — several games share an engine where they genuinely share
/// a loop (Charade/Tabu race a team against the clock, Wer-würde-eher and
/// das Duell both let the group point at a player).
enum GamePlayKind {
  impostor,
  truthOrDare,
  neverHaveIEver,
  pointVote,
  duel,
  bomb,
  roulette,
  charade,
  taboo,
  quiz,
  liar,
  fakeFact,
  bet,
}

class GameInfo {
  const GameInfo({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.description,
    required this.meta,
    required this.playKind,
    required this.minPlayers,
    this.needsTeams = false,
    this.badge,
  });

  final GameId id;
  final String title;
  final GameCategory category;
  final GameIconType icon;
  final String description;
  final String meta;
  final GamePlayKind playKind;

  /// Hard floor — the setup screen will not let the round start below this.
  final int minPlayers;

  /// Splits the roster into two teams before the first round.
  final bool needsTeams;

  final String? badge;
}

const games = <GameInfo>[
  GameInfo(
    id: GameId.impostor,
    title: 'Impostor',
    category: GameCategory.klassiker,
    icon: GameIconType.impostor,
    description: 'Einer kennt das Wort nicht.',
    meta: '3–12 SPIELER · 10 MIN',
    playKind: GamePlayKind.impostor,
    minPlayers: 3,
    badge: 'BELIEBT',
  ),
  GameInfo(
    id: GameId.wahrheitOderPflicht,
    title: 'Wahrheit oder Pflicht',
    category: GameCategory.klassiker,
    icon: GameIconType.truthOrDare,
    description: 'Antworten oder wagen.',
    meta: '3–12 SPIELER · OFFEN',
    playKind: GamePlayKind.truthOrDare,
    minPlayers: 3,
  ),
  GameInfo(
    id: GameId.werWuerdeEher,
    title: 'Wer würde eher',
    category: GameCategory.klassiker,
    icon: GameIconType.wouldRather,
    description: 'Alle zeigen auf einen.',
    meta: '3–12 SPIELER · SCHNELL',
    playKind: GamePlayKind.pointVote,
    minPlayers: 3,
  ),
  GameInfo(
    id: GameId.bombe,
    title: 'Bombe',
    category: GameCategory.schnell,
    icon: GameIconType.bomb,
    description: 'Weitergeben, bevor es knallt.',
    meta: '3–12 SPIELER · 1 MIN',
    playKind: GamePlayKind.bomb,
    minPlayers: 3,
  ),
  GameInfo(
    id: GameId.ichHabNochNie,
    title: 'Ich hab noch nie',
    category: GameCategory.neu,
    icon: GameIconType.neverHaveIEver,
    description: 'Wer es getan hat, gibt es zu.',
    meta: '3–12 SPIELER · OFFEN',
    playKind: GamePlayKind.neverHaveIEver,
    minPlayers: 3,
  ),
  GameInfo(
    id: GameId.trinkspielRoulette,
    title: 'Trinkspiel-Roulette',
    category: GameCategory.schnell,
    icon: GameIconType.roulette,
    description: 'Rad dreht, jemand zahlt.',
    meta: '3–12 SPIELER · SCHNELL',
    playKind: GamePlayKind.roulette,
    minPlayers: 3,
  ),
  GameInfo(
    id: GameId.charade,
    title: 'Charade',
    category: GameCategory.redenUndRaten,
    icon: GameIconType.charade,
    description: 'Vormachen statt sagen.',
    meta: '4–14 SPIELER · TEAMS',
    playKind: GamePlayKind.charade,
    minPlayers: 4,
    needsTeams: true,
  ),
  GameInfo(
    id: GameId.mostLikelyToDuell,
    title: 'Duell',
    category: GameCategory.klassiker,
    icon: GameIconType.duel,
    description: 'Zwei treten an, alle richten.',
    meta: '4–12 SPIELER · SCHNELL',
    playKind: GamePlayKind.duel,
    minPlayers: 4,
  ),
  GameInfo(
    id: GameId.quizBattle,
    title: 'Quiz-Battle',
    category: GameCategory.neu,
    icon: GameIconType.quiz,
    description: 'Team gegen Team, Punkte zählen.',
    meta: '4–16 SPIELER · TEAMS',
    playKind: GamePlayKind.quiz,
    minPlayers: 4,
    needsTeams: true,
  ),
  GameInfo(
    id: GameId.tabu,
    title: 'Tabu',
    category: GameCategory.redenUndRaten,
    icon: GameIconType.taboo,
    description: 'Erklären ohne die Reizwörter.',
    meta: '4–14 SPIELER · TEAMS',
    playKind: GamePlayKind.taboo,
    minPlayers: 4,
    needsTeams: true,
  ),
  GameInfo(
    id: GameId.findeDenLuegner,
    title: 'Finde den Lügner',
    category: GameCategory.redenUndRaten,
    icon: GameIconType.liar,
    description: 'Einer beantwortet eine andere Frage.',
    meta: '3–12 SPIELER · 10 MIN',
    playKind: GamePlayKind.liar,
    minPlayers: 3,
    badge: 'NEU',
  ),
  GameInfo(
    id: GameId.fakeOderFakt,
    title: 'Fake oder Fakt',
    category: GameCategory.neu,
    icon: GameIconType.fakeFact,
    description: 'Einer erfindet seinen Fakt.',
    meta: '3–12 SPIELER · 10 MIN',
    playKind: GamePlayKind.fakeFact,
    minPlayers: 3,
  ),
  GameInfo(
    id: GameId.betBuddy,
    title: 'Bet Buddy',
    category: GameCategory.schnell,
    icon: GameIconType.bet,
    description: 'Hochbieten, bis einer liefern muss.',
    meta: '4–16 SPIELER · TEAMS',
    playKind: GamePlayKind.bet,
    minPlayers: 4,
    needsTeams: true,
  ),
];

GameInfo gameById(GameId id) => games.firstWhere((g) => g.id == id);
