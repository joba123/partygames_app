import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// PromptCard(category, text, nextPlayer) — the one card component behind
/// Wahrheit oder Pflicht, Wer würde eher, Ich hab noch nie, Tabu, etc.
class PromptCardView extends StatelessWidget {
  const PromptCardView({
    super.key,
    required this.chips,
    required this.playerLine,
    required this.text,
    this.footnote,
  });

  final List<String> chips;
  final String playerLine;
  final String text;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gradient = dark
        ? const LinearGradient(colors: [Color(0xFF33203A), Color(0xFF1E1424)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Color(0xFFF7EDFB), Color(0xFFFFF1E7)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final borderColor = dark ? const Color(0xFF4A2F58) : const Color(0xFFE7D3EF);
    final chipFg = dark ? p.secondary : p.secondary;
    final chipBg = dark ? p.secondary.withValues(alpha: .18) : p.secondary.withValues(alpha: .12);
    final subtleText = dark ? const Color(0xFFC8A7D6) : p.textMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(999)),
                      child: Text(germanUpper(c), style: AppText.labelMono(chipFg, size: 11)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 22),
          Text(playerLine.toUpperCase(), style: AppText.labelMono(subtleText, size: 12)),
          const SizedBox(height: 14),
          Text(text, style: AppText.headline(p.textPrimary).copyWith(fontSize: 30, height: 1.2)),
          if (footnote != null) ...[
            const SizedBox(height: 14),
            Text(footnote!, style: AppText.caption(subtleText)),
          ],
        ],
      ),
    );
  }
}
