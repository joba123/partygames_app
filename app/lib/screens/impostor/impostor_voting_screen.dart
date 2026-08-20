import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/impostor_session.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/vote_row.dart';

/// Screen 08 — votes shown as dots, not a bar chart nobody can read in
/// the dark. Leading suspect gets a 2px danger outline.
class ImpostorVotingScreen extends StatelessWidget {
  const ImpostorVotingScreen({super.key, required this.onResolved});

  final VoidCallback onResolved;

  Future<String?> _askGuess(BuildContext context, String impostorName) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('$impostorName, was war das Wort?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Dein Tipp'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Bestätigen')),
        ],
      ),
    );
  }

  Future<void> _handleResolve(BuildContext context, ImpostorSession session) async {
    String? guess;
    if (session.leadingCandidateIndex == session.impostorIndex) {
      guess = await _askGuess(context, session.impostor.name);
    }
    session.resolve(guess: guess);
    onResolved();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final session = context.watch<ImpostorSession>();
    final leading = session.leadingCandidateIndex;
    final allVoted = session.votingComplete;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ABSTIMMUNG', style: AppText.labelMono(p.danger, size: 11).copyWith(letterSpacing: 11 * 0.14)),
                  const SizedBox(height: 8),
                  Text('Wer ist der Impostor?', style: AppText.headline(p.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Zählt laut ab drei — dann tippt die Gruppe gemeinsam.', style: AppText.bodySmall(p.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                itemCount: session.players.length,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) => VoteRow(
                  name: session.players[i].name,
                  colorIndex: i,
                  voteCount: session.voteCounts[i],
                  isLeading: i == leading,
                  onTap: allVoted ? null : () => session.castVote(i),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 30),
              child: Column(
                children: [
                  Text('${session.voterIndex} VON ${session.players.length} STIMMEN ABGEGEBEN',
                      textAlign: TextAlign.center, style: AppText.labelMono(p.textMuted, size: 11)),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Auflösen',
                    size: AppButtonSize.large,
                    color: p.danger,
                    onColor: p.onDanger,
                    onPressed: allVoted ? () => _handleResolve(context, session) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
