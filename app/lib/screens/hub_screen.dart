import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/games.dart';
import '../monetization/promo_policy.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../widgets/buttons.dart';
import '../widgets/game_tile.dart';
import '../widgets/rate_app_sheet.dart';
import 'player_setup_screen.dart';
import 'settings_screen.dart';
import 'shared/house_ad_screen.dart';

/// Screen 02 / 02b — Hub, dark by default, light via ThemeMode.light.
/// Hero card = last-played (Impostor); 2-col grid below, filterable by
/// category; bottom nav Spiele / Gruppe / Mehr.
class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  int _navIndex = 0;

  Future<void> _openGame(GameInfo game) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => PlayerSetupScreen(game: game)));
    if (!mounted) return;
    await _checkInterruptions();
  }

  /// Anything the app wants from the group happens here — back on the hub,
  /// between rounds, never inside a game.
  Future<void> _checkInterruptions() async {
    final interruption = PromoPolicy.nextInterruption(context.read<AppState>());
    if (interruption == Interruption.none) return;
    if (interruption == Interruption.rating) {
      await RateAppSheet.present(context);
    } else {
      await HouseAdScreen.present(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();
    final hero = gameById(appState.lastPlayed);
    final filter = appState.hubFilter;
    final rest = games.where((g) => g.id != hero.id && (filter == null || g.category == filter)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${appState.players.length} SPIELER BEREIT', style: AppText.labelMono(p.textMuted, size: 11)),
                        const SizedBox(height: 4),
                        Text('Was zocken wir?', style: AppText.headline(p.textPrimary)),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    size: 48,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                children: [
                  AppChip(label: 'Alle ${games.length}', selected: filter == null, onTap: () => appState.setHubFilter(null)),
                  const SizedBox(width: 8),
                  for (final c in GameCategory.values) ...[
                    AppChip(label: c.label, selected: filter == c, onTap: () => appState.setHubFilter(c)),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.xl),
                children: [
                  if (filter == null || filter == hero.category)
                    HeroGameCard(game: hero, onTap: () => _openGame(hero)),
                  if (filter == null || filter == hero.category) const SizedBox(height: AppSpacing.cardGap),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rest.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.cardGap,
                      crossAxisSpacing: AppSpacing.cardGap,
                      mainAxisExtent: 194,
                    ),
                    itemBuilder: (context, i) => GameTile(game: rest[i], onTap: () => _openGame(rest[i])),
                  ),
                ],
              ),
            ),
            _BottomNav(
              index: _navIndex,
              onTap: (i) {
                setState(() => _navIndex = i);
                if (i == 1) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const PlayerSetupScreen(game: null)))
                      .then((_) => setState(() => _navIndex = 0));
                } else if (i == 2) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
                      .then((_) => setState(() => _navIndex = 0));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const items = [
      (Icons.style_outlined, 'SPIELE'),
      (Icons.groups_outlined, 'GRUPPE'),
      (Icons.tune_rounded, 'MEHR'),
    ];
    return Container(
      height: 78,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == index;
          final color = active ? p.primary : p.textFaint;
          return InkWell(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(items[i].$1, size: 22, color: color),
                  const SizedBox(height: 5),
                  Text(items[i].$2, style: AppText.labelMono(color, size: 10)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
