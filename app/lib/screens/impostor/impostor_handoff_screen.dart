import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/impostor_session.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_text.dart';
import '../../widgets/avatar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/grid_background.dart';

/// Screen 04 — handoff has its own background colour (secondary tint) so
/// it never reads as game content; name is huge, confirmation is by name
/// so nobody accidentally reveals the wrong player's role.
class ImpostorHandoffScreen extends StatelessWidget {
  const ImpostorHandoffScreen({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ImpostorSession>();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final player = session.currentDistributionPlayer;
    final total = session.players.length;
    final index = session.distributionIndex;

    final bg = dark ? const Color(0xFF1F1226) : const Color(0xFFF7EDFB);
    final ringBg = dark ? const Color(0xFFE5B6F2).withValues(alpha: .12) : const Color(0xFF7B3E96).withValues(alpha: .10);
    final ringBorder = dark ? const Color(0xFFE5B6F2).withValues(alpha: .35) : const Color(0xFF7B3E96).withValues(alpha: .35);
    final titleColor = dark ? const Color(0xFFF7F1EA) : const Color(0xFF241A14);
    final subtitleColor = dark ? const Color(0xFFC8A7D6) : const Color(0xFF6B564A);
    final eyebrowColor = dark ? const Color(0xFFC8A7D6) : const Color(0xFF7B3E96);
    final p = context.palette;

    return Scaffold(
      backgroundColor: bg,
      body: GridBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('HANDY WEITERGEBEN', style: AppText.labelMono(eyebrowColor, size: 12).copyWith(letterSpacing: 12 * 0.2)),
                      const SizedBox(height: 32),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(color: ringBg, shape: BoxShape.circle, border: Border.all(color: ringBorder, width: 2)),
                        alignment: Alignment.center,
                        child: AvatarCircleRound(initial: player.initial, colorIndex: index, size: 120),
                      ),
                      const SizedBox(height: 32),
                      Text('${player.name},', textAlign: TextAlign.center, style: AppText.display(titleColor).copyWith(fontSize: 40, height: 1.05)),
                      Text('du bist dran', textAlign: TextAlign.center, style: AppText.display(titleColor).copyWith(fontSize: 40, height: 1.05)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text('Nimm das Handy und halt es so, dass niemand mitliest.',
                            textAlign: TextAlign.center, style: AppText.bodySmall(subtitleColor)),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(total, (i) {
                          final done = i <= index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              width: 26,
                              height: 5,
                              decoration: BoxDecoration(
                                color: done ? p.secondary : (dark ? const Color(0xFF4A2F58) : const Color(0xFFE7D3EF)),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: AppButton(
                  label: 'Ich bin ${player.name}',
                  size: AppButtonSize.large,
                  color: p.secondary,
                  onColor: p.onSecondary,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
