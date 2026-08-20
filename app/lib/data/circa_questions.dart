/// Circa — jede Frage hat genau eine Zahl als Antwort. Alle tippen einen
/// Tipp ein, wer am nächsten dran ist, bekommt den Punkt. Deshalb sind hier
/// nur Zahlen, die feststehen und sich nicht mit dem Jahr ändern.
class CircaQuestion {
  const CircaQuestion(this.question, this.answer, this.unit);

  final String question;
  final int answer;

  /// Mono-Suffix hinter der Zahl, z. B. "JAHR" oder "KM".
  final String unit;
}

const circaQuestions = <CircaQuestion>[
  CircaQuestion('Wie viele Knochen hat ein erwachsener Mensch?', 206, 'Knochen'),
  CircaQuestion('Wie viele Länder sind in der Europäischen Union?', 27, 'Länder'),
  CircaQuestion('Wie viele Tasten hat ein Standard-Klavier?', 88, 'Tasten'),
  CircaQuestion('Wie viele Felder hat ein Schachbrett?', 64, 'Felder'),
  CircaQuestion('Wie viele Sekunden hat ein Tag?', 86400, 'Sekunden'),
  CircaQuestion('Wie viele Zähne hat ein Erwachsener mit Weisheitszähnen?', 32, 'Zähne'),
  CircaQuestion('Wie viele Zähne hat ein vollständiges Milchgebiss?', 20, 'Zähne'),
  CircaQuestion('Wie hoch ist der Mount Everest in Metern?', 8849, 'Meter'),
  CircaQuestion('Wie hoch ist der Eiffelturm mit Antenne in Metern?', 330, 'Meter'),
  CircaQuestion('Wie viele Streifen hat die Flagge der USA?', 13, 'Streifen'),
  CircaQuestion('Wie viele Karten hat ein Skatblatt?', 32, 'Karten'),
  CircaQuestion('Wie viele Karten hat ein französisches Blatt ohne Joker?', 52, 'Karten'),
  CircaQuestion('Wie viele Minuten hat eine Woche?', 10080, 'Minuten'),
  CircaQuestion('Wie viele Kilometer ist ein Marathon lang, aufgerundet?', 42, 'Kilometer'),
  CircaQuestion('Wie viele Saiten hat eine Geige?', 4, 'Saiten'),
  CircaQuestion('Wie viele Knochen stecken in einer menschlichen Hand?', 27, 'Knochen'),
  CircaQuestion('Wie viele Kammern hat ein menschliches Herz?', 4, 'Kammern'),
  CircaQuestion('Wie viele Spieltage hat eine Bundesliga-Saison?', 34, 'Spieltage'),
  CircaQuestion('Wie viele Weltwunder der Antike gab es?', 7, 'Weltwunder'),
  CircaQuestion('Wie weit ist der Mond im Schnitt entfernt, in tausend Kilometern?', 384, 'Tausend km'),
  CircaQuestion('In welchem Jahr landeten die ersten Menschen auf dem Mond?', 1969, 'Jahr'),
  CircaQuestion('In welchem Jahr fiel die Berliner Mauer?', 1989, 'Jahr'),
  CircaQuestion('In welchem Jahr endete der Zweite Weltkrieg?', 1945, 'Jahr'),
  CircaQuestion('Wie lang ist der Rhein in Kilometern?', 1233, 'Kilometer'),
  CircaQuestion('Wie viele Bundesstaaten hat die USA?', 50, 'Staaten'),
  CircaQuestion('Wie viele Spieler einer Basketballmannschaft stehen auf dem Feld?', 5, 'Spieler'),
  CircaQuestion('Bei wie viel Grad Celsius kocht Wasser auf Meereshöhe?', 100, 'Grad'),
  CircaQuestion('Wie viele Planeten hat unser Sonnensystem?', 8, 'Planeten'),
  CircaQuestion('Wie viele Buchstaben hat das lateinische Alphabet?', 26, 'Buchstaben'),
  CircaQuestion('Wie viele Bundesländer hat Deutschland?', 16, 'Länder'),
];
