/// Word pools for the two team word-race games. Both share the same round
/// engine, so both live in one file: Charade acts a term out, Tabu explains
/// it while dodging the five obvious words.
library;

class CharadeWord {
  const CharadeWord(this.term, this.hint);

  final String term;

  /// One line of staging help so nobody freezes on the spot.
  final String hint;
}

const charadeWords = <CharadeWord>[
  CharadeWord('Astronaut beim Frühstück', 'Schwerelos, aber hungrig.'),
  CharadeWord('Pinguin im Fitnessstudio', 'Kurze Arme, großes Ziel.'),
  CharadeWord('Zahnarzt', 'Alles dreht sich um den Mund.'),
  CharadeWord('Regenschirm im Sturm', 'Du verlierst diesen Kampf.'),
  CharadeWord('Selfie mit schlechtem Licht', 'Winkel, Winkel, Winkel.'),
  CharadeWord('Fahrstuhl mit Fremden', 'Bloß niemanden ansehen.'),
  CharadeWord('Kaffeemaschine', 'Erst brummen, dann tropfen.'),
  CharadeWord('Erstes Date', 'Nervös, aber locker wirken.'),
  CharadeWord('Möbel aufbauen', 'Anleitung? Brauchst du nicht.'),
  CharadeWord('Katze weckt Herrchen', 'Fünf Uhr morgens.'),
  CharadeWord('Bewerbungsgespräch', 'Wo sehen Sie sich in fünf Jahren?'),
  CharadeWord('Handy fällt ins Klo', 'Der Moment danach.'),
  CharadeWord('Achterbahn', 'Erst rauf, dann Geschrei.'),
  CharadeWord('Kellner mit vollen Tellern', 'Balance ist alles.'),
  CharadeWord('Yoga-Anfänger', 'Der Körper macht nicht mit.'),
  CharadeWord('Verspäteter Zug', 'Anzeigetafel starren.'),
  CharadeWord('Hund an der Leine', 'Wer führt hier wen?'),
  CharadeWord('Karaoke ohne Textsicherheit', 'Ab dem zweiten Vers Improvisation.'),
  CharadeWord('Supermarktkasse', 'Piep. Piep. Karte oder bar?'),
  CharadeWord('Umzug im dritten Stock', 'Kein Aufzug.'),
  CharadeWord('Schlafender Sitznachbar', 'Die Schulter ist nicht deine.'),
  CharadeWord('Torwart beim Elfmeter', 'Eine Richtung, alles oder nichts.'),
  CharadeWord('Bügeln', 'Langweilig, aber heiß.'),
  CharadeWord('Sonnenbrand', 'Jede Berührung tut weh.'),
  CharadeWord('Schnappschuss mit Blitz', 'Alle blinzeln.'),
  CharadeWord('Kind im Süßigkeitenregal', 'Verhandeln bis zum Schluss.'),
  CharadeWord('Fahrradkette springt ab', 'Öl an den Fingern.'),
  CharadeWord('Klavierunterricht', 'Metronom im Nacken.'),
  CharadeWord('Chef betritt den Raum', 'Alle Fenster schließen.'),
  CharadeWord('Nachbar bohrt sonntags', 'Der Wutpegel steigt.'),
  CharadeWord('Airport-Sicherheitskontrolle', 'Gürtel, Laptop, Schuhe.'),
  CharadeWord('Winterreifenwechsel', 'Schrauben in der Kälte.'),
  CharadeWord('Pantomime spielt Pantomime', 'Ja, das geht.'),
  CharadeWord('Verliebter Teenager', 'Handy alle zehn Sekunden.'),
  CharadeWord('Kaugummi am Schuh', 'Jeder Schritt klebt.'),
  CharadeWord('Ikea am Samstag', 'Der Pfeil zeigt immer weiter.'),
];

class TabooWord {
  const TabooWord(this.term, this.forbidden);

  final String term;

  /// The words the explainer may not say. Five, per the classic rules.
  final List<String> forbidden;
}

const tabooWords = <TabooWord>[
  TabooWord('Strand', ['Meer', 'Sand', 'Urlaub', 'Sonne', 'Handtuch']),
  TabooWord('Kaffee', ['Koffein', 'Tasse', 'morgens', 'schwarz', 'wach']),
  TabooWord('Fahrrad', ['Pedale', 'fahren', 'Rad', 'Kette', 'Sattel']),
  TabooWord('Geburtstag', ['Kuchen', 'Kerzen', 'Geschenk', 'feiern', 'Jahr']),
  TabooWord('Winter', ['Schnee', 'kalt', 'Weihnachten', 'Jahreszeit', 'Ski']),
  TabooWord('Handy', ['Telefon', 'Display', 'App', 'anrufen', 'Akku']),
  TabooWord('Pizza', ['Italien', 'Käse', 'Teig', 'Ofen', 'Belag']),
  TabooWord('Regenbogen', ['Farben', 'Regen', 'Sonne', 'Himmel', 'bunt']),
  TabooWord('Bibliothek', ['Bücher', 'leise', 'lesen', 'ausleihen', 'Regal']),
  TabooWord('Fußball', ['Tor', 'Ball', 'Mannschaft', 'Spiel', 'Schiedsrichter']),
  TabooWord('Zahnbürste', ['Zähne', 'putzen', 'Bad', 'Paste', 'Mund']),
  TabooWord('Flughafen', ['Flugzeug', 'fliegen', 'Koffer', 'Terminal', 'Ticket']),
  TabooWord('Katze', ['miauen', 'Tier', 'Haustier', 'Maus', 'schnurren']),
  TabooWord('Kino', ['Film', 'Popcorn', 'Leinwand', 'Kasse', 'dunkel']),
  TabooWord('Regenschirm', ['Regen', 'nass', 'aufspannen', 'Schirm', 'Wetter']),
  TabooWord('Supermarkt', ['einkaufen', 'Kasse', 'Wagen', 'Lebensmittel', 'Regal']),
  TabooWord('Gitarre', ['Saiten', 'Musik', 'spielen', 'Band', 'Instrument']),
  TabooWord('Hochzeit', ['heiraten', 'Ringe', 'Kleid', 'Braut', 'Ja-Wort']),
  TabooWord('Schnee', ['weiß', 'kalt', 'Winter', 'fallen', 'Flocke']),
  TabooWord('Feuerwehr', ['Feuer', 'löschen', 'Wasser', 'rot', 'Sirene']),
  TabooWord('Podcast', ['hören', 'Folge', 'reden', 'Mikrofon', 'Serie']),
  TabooWord('Kühlschrank', ['kalt', 'Küche', 'Lebensmittel', 'Tür', 'Strom']),
  TabooWord('Marathon', ['laufen', 'Kilometer', 'Rennen', 'Ziel', 'Sport']),
  TabooWord('Passwort', ['Login', 'geheim', 'Konto', 'eingeben', 'vergessen']),
  TabooWord('Krankenhaus', ['Arzt', 'krank', 'Bett', 'Schwester', 'Notaufnahme']),
  TabooWord('Weihnachtsmarkt', ['Glühwein', 'Dezember', 'Buden', 'Weihnachten', 'kalt']),
  TabooWord('Sonnenbrille', ['Sonne', 'Augen', 'Nase', 'dunkel', 'Gläser']),
  TabooWord('Aufzug', ['Etage', 'fahren', 'Knopf', 'Haus', 'Treppe']),
  TabooWord('Tattoo', ['Nadel', 'Haut', 'Farbe', 'stechen', 'Motiv']),
  TabooWord('Regisseur', ['Film', 'Kamera', 'Schauspieler', 'drehen', 'Szene']),
  TabooWord('Waschmaschine', ['Wäsche', 'waschen', 'Trommel', 'Wasser', 'Programm']),
  TabooWord('Schatzsuche', ['Karte', 'Gold', 'graben', 'Piraten', 'finden']),
];
