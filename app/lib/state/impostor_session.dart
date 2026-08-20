import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';

const _wordPool = [
  'Sauna', 'Lagerfeuer', 'U-Bahn', 'Zahnarzt', 'Flughafen', 'Karneval',
  'Schwimmbad', 'Zeltlager', 'Weihnachten', 'Baustelle', 'Aquarium',
  'Achterbahn', 'Bibliothek', 'Yoga-Kurs', 'Junggesellenabschied',
  'Flohmarkt', 'Skiurlaub', 'Feuerwerk', 'Grillparty', 'Umzug',
];

/// One Impostor round: who's the impostor, the word, and progress through
/// handoff → reveal → clue rounds → voting → resolution.
class ImpostorSession extends ChangeNotifier {
  ImpostorSession(List<Player> players) : _players = List.of(players) {
    _startRound();
  }

  final List<Player> _players;
  List<Player> get players => List.unmodifiable(_players);

  final _random = Random();

  late int impostorIndex;
  late String word;

  /// Handoff/reveal progress: whose turn it is to see their role (0-based).
  int distributionIndex = 0;
  bool get distributionComplete => distributionIndex >= _players.length;

  static const clueRoundsTotal = 2;
  int clueRoundNumber = 1;
  int clueTurnIndex = 0;
  late List<bool> _clueDoneThisRound;

  static const clueTurnSeconds = 20;
  int secondsLeft = clueTurnSeconds;
  Timer? _turnTimer;
  bool timerPaused = false;

  /// Fired once the second clue round finishes — hook for the screen to
  /// navigate on to voting without polling [clueRoundComplete] in build().
  VoidCallback? onAllCluesDone;

  List<int> voteCounts = [];
  int voterIndex = 0;
  bool get votingComplete => voterIndex >= _players.length;

  int? accusedIndex;
  String? impostorGuess;

  int groupScore = 0;
  int impostorScore = 0;

  Player get impostor => _players[impostorIndex];
  Player get currentDistributionPlayer => _players[distributionIndex];
  Player get currentCluePlayer => _players[clueTurnIndex];
  bool isImpostor(int playerIndex) => playerIndex == impostorIndex;

  void _startRound() {
    impostorIndex = _random.nextInt(_players.length);
    word = (List.of(_wordPool)..shuffle(_random)).first;
    distributionIndex = 0;
    clueRoundNumber = 1;
    clueTurnIndex = 0;
    _clueDoneThisRound = List.filled(_players.length, false);
    voteCounts = List.filled(_players.length, 0);
    voterIndex = 0;
    accusedIndex = null;
    impostorGuess = null;
    secondsLeft = clueTurnSeconds;
    timerPaused = false;
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  void startNewRound() {
    _startRound();
    notifyListeners();
  }

  void advanceDistribution() {
    distributionIndex += 1;
    notifyListeners();
  }

  bool get isCurrentClueTurnDone => _clueDoneThisRound[clueTurnIndex];
  bool isClueDoneAt(int playerIndex) => _clueDoneThisRound[playerIndex];

  void startClueTimer() {
    _turnTimer?.cancel();
    timerPaused = false;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timerPaused) return;
      if (secondsLeft > 0) {
        secondsLeft -= 1;
        notifyListeners();
      } else {
        markCurrentClueDone();
      }
    });
  }

  void togglePauseClueTimer() {
    timerPaused = !timerPaused;
    notifyListeners();
  }

  void markCurrentClueDone() {
    if (_clueDoneThisRound[clueTurnIndex]) return;
    _clueDoneThisRound[clueTurnIndex] = true;
    if (clueTurnIndex < _players.length - 1) {
      clueTurnIndex += 1;
      secondsLeft = clueTurnSeconds;
    } else if (clueRoundNumber < clueRoundsTotal) {
      clueRoundNumber += 1;
      clueTurnIndex = 0;
      secondsLeft = clueTurnSeconds;
      _clueDoneThisRound = List.filled(_players.length, false);
    } else {
      _turnTimer?.cancel();
      notifyListeners();
      onAllCluesDone?.call();
      return;
    }
    notifyListeners();
  }

  bool get clueRoundComplete =>
      clueRoundNumber == clueRoundsTotal && _clueDoneThisRound.every((d) => d);

  void castVote(int targetIndex) {
    voteCounts[targetIndex] += 1;
    voterIndex += 1;
    notifyListeners();
  }

  int get leadingCandidateIndex {
    var best = 0;
    for (var i = 1; i < voteCounts.length; i++) {
      if (voteCounts[i] > voteCounts[best]) best = i;
    }
    return best;
  }

  bool resolve({String? guess}) {
    accusedIndex = leadingCandidateIndex;
    impostorGuess = guess;
    final caught = accusedIndex == impostorIndex;
    if (caught) {
      groupScore += 2;
    } else {
      impostorScore += 2;
    }
    notifyListeners();
    return caught;
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }
}
