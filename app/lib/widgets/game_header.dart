import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'buttons.dart';

/// Every game screen wears the same hat: back on the left, a mono status
/// line in the middle, an optional accent chip on the right. Factored out so
/// ten screens cannot drift apart by a few pixels each.
class GameHeader extends StatelessWidget {
  const GameHeader({super.key, required this.status, this.trailingLabel, this.trailingColor, this.onBack});

  final String status;
  final String? trailingLabel;
  final Color? trailingColor;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = trailingColor ?? p.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack ?? () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                germanUpper(status),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.labelMono(p.textMuted, size: 11),
              ),
            ),
          ),
          if (trailingLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(germanUpper(trailingLabel!), style: AppText.labelMono(accent, size: 11)),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }
}
