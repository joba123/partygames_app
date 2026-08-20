import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/content.dart';
import '../data/games.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';

export '../data/content.dart' show ContentFilter, Spice;

enum DesignMode { dark, light, auto }

enum ContentCategory { harmlos, flirty, fuerMutige, alkoholfrei }

/// Top-level app state: shared player roster, theme/content settings, Pro
/// status and the counters that drive the ad and rating prompts.
///
/// Everything here is persisted. The player setup screen promises "Namen
/// bleiben für alle Spiele gespeichert" — before this it only held until the
/// app was killed.
class AppState extends ChangeNotifier {
  /// Positional because Dart forbids private field formals on named
  /// parameters; tests inject a mocked instance, production lets [load] fetch
  /// the real one.
  AppState([this._prefs]);

  SharedPreferences? _prefs;

  static const _kPlayers = 'players';
  static const _kDesignMode = 'designMode';
  static const _kVibration = 'vibration';
  static const _kSound = 'sound';
  static const _kPremium = 'premium';
  static const _kCategories = 'categories';
  static const _kLastPlayed = 'lastPlayed';
  static const _kRoundsFinished = 'roundsFinished';
  static const _kRoundsAtLastAd = 'roundsAtLastAd';
  static const _kRatingState = 'ratingState';
  static const _kRoundsAtRatingAsk = 'roundsAtRatingAsk';

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

  /// Drives the Hub's hero card.
  GameId lastPlayed = GameId.impostor;

  /// How many rounds have been played to the end. Drives both prompts.
  int roundsFinished = 0;
  int roundsAtLastAd = 0;

  /// 0 = not asked yet, 1 = asked and snoozed, 2 = done or refused for good.
  int ratingState = 0;
  int roundsAtRatingAsk = 0;

  final Map<ContentCategory, bool> contentCategories = {
    ContentCategory.harmlos: true,
    ContentCategory.flirty: true,
    ContentCategory.fuerMutige: false,
    ContentCategory.alkoholfrei: false,
  };

  /// Set by the pre-game category picker; overrides the global settings for
  /// exactly one round so a single spicy game does not rewrite the defaults.
  Map<ContentCategory, bool>? _roundCategories;

  Map<ContentCategory, bool> get activeCategories => _roundCategories ?? contentCategories;

  bool get hasRoundOverride => _roundCategories != null;

  // ---------------------------------------------------------------- loading

  Future<void> load() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();

    final storedPlayers = prefs.getStringList(_kPlayers);
    if (storedPlayers != null && storedPlayers.isNotEmpty) {
      players
        ..clear()
        ..addAll(storedPlayers.asMap().entries.map((e) => Player(id: 'p${e.key}', name: e.value)));
    }

    designMode = DesignMode.values[(prefs.getInt(_kDesignMode) ?? 0).clamp(0, DesignMode.values.length - 1)];
    vibration = prefs.getBool(_kVibration) ?? true;
    sound = prefs.getBool(_kSound) ?? false;
    isPremium = prefs.getBool(_kPremium) ?? false;
    roundsFinished = prefs.getInt(_kRoundsFinished) ?? 0;
    roundsAtLastAd = prefs.getInt(_kRoundsAtLastAd) ?? 0;
    ratingState = prefs.getInt(_kRatingState) ?? 0;
    roundsAtRatingAsk = prefs.getInt(_kRoundsAtRatingAsk) ?? 0;

    final storedLast = prefs.getInt(_kLastPlayed);
    if (storedLast != null && storedLast >= 0 && storedLast < GameId.values.length) {
      lastPlayed = GameId.values[storedLast];
    }

    final storedCategories = prefs.getStringList(_kCategories);
    if (storedCategories != null) {
      for (final category in ContentCategory.values) {
        contentCategories[category] = storedCategories.contains(category.name);
      }
    }

    notifyListeners();
  }

  void _save() {
    final prefs = _prefs;
    if (prefs == null) return;
    prefs.setStringList(_kPlayers, players.map((p) => p.name).toList());
    prefs.setInt(_kDesignMode, designMode.index);
    prefs.setBool(_kVibration, vibration);
    prefs.setBool(_kSound, sound);
    prefs.setBool(_kPremium, isPremium);
    prefs.setInt(_kLastPlayed, lastPlayed.index);
    prefs.setInt(_kRoundsFinished, roundsFinished);
    prefs.setInt(_kRoundsAtLastAd, roundsAtLastAd);
    prefs.setInt(_kRatingState, ratingState);
    prefs.setInt(_kRoundsAtRatingAsk, roundsAtRatingAsk);
    prefs.setStringList(
      _kCategories,
      [
        for (final entry in contentCategories.entries)
          if (entry.value) entry.key.name,
      ],
    );
  }

  // ------------------------------------------------------------- content

  /// The card filter the settings screen describes. "Für Mutige" is the one
  /// category Pro unlocks — without it the toggle is visible but inert, which
  /// is exactly what the paywall is supposed to communicate.
  ContentFilter get contentFilter {
    final active = activeCategories;
    return ContentFilter(
      spices: {
        if (active[ContentCategory.harmlos] ?? false) Spice.harmlos,
        if (active[ContentCategory.flirty] ?? false) Spice.flirty,
        if ((active[ContentCategory.fuerMutige] ?? false) && isPremium) Spice.fuerMutige,
      },
      noAlcohol: active[ContentCategory.alkoholfrei] ?? false,
      premium: isPremium,
    );
  }

  /// True when the category is behind the Pro upgrade.
  bool isCategoryLocked(ContentCategory category) =>
      category == ContentCategory.fuerMutige && !isPremium;

  void setRoundCategories(Map<ContentCategory, bool> categories) {
    _roundCategories = Map.of(categories);
    notifyListeners();
  }

  void clearRoundCategories() {
    if (_roundCategories == null) return;
    _roundCategories = null;
    notifyListeners();
  }

  // -------------------------------------------------------------- settings

  ThemeMode get themeMode => switch (designMode) {
        DesignMode.dark => ThemeMode.dark,
        DesignMode.light => ThemeMode.light,
        DesignMode.auto => ThemeMode.system,
      };

  void setDesignMode(DesignMode mode) {
    designMode = mode;
    _save();
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
    _save();
    notifyListeners();
  }

  void removePlayer(String id) {
    players.removeWhere((p) => p.id == id);
    _save();
    notifyListeners();
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final player = players.removeAt(oldIndex);
    players.insert(newIndex, player);
    _save();
    notifyListeners();
  }

  void shufflePlayers() {
    players.shuffle();
    _save();
    notifyListeners();
  }

  void toggleContentCategory(ContentCategory category) {
    contentCategories[category] = !(contentCategories[category] ?? false);
    _save();
    notifyListeners();
  }

  void toggleVibration() {
    vibration = !vibration;
    _save();
    notifyListeners();
  }

  void toggleSound() {
    sound = !sound;
    _save();
    notifyListeners();
  }

  void markPlayed(GameId id) {
    if (lastPlayed == id) return;
    lastPlayed = id;
    _save();
    notifyListeners();
  }

  /// Called when a round reaches its podium. Everything the app asks of the
  /// user — the Pro nudge, the rating prompt — is paced by this counter, not
  /// by wall-clock time, so a long evening is never interrupted twice.
  void markRoundFinished() {
    roundsFinished += 1;
    _save();
    notifyListeners();
  }

  void unlockPremium() {
    isPremium = true;
    _save();
    notifyListeners();
  }

  void setRatingState(int state) {
    ratingState = state;
    roundsAtRatingAsk = roundsFinished;
    _save();
    notifyListeners();
  }

  void markAdShown() {
    roundsAtLastAd = roundsFinished;
    _save();
    notifyListeners();
  }
}
