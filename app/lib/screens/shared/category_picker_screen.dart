import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/card_counts.dart';
import '../../data/games.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/game_header.dart';
import '../premium_screen.dart';

/// The step between the roster and the round: which kinds of cards are in
/// play tonight.
///
/// It starts from the global settings but writes a per-round override, so
/// turning "Flirty" off once for the in-laws does not silently change the
/// defaults for the rest of the year. The live card count under the list is
/// the honest feedback — pick too narrowly and you can watch the deck shrink.
class CategoryPickerScreen extends StatefulWidget {
  const CategoryPickerScreen({
    super.key,
    required this.game,
    required this.stepLabel,
    required this.onStart,
  });

  final GameInfo game;

  /// e.g. "Schritt 2 von 2" — the roster step counts as the first.
  final String stepLabel;

  final Widget Function() onStart;

  @override
  State<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends State<CategoryPickerScreen> {
  late Map<ContentCategory, bool> _selection;

  @override
  void initState() {
    super.initState();
    _selection = Map.of(context.read<AppState>().contentCategories);
  }

  /// Mirrors [AppState.contentFilter] against the pending selection, so the
  /// count below the list matches the deck the round will actually get.
  ContentFilter _filterFor(AppState appState) => ContentFilter(
        spices: {
          if (_selection[ContentCategory.harmlos] ?? false) Spice.harmlos,
          if (_selection[ContentCategory.flirty] ?? false) Spice.flirty,
          if ((_selection[ContentCategory.fuerMutige] ?? false) && appState.isPremium) Spice.fuerMutige,
        },
        noAlcohol: _selection[ContentCategory.alkoholfrei] ?? false,
        premium: appState.isPremium,
      );

  void _toggle(ContentCategory category, AppState appState) {
    if (appState.isCategoryLocked(category)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
      return;
    }
    setState(() => _selection[category] = !(_selection[category] ?? false));
  }

  void _start(AppState appState) {
    appState.setRoundCategories(_selection);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => widget.onStart()));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();
    final pool = poolForGame(widget.game.id);
    final filter = _filterFor(appState);
    final available = pool.where(filter.allows).length;

    // Everything the spice toggles could still unlock, if Pro were active.
    final lockedAway = pool.where((card) => !filter.allows(card) && card.spice == Spice.fuerMutige).length +
        pool.where((card) => card.premium && !filter.allows(card) && card.spice != Spice.fuerMutige).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // No game title here: "Er/Sie ist eine 10/10" and "Wahrheit oder
            // Pflicht" both overflow the header, and the group just picked it.
            GameHeader(status: widget.stepLabel),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 6, AppSpacing.screenPadding, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Womit spielt ihr?', style: AppText.headline(p.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Gilt nur für diese Runde. Eure Standardeinstellung bleibt.',
                      style: AppText.bodySmall(p.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                children: [
                  _CategoryCard(
                    label: 'Harmlos',
                    subtitle: 'Geht immer, auch vor der Familie',
                    accent: p.primary,
                    value: _selection[ContentCategory.harmlos] ?? false,
                    onTap: () => _toggle(ContentCategory.harmlos, appState),
                  ),
                  const SizedBox(height: 10),
                  _CategoryCard(
                    label: 'Flirty',
                    subtitle: 'Anzüglich, aber harmlos',
                    accent: p.secondary,
                    value: _selection[ContentCategory.flirty] ?? false,
                    onTap: () => _toggle(ContentCategory.flirty, appState),
                  ),
                  const SizedBox(height: 10),
                  _CategoryCard(
                    label: 'Für Mutige',
                    subtitle: appState.isPremium ? '18+, kann eskalieren' : 'Mit Pro freischalten',
                    accent: p.danger,
                    value: (_selection[ContentCategory.fuerMutige] ?? false) && appState.isPremium,
                    locked: appState.isCategoryLocked(ContentCategory.fuerMutige),
                    onTap: () => _toggle(ContentCategory.fuerMutige, appState),
                  ),
                  const SizedBox(height: 10),
                  _CategoryCard(
                    label: 'Alkoholfrei',
                    subtitle: 'Blendet alle Trink-Aufgaben aus',
                    accent: p.accentSafe,
                    value: _selection[ContentCategory.alkoholfrei] ?? false,
                    onTap: () => _toggle(ContentCategory.alkoholfrei, appState),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text('$available', style: AppText.monoDisplay(p.textPrimary, size: 34)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          available == 1 ? 'KARTE IM DECK' : 'KARTEN IM DECK',
                          style: AppText.labelMono(p.textMuted, size: 11),
                        ),
                      ),
                    ],
                  ),
                  if (available == 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Nichts ausgewählt — die Runde läuft dann mit den harmlosen Karten.',
                      style: AppText.caption(p.warning),
                    ),
                  ],
                  if (lockedAway > 0) ...[
                    const SizedBox(height: 14),
                    _LockedHint(count: lockedAway),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 28),
              child: AppButton(
                label: 'Runde starten',
                size: AppButtonSize.large,
                onPressed: () => _start(appState),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.value,
    required this.onTap,
    this.locked = false,
  });

  final String label;
  final String subtitle;
  final Color accent;
  final bool value;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: value ? accent.withValues(alpha: .10) : p.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: value ? accent : p.outlineVariant, width: value ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: locked ? p.textDim : accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppText.nameLabel(locked ? p.textMuted : p.textPrimary)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppText.caption(p.textMuted).copyWith(fontSize: 12)),
                  ],
                ),
              ),
              if (locked)
                Icon(Icons.lock_outline_rounded, size: 20, color: p.textMuted)
              else
                Icon(
                  value ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 24,
                  color: value ? accent : p.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedHint extends StatelessWidget {
  const _LockedHint({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: p.outline),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 18, color: p.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text('$count weitere Karten mit Pro',
                    style: AppText.caption(p.textSecondary).copyWith(fontSize: 13)),
              ),
              Text('ANSEHEN', style: AppText.labelMono(p.primary, size: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
