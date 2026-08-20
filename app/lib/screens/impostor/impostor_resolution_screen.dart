import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/impostor_session.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';

/// Screen 09 — the only screen with a glow; the emotional peak. Two
/// variants: caught (danger) or escaped (secondary).
class ImpostorResolutionScreen extends StatelessWidget {
  const ImpostorResolutionScreen({super.key, required this.onNextRound, required this.onEnd});

  final VoidCallback onNextRound;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final session = context.watch<ImpostorSession>();
    final accusedIndex = session.accusedIndex ?? session.leadingCandidateIndex;
    final accused = session.players[accusedIndex];
    final caught = accusedIndex == session.impostorIndex;
    final accent = caught ? p.danger : p.secondary;
    final onAccent = caught ? p.onDanger : p.onSecondary;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.7),
            radius: 1.15,
            colors: [accent.withValues(alpha: .22), p.background],
            stops: const [0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Text(caught ? 'ERWISCHT' : 'ENTKOMMEN',
                          style: AppText.labelMono(accent, size: 12).copyWith(letterSpacing: 12 * 0.2)),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(color: accent, shape: BoxShape.circle, boxShadow: [
                          BoxShadow(color: accent.withValues(alpha: .28), blurRadius: 44, spreadRadius: 4),
                        ]),
                        alignment: Alignment.center,
                        child: Text(session.impostor.initial, style: AppText.display(onAccent).copyWith(fontSize: 60)),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      '${session.impostor.name} war\nder Impostor',
                      textAlign: TextAlign.center,
                      style: AppText.display(p.textPrimary).copyWith(fontSize: 34, height: 1.1),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      caught
                          ? 'Die Gruppe hat ${session.impostor.name} mit ${session.voteCounts[accusedIndex]} Stimmen erwischt.'
                          : '${accused.name} wurde stattdessen verdächtigt — der Impostor ist entkommen.',
                      textAlign: TextAlign.center,
                      style: AppText.bodySmall(p.textSecondary),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: p.outlineVariant)),
                      child: Column(
                        children: [
                          _InfoRow(label: 'DAS WORT WAR', value: session.word, valueColor: p.accentSafe),
                          Divider(color: p.outlineVariant, height: 25),
                          if (session.impostorGuess != null && session.impostorGuess!.trim().isNotEmpty) ...[
                            _InfoRow(label: '${germanUpper(session.impostor.name)} TIPPTE AUF', value: '„${session.impostorGuess}"', valueColor: p.textPrimary),
                            Divider(color: p.outlineVariant, height: 25),
                          ],
                          _InfoRow(
                            label: 'PUNKTE',
                            value: 'Gruppe ${session.groupScore} · Impostor ${session.impostorScore}',
                            valueColor: p.primary,
                            mono: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 30),
                child: Column(
                  children: [
                    AppButton(label: 'Nächste Runde', size: AppButtonSize.large, onPressed: onNextRound),
                    const SizedBox(height: 10),
                    AppButton(label: 'Punktestand & beenden', filled: false, onPressed: onEnd),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.valueColor, this.mono = false});

  final String label;
  final String value;
  final Color valueColor;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.labelMono(p.textMuted, size: 11)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: mono ? AppText.monoValue(valueColor, size: 15) : AppText.title(valueColor).copyWith(fontSize: 17),
          ),
        ),
      ],
    );
  }
}
