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
}

/// What kind of screen a game opens once players are set up — only
/// Impostor gets its full bespoke flow; the rest reuse the two generic
/// components from the handoff (Timer, Prompt-card) as playable demos.
enum GamePlayKind { impostor, timerDemo, promptDemo }

class GameInfo {
  const GameInfo({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.description,
    required this.meta,
    required this.playKind,
    this.badge,
  });

  final GameId id;
  final String title;
  final GameCategory category;
  final GameIconType icon;
  final String description;
  final String meta;
  final GamePlayKind playKind;
  final String? badge;
}

const games = <GameInfo>[
  GameInfo(
    id: GameId.impostor,
    title: 'Impostor',
    category: GameCategory.klassiker,
    icon: GameIconType.impostor,
    description: 'Einer kennt das Wort nicht. Finde ihn.',
    meta: '3–12 SPIELER · 10 MIN',
    playKind: GamePlayKind.impostor,
    badge: 'BELIEBT',
  ),
  GameInfo(
    id: GameId.wahrheitOderPflicht,
    title: 'Wahrheit oder Pflicht',
    category: GameCategory.klassiker,
    icon: GameIconType.truthOrDare,
    description: 'Ehrlich antworten oder die Aufgabe wagen.',
    meta: '3–10 SPIELER · OFFEN',
    playKind: GamePlayKind.promptDemo,
  ),
  GameInfo(
    id: GameId.werWuerdeEher,
    title: 'Wer würde eher',
    category: GameCategory.klassiker,
    icon: GameIconType.wouldRather,
    description: 'Alle zeigen gleichzeitig auf jemanden.',
    meta: '3–12 SPIELER · SCHNELL',
    playKind: GamePlayKind.promptDemo,
  ),
  GameInfo(
    id: GameId.bombe,
    title: 'Bombe',
    category: GameCategory.schnell,
    icon: GameIconType.bomb,
    description: 'Handy weiterreichen, bevor der Timer abläuft.',
    meta: '3–12 SPIELER · 1 MIN',
    playKind: GamePlayKind.timerDemo,
  ),
  GameInfo(
    id: GameId.ichHabNochNie,
    title: 'Ich hab noch nie',
    category: GameCategory.neu,
    icon: GameIconType.neverHaveIEver,
    description: 'Wer es getan hat, trinkt.',
    meta: '3–12 SPIELER · OFFEN',
    playKind: GamePlayKind.promptDemo,
  ),
  GameInfo(
    id: GameId.trinkspielRoulette,
    title: 'Trinkspiel-Roulette',
    category: GameCategory.schnell,
    icon: GameIconType.bomb,
    description: 'Zufällige Regel, zufälliges Opfer.',
    meta: '3–12 SPIELER · SCHNELL',
    playKind: GamePlayKind.timerDemo,
  ),
  GameInfo(
    id: GameId.charade,
    title: 'Charade / Pantomime',
    category: GameCategory.redenUndRaten,
    icon: GameIconType.wouldRather,
    description: 'Vormachen statt sagen.',
    meta: '4–14 SPIELER · TEAMS',
    playKind: GamePlayKind.promptDemo,
  ),
  GameInfo(
    id: GameId.mostLikelyToDuell,
    title: 'Most Likely To Duell',
    category: GameCategory.klassiker,
    icon: GameIconType.wouldRather,
    description: 'Zwei treten an, die Gruppe entscheidet.',
    meta: '4–12 SPIELER · SCHNELL',
    playKind: GamePlayKind.promptDemo,
  ),
  GameInfo(
    id: GameId.quizBattle,
    title: 'Quiz-Battle',
    category: GameCategory.neu,
    icon: GameIconType.truthOrDare,
    description: 'Teams gegeneinander, Punkte zählen.',
    meta: '4–16 SPIELER · TEAMS',
    playKind: GamePlayKind.promptDemo,
  ),
  GameInfo(
    id: GameId.tabu,
    title: 'Tabu — Verbotene Wörter',
    category: GameCategory.redenUndRaten,
    icon: GameIconType.impostor,
    description: 'Erklären, ohne die verbotenen Wörter zu nennen.',
    meta: '4–14 SPIELER · TEAMS',
    playKind: GamePlayKind.timerDemo,
  ),
];
