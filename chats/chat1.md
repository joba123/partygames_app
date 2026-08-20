# Party Games App UI/UX

_Started 2026-08-19 20:25 UTC_

---

## User

Design a mobile app for Entwirf das UI/UX-Konzept für eine mobile App namens "[EIGENER NAME]" 
— eine Sammel-App für Party- und Gruppenspiele (Android/iOS, Flutter).

ORIENTIERUNG:
Als funktionale Referenz dient die App "Splash - Party Spiele" 
(Cranberry Apps). Orientiere dich an der GRUNDSTRUKTUR und dem 
NUTZUNGSFLUSS (Hub mit Spielauswahl → Spieler-Setup → Spielmodus). 
Übernimm KEINE Farbpalette, Logos, Icons, Typografie, Illustrationen 
oder sonstigen visuellen Markenelemente von Splash. Entwickle ein 
komplett eigenständiges visuelles Konzept (Farbschema, Typografie, 
Icon-Stil, Illustrationsstil).

ZIELGRUPPE & STIMMUNG:
Junge Erwachsene (16–30), Partyszene / gesellige Runden. Die App wird 
meist herumgereicht (ein Handy für die ganze Gruppe) — also verspielt, 
energiegeladen, sozial. Design-Sprache: modern, bunt, aber aufgeräumt; 
Material 3 als Basis.

ZU GESTALTENDE SCREENS:
1. Splashscreen/App-Icon (eigenständiges Branding)
2. Hub-/Startbildschirm — Übersicht aller Spielmodi als Karten/Kacheln, 
   mit Kategorie-Filter (z.B. "Klassiker", "Neu", "Für Mutige")
3. Spieler-Setup-Screen — Namen/Anzahl eingeben, gemeinsames Modul 
   für alle Spiele
4. Impostor-Spiel: Rollenverteilungs-Screen (Karte "aufdecken"), 
   Hinweisrunde-Screen, Abstimmungs-Screen, Auflösungs-Screen
5. Generischer Timer-Komponenten-Screen (wiederverwendbar)
6. Generischer "Frage/Aufgabe anzeigen"-Screen (für Wahrheit oder 
   Pflicht, Wer würde eher, etc.)
7. Einstellungen/Kategorie-Auswahl-Screen
8. Premium/Upsell-Screen (dezent, nicht aufdringlich)

ANFORDERUNGEN AN DIE AUSGABE:
- Design-System: Farbpalette (Primär-, Sekundär-, Akzentfarben), 
  Typografie-Skala, Abstände/Grid, Button- und Card-Styles
- Große, gut erreichbare Touch-Ziele (Handy wird oft im Kreis 
  herumgereicht, auch unter schlechten Lichtbedingungen z.B. abends)
- Dark Mode von Anfang an mitdenken (Partys finden oft abends/nachts statt)
- Konsistente Icon-Sprache für die verschiedenen Spielmodi
- Übergaben/Transitions zwischen Spielern klar visuell kennzeichnen 
  (z.B. "Gib das Handy weiter an [Name]"-Screen)
- Liefere Ergebnisse als Figma-Datei / Screens + kurze Style-Guide-
  Dokumentation, die der Entwicklung als Grundlage für die Umsetzung 
  in Flutter dient

Beginne mit dem Design-System (Farben, Typografie, Komponenten) und 
anschließend mit dem Hub-Screen sowie dem kompletten Flow für das 
Impostor-Spiel als ersten vollständigen Screen-Satz.

## Assistant



## Assistant

_[tool: ask_user]_

Warte auf die Antworten — vor allem Name, Optik-Richtung und Spielmodi. Danach starte ich mit Design-System, Hub und dem kompletten Impostor-Flow.

## User

Answered — app_name: Imposter - Offline Partyspiele; ui_language: Deutsch; vibe_axis: Warm & weich: Pastell-Akzente, runde Formen, Retro-Arcade: Grid, Pixel-/Mono-Details; games: Impostor, Wahrheit oder Pflicht, Wer würde eher, Ich hab noch nie, Bombe (Timer), Trinkspiel-Roulette, Charade / Pantomime, Most Likely To Duell, Quiz-Battle, Tabu-Verbotene Wörter; copy_tone: Frech & laut; deliverable: Screen-Katalog aller 8 Screens nebeneinander

## Assistant

_[tool: dc_write]_

## Assistant

_[tool: dc_write]_

_[tool: ready_for_verification]_

Screen-Katalog liegt vor: Design-System (Palette dark+light, Typo-Skala, Spacing, Buttons, Icon-System, Kategorie-Farbcode), 13 Screens à 390×844 — Splash, Hub (dark + light), Spieler-Setup, kompletter Impostor-Flow (Übergabe → Karte verdeckt → Rolle → Hinweisrunde → Abstimmung → Auflösung), Timer- und Frage-Komponente, Einstellungen, Plus-Upsell — plus Flutter-Handoff mit ColorScheme-Mapping, Widget-Liste und Motion-Werten.

Figma kann ich nicht erzeugen; die Werte sind aber direkt aus dem Katalog ablesbar. Nächster sinnvoller Schritt: den Impostor-Flow als klickbaren Prototyp, oder Karten-Screens für die übrigen 6 Spiele.

