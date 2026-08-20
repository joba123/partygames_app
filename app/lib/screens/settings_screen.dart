import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/card_counts.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../widgets/buttons.dart';
import '../widgets/settings_tiles.dart';
import 'premium_screen.dart';

/// Screen 12 — content categories share the dot code from the Hub;
/// "Alkoholfrei" is a hard filter, not a suggestion. Upsell lives in the
/// status row, not a banner.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
                  const SizedBox(height: 14),
                  Text('Einstellungen', style: AppText.headline(p.textPrimary)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                children: [
                  Text('KATEGORIEN', style: AppText.labelMono(p.textMuted, size: 11).copyWith(letterSpacing: 11 * 0.14)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: p.outlineVariant)),
                    child: Column(
                      children: [
                        CategoryToggleTile(
                          dotColor: p.primary,
                          label: 'Harmlos',
                          value: appState.contentCategories[ContentCategory.harmlos]!,
                          onChanged: (_) => appState.toggleContentCategory(ContentCategory.harmlos),
                        ),
                        CategoryToggleTile(
                          dotColor: p.secondary,
                          label: 'Flirty',
                          value: appState.contentCategories[ContentCategory.flirty]!,
                          onChanged: (_) => appState.toggleContentCategory(ContentCategory.flirty),
                        ),
                        CategoryToggleTile(
                          dotColor: p.danger,
                          label: 'Für Mutige',
                          subtitle: '18+, kann eskalieren',
                          value: appState.contentCategories[ContentCategory.fuerMutige]!,
                          onChanged: (_) => appState.toggleContentCategory(ContentCategory.fuerMutige),
                        ),
                        CategoryToggleTile(
                          dotColor: p.accentSafe,
                          label: 'Alkoholfrei',
                          subtitle: 'Keine Trink-Aufgaben',
                          value: appState.contentCategories[ContentCategory.alkoholfrei]!,
                          onChanged: (_) => appState.toggleContentCategory(ContentCategory.alkoholfrei),
                          showBorder: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('APP', style: AppText.labelMono(p.textMuted, size: 11).copyWith(letterSpacing: 11 * 0.14)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(AppRadius.card), border: Border.all(color: p.outlineVariant)),
                    child: Column(
                      children: [
                        Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.surfaceContainer))),
                          child: Row(
                            children: [
                              Expanded(child: Text('Design', style: AppText.nameLabel(p.textPrimary))),
                              DesignModeSegmented<DesignMode>(
                                value: appState.designMode,
                                options: const {DesignMode.dark: 'DARK', DesignMode.light: 'LIGHT', DesignMode.auto: 'AUTO'},
                                onChanged: appState.setDesignMode,
                              ),
                            ],
                          ),
                        ),
                        SimpleToggleTile(label: 'Vibration', value: appState.vibration, onChanged: (_) => appState.toggleVibration()),
                        SimpleToggleTile(label: 'Sound', value: appState.sound, onChanged: (_) => appState.toggleSound(), showBorder: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 30),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sheet),
                  onTap: appState.isPremium
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      border: Border.all(color: p.outline),
                    ),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: p.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text('${activeCardCount(appState.contentFilter)} Karten aktiv',
                              style: AppText.nameLabel(p.textSecondary)),
                        ),
                        if (!appState.isPremium)
                          Text('+${lockedPremiumCardCount(appState.contentFilter)} MIT PLUS',
                              style: AppText.labelMono(p.primary, size: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
