/// Quiz-Battle question pool. Four options, one correct — kept to facts that
/// do not age or depend on a source, so a wrong answer is never the app's
/// fault.
class QuizQuestion {
  const QuizQuestion(this.question, this.options, this.correctIndex);

  final String question;
  final List<String> options;
  final int correctIndex;

  String get correctAnswer => options[correctIndex];
}

const quizQuestions = <QuizQuestion>[
  QuizQuestion('In welchem Jahr fiel die Berliner Mauer?', ['1987', '1989', '1991', '1993'], 1),
  QuizQuestion('Wie viele Bundesländer hat Deutschland?', ['14', '15', '16', '17'], 2),
  QuizQuestion('Was ist die Hauptstadt Australiens?', ['Sydney', 'Melbourne', 'Canberra', 'Perth'], 2),
  QuizQuestion('Welches chemische Symbol steht für Gold?', ['Go', 'Au', 'Ag', 'Gd'], 1),
  QuizQuestion('Welcher Planet ist der Sonne am nächsten?', ['Venus', 'Mars', 'Merkur', 'Erde'], 2),
  QuizQuestion('Wer schrieb "Faust"?', ['Schiller', 'Goethe', 'Lessing', 'Heine'], 1),
  QuizQuestion('Wie viele Saiten hat eine klassische Gitarre?', ['4', '5', '6', '7'], 2),
  QuizQuestion('Wie heißt die Währung Japans?', ['Won', 'Yen', 'Yuan', 'Rupie'], 1),
  QuizQuestion('Welcher ist der größte Ozean der Erde?', ['Atlantik', 'Indischer Ozean', 'Pazifik', 'Arktischer Ozean'], 2),
  QuizQuestion('Was ist die Hauptstadt der Schweiz?', ['Zürich', 'Genf', 'Basel', 'Bern'], 3),
  QuizQuestion('Wie viele Beine hat eine Spinne?', ['6', '8', '10', '12'], 1),
  QuizQuestion('Welches Element hat das Symbol O?', ['Osmium', 'Gold', 'Sauerstoff', 'Ozon'], 2),
  QuizQuestion('Wer betrat 1969 als erster Mensch den Mond?', ['Juri Gagarin', 'Buzz Aldrin', 'Neil Armstrong', 'Michael Collins'], 2),
  QuizQuestion('Wie viele Tasten hat ein Standard-Klavier?', ['76', '80', '88', '96'], 2),
  QuizQuestion('Wie heißt der höchste Berg der Erde?', ['K2', 'Mount Everest', 'Kangchendzönga', 'Lhotse'], 1),
  QuizQuestion('Wie viele Herzen hat ein Oktopus?', ['1', '2', '3', '4'], 2),
  QuizQuestion('Wie viele Sekunden hat eine Stunde?', ['360', '600', '1800', '3600'], 3),
  QuizQuestion('Welches Landtier ist das schnellste?', ['Gepard', 'Antilope', 'Löwe', 'Pferd'], 0),
  QuizQuestion('Welche Farbe ergibt Blau gemischt mit Gelb?', ['Lila', 'Grün', 'Orange', 'Braun'], 1),
  QuizQuestion('Wie viele Zähne hat ein Erwachsener mit Weisheitszähnen?', ['28', '30', '32', '34'], 2),
  QuizQuestion('Welcher Planet ist der größte im Sonnensystem?', ['Saturn', 'Neptun', 'Jupiter', 'Uranus'], 2),
  QuizQuestion('Wie viele Ringe zeigt das olympische Symbol?', ['4', '5', '6', '7'], 1),
  QuizQuestion('Was ist die Hauptstadt Kanadas?', ['Toronto', 'Vancouver', 'Montreal', 'Ottawa'], 3),
  QuizQuestion('Wie viele Bundesstaaten hat die USA?', ['48', '50', '52', '54'], 1),
  QuizQuestion('Wer malte die Mona Lisa?', ['Michelangelo', 'Raffael', 'Leonardo da Vinci', 'Donatello'], 2),
  QuizQuestion('Wie viele Buchstaben hat das lateinische Alphabet?', ['24', '25', '26', '27'], 2),
  QuizQuestion('Welches Gas nehmen Pflanzen bei der Fotosynthese auf?', ['Sauerstoff', 'Stickstoff', 'Kohlendioxid', 'Wasserstoff'], 2),
  QuizQuestion('Welches Land hat die größte Fläche der Erde?', ['China', 'Kanada', 'USA', 'Russland'], 3),
  QuizQuestion('Wie viele Spielfiguren hat eine Seite beim Schach?', ['12', '14', '16', '18'], 2),
  QuizQuestion('Wie viele Spieler einer Volleyball-Mannschaft stehen auf dem Feld?', ['5', '6', '7', '8'], 1),
];
