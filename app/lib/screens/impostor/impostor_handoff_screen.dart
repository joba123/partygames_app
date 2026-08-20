import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/impostor_session.dart';
import '../../widgets/pass_phone.dart';

/// Screen 04 — Impostor's handoff. The layout is shared with the other
/// hidden-role games via [PassPhoneView].
class ImpostorHandoffScreen extends StatelessWidget {
  const ImpostorHandoffScreen({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ImpostorSession>();
    return PassPhoneView(
      player: session.currentDistributionPlayer,
      index: session.distributionIndex,
      total: session.players.length,
      onConfirm: onConfirm,
    );
  }
}
