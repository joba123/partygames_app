import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';

class ScoreEntry {
  const ScoreEntry({required this.name, required this.score, this.detail});

  final String name;
  final int score;
  final String? detail;
}

/// Shared podium for every game that keeps score. Ties are shown as ties —
/// nothing is invented to force a single winner.
///
/// Reaching this screen is what counts as "a round played" for the promo and
/// rating pacing, so the counter is bumped here rather than in ten game
/// screens that would each have to remember.
class GameResultScreen extends StatefulWidget {
  const GameResultScreen({
    super.key,
    required this.title,
    required this.entries,
    required this.scoreUnit,
    required this.onRematch,
    required this.onExit,
    this.subtitle,
    this.lowerIsBetter = false,
  });

  final String title;
  final String? subtitle;
  final List<ScoreEntry> entries;

  /// Mono suffix behind each number, e.g. "PUNKTE" or "SCHLUCKE".
  final String scoreUnit;

  final VoidCallback onRematch;
  final VoidCallback onExit;

  /// Ich-hab-noch-nie ranks by sips collected, where fewer is the cleaner record.
  final bool lowerIsBetter;

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  @override
  void initState() {
    super.initState();
    // initState runs inside the build phase, and markRoundFinished notifies
    // listeners — doing it inline throws "setState() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().markRoundFinished();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ranked = List.of(widget.entries)
      ..sort((a, b) => widget.lowerIsBetter ? a.score.compareTo(b.score) : b.score.compareTo(a.score));
    final topScore = ranked.isEmpty ? 0 : ranked.first.score;
    final winners = ranked.where((e) => e.score == topScore).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Column(
                children: [
                  Text('ENDSTAND', style: AppText.labelMono(p.textMuted, size: 11)),
                  const SizedBox(height: 10),
                  Text(
                    winners.length == 1 ? '${winners.first.name} gewinnt' : widget.title,
                    textAlign: TextAlign.center,
                    style: AppText.headline(p.textPrimary),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.subtitle!, textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
                  ] else if (winners.length > 1) ...[
                    const SizedBox(height: 8),
                    Text('Unentschieden zwischen ${winners.map((w) => w.name).join(', ')}.',
                        textAlign: TextAlign.center, style: AppText.bodySmall(p.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                itemCount: ranked.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final e = ranked[i];
                  final leading = e.score == topScore;
                  return Container(
                    constraints: const BoxConstraints(minHeight: 68),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: leading ? p.primary.withValues(alpha: .12) : p.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: leading ? p.primary : p.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 26, child: Text('${i + 1}', style: AppText.monoValue(p.textFaint, size: 15))),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.nameLabel(p.textPrimary)),
                              if (e.detail != null) ...[
                                const SizedBox(height: 4),
                                Text(e.detail!, style: AppText.caption(p.textMuted).copyWith(fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${e.score}', style: AppText.monoValue(p.textPrimary, size: 22, weight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        Text(germanUpper(widget.scoreUnit), style: AppText.labelMono(p.textFaint, size: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 30),
              child: Column(
                children: [
                  AppButton(label: 'Nochmal', size: AppButtonSize.large, onPressed: widget.onRematch),
                  const SizedBox(height: 10),
                  AppButton(label: 'Zurück zur Übersicht', filled: false, onPressed: widget.onExit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
