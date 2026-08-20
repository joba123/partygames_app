import 'package:flutter/material.dart';
import '../data/games.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'game_icons.dart';

/// 2-column grid tile: icon top-left, title + category mono label pinned
/// to the bottom — scannable without reading.
class GameTile extends StatelessWidget {
  const GameTile({super.key, required this.game, this.onTap});

  final GameInfo game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final brightness = Theme.of(context).brightness;
    final accent = AppColors.category(game.category, brightness);
    final tint = AppColors.categoryTint(game.category, brightness);

    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: p.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: GameIconGlyph(type: game.icon, color: accent, size: 22),
              ),
              const Spacer(),
              Text(game.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.title(p.textPrimary).copyWith(fontSize: 15, height: 1.2)),
              const SizedBox(height: 4),
              Text(game.category.label.toUpperCase(), style: AppText.labelMono(p.textFaint, size: 9)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width hero card for the most-recently-played game.
class HeroGameCard extends StatelessWidget {
  const HeroGameCard({super.key, required this.game, this.onTap});

  final GameInfo game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.category(game.category, Theme.of(context).brightness);

    final gradient = dark
        ? const LinearGradient(colors: [Color(0xFF3A2321), Color(0xFF241817)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Color(0xFFFFE6D6), Color(0xFFFFF1E7)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final borderColor = dark ? const Color(0xFF4A302C) : const Color(0xFFF0D3C0);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(18)),
                alignment: Alignment.center,
                child: GameIconGlyph(type: game.icon, color: accent, size: 28),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(game.title, style: AppText.title(p.textPrimary).copyWith(fontSize: 20, height: 1.15))),
                        if (game.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: p.primary.withValues(alpha: dark ? 1 : 1), borderRadius: BorderRadius.circular(999)),
                            child: Text(game.badge!, style: AppText.labelMono(p.onPrimary, size: 9)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(game.description, style: AppText.caption(p.textSecondary)),
                    const SizedBox(height: 5),
                    Text(game.meta, style: AppText.labelMono(p.textMuted, size: 10)),
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
