import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player.dart';
import '../../state/impostor_session.dart';
import 'impostor_handoff_screen.dart';
import 'impostor_reveal_screen.dart';
import 'impostor_clue_round_screen.dart';
import 'impostor_voting_screen.dart';
import 'impostor_resolution_screen.dart';

enum ImpostorPhase { handoff, reveal, clueRound, voting, resolution }

/// Owns the [ImpostorSession] for one Impostor game and swaps between the
/// five phase screens (04–09) — a single flat state machine instead of a
/// nested Navigator, so the shared session never falls out of scope.
class ImpostorFlowScreen extends StatefulWidget {
  const ImpostorFlowScreen({super.key, required this.players});

  final List<Player> players;

  @override
  State<ImpostorFlowScreen> createState() => _ImpostorFlowScreenState();
}

class _ImpostorFlowScreenState extends State<ImpostorFlowScreen> {
  late final ImpostorSession session = ImpostorSession(widget.players);
  ImpostorPhase phase = ImpostorPhase.handoff;

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  void _afterReveal() {
    session.advanceDistribution();
    setState(() => phase = session.distributionComplete ? ImpostorPhase.clueRound : ImpostorPhase.handoff);
  }

  void _toVoting() => setState(() => phase = ImpostorPhase.voting);

  void _toResolution() => setState(() => phase = ImpostorPhase.resolution);

  void _nextRound() {
    session.startNewRound();
    setState(() => phase = ImpostorPhase.handoff);
  }

  void _exitFlow() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: session,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (phase) {
          ImpostorPhase.handoff => ImpostorHandoffScreen(key: const ValueKey('handoff'), onConfirm: () => setState(() => phase = ImpostorPhase.reveal)),
          ImpostorPhase.reveal => ImpostorRevealScreen(key: const ValueKey('reveal'), onContinue: _afterReveal, onExit: _exitFlow),
          ImpostorPhase.clueRound => ImpostorClueRoundScreen(key: const ValueKey('clue'), onAllCluesDone: _toVoting),
          ImpostorPhase.voting => ImpostorVotingScreen(key: const ValueKey('voting'), onResolved: _toResolution),
          ImpostorPhase.resolution => ImpostorResolutionScreen(key: const ValueKey('resolution'), onNextRound: _nextRound, onEnd: _exitFlow),
        },
      ),
    );
  }
}
