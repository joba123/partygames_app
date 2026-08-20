import 'package:flutter/material.dart';
import '../data/content.dart';
import '../data/games.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';

enum DesignMode { dark, light, auto }

enum ContentCategory { harmlos, flirty, fuerMutige, alkoholfrei }

/// Top-level app state: shared player roster, theme/content settings and
/// premium status. Survives navigation between games (as the handoff
/// describes: "Namen bleiben für alle Spiele gespeichert").
class AppState extends ChangeNotifier {
  final List<Player> players = [
    Player(id: 'p1', name: 'Lena'),
    Player(id: 'p2', name: 'Jonas'),
    Player(id: 'p3', name: 'Mira'),
    Player(id: 'p4', name: 'Tobi'),
  ];

  DesignMode designMode = DesignMode.dark;
  bool vibration = true;
  bool sound = false;
  bool isPremium = false;

  GameCategory? hubFilter;

  /// Drives the Hub's hero card. Starts on Impostor so a fresh install still
  /// has something featured.
  GameId lastPlayed = GameId.impostor;

  final Map<ContentCategory, bool> contentCategories = {
    ContentCategory.harmlos: true,
    ContentCategory.flirty: true,
    ContentCategory.fuerMutige: false,
    ContentCategory.alkoholfrei: false,
  };

  /// The card filter the settings screen actually describes: the three spice
  /// toggles decide what may appear, "Alkoholfrei" removes drinking cards,
  /// and Plus unlocks the premium pool.
  ContentFilter get contentFilter => ContentFilter(
        spices: {
          if (contentCategories[ContentCategory.harmlos] ?? false) Spice.harmlos,
          if (contentCategories[ContentCategory.flirty] ?? false) Spice.flirty,
          if (contentCategories[ContentCategory.fuerMutige] ?? false) Spice.fuerMutige,
        },
        noAlcohol: contentCategories[ContentCategory.alkoholfrei] ?? false,
        premium: isPremium,
      );

  void markPlayed(GameId id) {
    if (lastPlayed == id) return;
    lastPlayed = id;
    notifyListeners();
  }

  ThemeMode get themeMode => switch (designMode) {
        DesignMode.dark => ThemeMode.dark,
        DesignMode.light => ThemeMode.light,
        DesignMode.auto => ThemeMode.system,
      };

  void setDesignMode(DesignMode mode) {
    designMode = mode;
    notifyListeners();
  }

  void setHubFilter(GameCategory? category) {
    hubFilter = category;
    notifyListeners();
  }

  void addPlayer(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    players.add(Player(id: DateTime.now().microsecondsSinceEpoch.toString(), name: trimmed));
    notifyListeners();
  }

  void removePlayer(String id) {
    players.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final player = players.removeAt(oldIndex);
    players.insert(newIndex, player);
    notifyListeners();
  }

  void shufflePlayers() {
    players.shuffle();
    notifyListeners();
  }

  void toggleContentCategory(ContentCategory category) {
    contentCategories[category] = !(contentCategories[category] ?? false);
    notifyListeners();
  }

  void toggleVibration() {
    vibration = !vibration;
    notifyListeners();
  }

  void toggleSound() {
    sound = !sound;
    notifyListeners();
  }

  void unlockPremium() {
    isPremium = true;
    notifyListeners();
  }
}
