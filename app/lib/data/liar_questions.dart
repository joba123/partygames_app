/// Finde den Lügner: everyone answers the same question — except one player,
/// who gets the decoy. The pair has to be close enough that a decoy answer
/// still sounds plausible, and different enough that it stands out once the
/// real question is on the table.
class LiarQuestion {
  const LiarQuestion(this.real, this.decoy);

  /// What the group was asked.
  final String real;

  /// What the liar was asked instead — usually the same subject, inverted.
  final String decoy;
}

const liarQuestions = <LiarQuestion>[
  LiarQuestion('Was ist dein Lieblingsessen?', 'Welches Essen könntest du nie wieder anrühren?'),
  LiarQuestion('Wohin würdest du sofort in den Urlaub fliegen?', 'Wo würdest du niemals Urlaub machen?'),
  LiarQuestion('Welche App nutzt du am meisten?', 'Welche App hast du zuletzt gelöscht?'),
  LiarQuestion('Was war dein erster Job?', 'Welchen Job würdest du niemals machen?'),
  LiarQuestion('Welches Tier wärst du gern?', 'Vor welchem Tier hast du echten Respekt?'),
  LiarQuestion('Was machst du als Erstes nach dem Aufstehen?', 'Was machst du als Letztes vor dem Schlafen?'),
  LiarQuestion('Welche Serie hast du zuletzt zu Ende geschaut?', 'Welche Serie hast du mittendrin abgebrochen?'),
  LiarQuestion('Was liegt auf deinem Nachttisch?', 'Was liegt in deiner Jackentasche?'),
  LiarQuestion('Welches Schulfach lag dir am besten?', 'In welchem Schulfach warst du eine Katastrophe?'),
  LiarQuestion('Was würdest du mit 1000 Euro sofort machen?', 'Wofür hast du zuletzt zu viel Geld ausgegeben?'),
  LiarQuestion('Welchen Superhelden findest du am coolsten?', 'Welchen Superhelden findest du überbewertet?'),
  LiarQuestion('Was trinkst du auf einer Party am liebsten?', 'Was trinkst du auf einer Party garantiert nicht?'),
  LiarQuestion('Welche deutsche Stadt magst du am liebsten?', 'In welche deutsche Stadt würdest du nie ziehen?'),
  LiarQuestion('Was kannst du richtig gut kochen?', 'Was hast du beim Kochen schon mal ruiniert?'),
  LiarQuestion('Was würdest du studieren, wenn du neu anfangen könntest?', 'Welches Studium würdest du niemandem empfehlen?'),
  LiarQuestion('Welcher Song läuft bei dir gerade in Dauerschleife?', 'Welchen Song kannst du nicht mehr hören?'),
  LiarQuestion('Was ist deine liebste Jahreszeit?', 'Welche Jahreszeit nervt dich am meisten?'),
  LiarQuestion('Welches Spiel hast du als Kind geliebt?', 'Welches Spiel hast du nie verstanden?'),
  LiarQuestion('Was nimmst du auf jede Reise mit?', 'Was vergisst du beim Packen jedes Mal?'),
  LiarQuestion('Welche Farbe trägst du am häufigsten?', 'Welche Farbe steht dir überhaupt nicht?'),
  LiarQuestion('Was ist dein liebstes Frühstück?', 'Was würdest du morgens nie anrühren?'),
  LiarQuestion('Welchen Film schaust du immer wieder?', 'Bei welchem Film bist du eingeschlafen?'),
  LiarQuestion('Welches Talent hättest du gern?', 'Welches Talent findest du völlig nutzlos?'),
  LiarQuestion('Was ist dein Lieblingsplatz in deiner Wohnung?', 'Welchen Raum in deiner Wohnung meidest du?'),
];
