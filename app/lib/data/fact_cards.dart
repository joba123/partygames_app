/// Fake oder Fakt: everyone memorises the same true fact, one player gets
/// only the topic and has to invent something that fits. Every entry below is
/// actually true — the resolution screen shows it again, so a wrong "fact"
/// would teach the group nonsense.
class FactCard {
  const FactCard(this.topic, this.fact);

  /// The only thing the faker sees. Broad enough to bluff with, narrow
  /// enough that a wild invention sticks out.
  final String topic;

  final String fact;
}

const factCards = <FactCard>[
  FactCard('Weltraum', 'Ein Tag auf der Venus dauert länger als ein Jahr auf der Venus.'),
  FactCard('Weltraum', 'Die Sonne macht über 99 Prozent der Masse des Sonnensystems aus.'),
  FactCard('Weltraum', 'Saturn hat eine so geringe Dichte, dass er in Wasser schwimmen würde.'),
  FactCard('Weltraum', 'Fußabdrücke auf dem Mond bleiben sehr lange erhalten, weil es dort keinen Wind gibt.'),
  FactCard('Tiere', 'Bei Seepferdchen trägt das Männchen die Jungen aus.'),
  FactCard('Tiere', 'Ein Kolibri kann rückwärts fliegen.'),
  FactCard('Tiere', 'Flamingos sind von Natur aus grau — ihre Farbe kommt aus dem Futter.'),
  FactCard('Tiere', 'Wombats hinterlassen würfelförmigen Kot.'),
  FactCard('Tiere', 'Kühe haben feste Freundinnen und werden gestresst, wenn man sie trennt.'),
  FactCard('Tiere', 'Eichhörnchen pflanzen unabsichtlich Bäume, weil sie ihre Verstecke vergessen.'),
  FactCard('Körper', 'Der kleinste Knochen im menschlichen Körper sitzt im Ohr und heißt Steigbügel.'),
  FactCard('Körper', 'Die Magenschleimhaut erneuert sich alle paar Tage komplett.'),
  FactCard('Körper', 'Menschen teilen etwa 60 Prozent ihrer Gene mit einer Banane.'),
  FactCard('Geschichte', 'Die Universität Oxford ist älter als das Aztekenreich.'),
  FactCard('Geschichte', 'Kleopatra lebte zeitlich näher an der Mondlandung als am Bau der Cheops-Pyramide.'),
  FactCard('Natur', 'Bananen sind botanisch Beeren, Erdbeeren nicht.'),
  FactCard('Natur', 'Honig verdirbt praktisch nicht.'),
  FactCard('Natur', 'Ein Blitz ist etwa fünfmal heißer als die Oberfläche der Sonne.'),
  FactCard('Natur', 'Auf der Erde gibt es mehr Bäume als Sterne in der Milchstraße.'),
  FactCard('Natur', 'Ananas wachsen nicht auf Bäumen, sondern dicht über dem Boden.'),
  FactCard('Natur', 'Die Sahara war vor einigen tausend Jahren grün.'),
  FactCard('Technik', 'Die erste Computermaus hatte ein Gehäuse aus Holz.'),
  FactCard('Technik', 'Das erste iPhone konnte keine Videos aufnehmen.'),
  FactCard('Geografie', 'Russland grenzt an 14 Länder.'),
  FactCard('Geografie', 'Der Pazifik ist größer als alle Landmassen der Erde zusammen.'),
  FactCard('Sprache', 'Das längste jemals amtlich verwendete deutsche Wort hatte 63 Buchstaben.'),
];
