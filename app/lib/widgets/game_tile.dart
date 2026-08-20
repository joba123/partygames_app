import 'package:flutter/material.dart';
import '../data/games.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'game_icons.dart';

/// Blends [accent] into [base] — used to derive every tinted surface from the
/// one category colour, so a new category needs no new hand-picked hex codes.
Color _tint(Color accent, Color base, double alpha) =>
    Color.alphaBlend(accent.withValues(alpha: alpha), base);

/// 2-column grid tile. The icon medallion carries the category colour and the
/// game's own glyph, so a tile is recognisable before the label is read —
/// which is the whole point when the phone is going round a dark room.
class GameTile extends StatelessWidget {
  const GameTile({super.key, required this.game, this.onTap});

  final GameInfo game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final brightness = Theme.of(context).brightness;
    final accent = AppColors.category(game.category, brightness);
    final dark = brightness == Brightness.dark;

    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: p.outlineVariant),
            // A faint wash from the icon corner gives every category its own
            // temperature without shouting.
            gradient: RadialGradient(
              center: const Alignment(-0.85, -0.95),
              radius: 1.5,
              colors: [
                _tint(accent, p.surface, dark ? 0.13 : 0.10),
                p.surface,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconMedallion(icon: game.icon, accent: accent, base: p.surface, size: 54, glyphSize: 27),
                    const Spacer(),
                    if (game.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(999)),
                        child: Text(
                          game.badge!,
                          style: AppText.labelMono(
                            dark ? AppColors.darkBackground : Colors.white,
                            size: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title(p.textPrimary).copyWith(fontSize: 16, height: 1.15),
                ),
                const SizedBox(height: 5),
                Text(
                  game.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(p.textMuted).copyWith(fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        game.category.label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.labelMono(p.textFaint, size: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded icon plate. Shared by the tile and the hero card so the glyph sits
/// in the same frame at both sizes.
class _IconMedallion extends StatelessWidget {
  const _IconMedallion({
    required this.icon,
    required this.accent,
    required this.base,
    required this.size,
    required this.glyphSize,
  });

  final GameIconType icon;
  final Color accent;
  final Color base;
  final double size;
  final double glyphSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_tint(accent, base, 0.26), _tint(accent, base, 0.10)],
        ),
      ),
      alignment: Alignment.center,
      child: GameIconGlyph(type: icon, color: accent, size: glyphSize),
    );
  }
}

/// Full-width hero card for the most-recently-played game. Takes its colour
/// from the game's own category instead of a fixed orange, so featuring a
/// different game actually looks different.
class HeroGameCard extends StatelessWidget {
  const HeroGameCard({super.key, required this.game, this.onTap});

  final GameInfo game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    final accent = AppColors.category(game.category, brightness);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: accent.withValues(alpha: dark ? 0.38 : 0.30)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [_tint(accent, p.surface, 0.22), _tint(accent, p.background, 0.07)]
                  : [_tint(accent, Colors.white, 0.18), _tint(accent, Colors.white, 0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                _IconMedallion(
                  icon: game.icon,
                  accent: accent,
                  base: p.surface,
                  size: 64,
                  glyphSize: 32,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              game.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.title(p.textPrimary).copyWith(fontSize: 20, height: 1.15),
                            ),
                          ),
                          if (game.badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(999)),
                              child: Text(
                                game.badge!,
                                style: AppText.labelMono(dark ? AppColors.darkBackground : Colors.white, size: 9),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(game.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.caption(p.textSecondary)),
                      const SizedBox(height: 5),
                      Text(game.meta, style: AppText.labelMono(p.textMuted, size: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
