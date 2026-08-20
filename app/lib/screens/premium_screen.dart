import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/card_counts.dart';
import '../monetization/purchase_gateway.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../widgets/app_logo.dart';
import '../widgets/buttons.dart';

/// Screen 13 — no countdown, no discount pressure, no mid-game paywall.
/// Only reachable via Settings and the status row; one-time purchase is
/// visually favoured over the subscription.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [AppIconButton(icon: Icons.close_rounded, onTap: () => Navigator.of(context).pop())],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                children: [
                  const AppLogoMark(size: 56),
                  const SizedBox(height: 14),
                  Text('Imposter Plus', style: AppText.headline(p.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Alles Wichtige bleibt gratis. Pro ist für Runden, die nicht aufhören wollen.',
                      style: AppText.bodySmall(p.textSecondary)),
                  const SizedBox(height: 22),
                  // Only things Pro actually does today — a paywall that
                  // promises features the build does not have earns refunds.
                  _FeatureRow(
                    icon: Icons.block_rounded,
                    color: const Color(0xFF9BE8D8),
                    title: 'Keine Hinweise mehr',
                    subtitle: 'Der Abend läuft ohne Unterbrechung durch',
                  ),
                  const SizedBox(height: 10),
                  _FeatureRow(
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF8A7A),
                    title: '„Für Mutige" freigeschaltet',
                    subtitle: 'In jedem Modus wählbar, 18+',
                  ),
                  const SizedBox(height: 10),
                  _FeatureRow(
                    icon: Icons.style_rounded,
                    color: const Color(0xFFFFC49B),
                    title: '+${lockedPremiumCardCount(appState.contentFilter)} Bonuskarten',
                    subtitle: 'Verteilt über alle Decks',
                  ),
                  const SizedBox(height: 22),
                  IntrinsicHeight(
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: p.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('MONAT', style: AppText.labelMono(p.textMuted, size: 11)),
                              const SizedBox(height: 4),
                              Text('2,49 €', style: AppText.title(p.textPrimary).copyWith(fontSize: 26)),
                              const SizedBox(height: 4),
                              Text('jederzeit kündbar', style: AppText.caption(p.textMuted).copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: p.primary.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(AppRadius.card),
                                border: Border.all(color: p.primary, width: 2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('FÜR IMMER', style: AppText.labelMono(p.primary, size: 11)),
                                  const SizedBox(height: 4),
                                  Text('12,99 €', style: AppText.title(p.primary).copyWith(fontSize: 26)),
                                  const SizedBox(height: 4),
                                  Text('kein Abo, kein Stress', style: AppText.caption(p.textSecondary).copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -11,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(999)),
                                child: Text('EINMALIG', style: AppText.labelMono(p.onPrimary, size: 10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 30),
              child: Column(
                children: [
                  AppButton(
                    label: appState.isPremium ? 'Bereits freigeschaltet' : 'Einmalig freischalten',
                    size: AppButtonSize.large,
                    onPressed: appState.isPremium
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            await LocalUnlockGateway(appState).buyLifetime();
                            navigator.pop();
                          },
                  ),
                  const SizedBox(height: 12),
                  if (!appState.isPremium)
                    GestureDetector(
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final restored = await LocalUnlockGateway(appState).restore();
                        if (!restored) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Kein früherer Kauf gefunden.')),
                          );
                        }
                      },
                      child: Text('Käufe wiederherstellen', style: AppText.caption(p.textFaint)),
                    )
                  else
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text('Später — erstmal weiterspielen', style: AppText.caption(p.textFaint)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.color, required this.title, required this.subtitle});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.outlineVariant)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: .14), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppText.title(p.textPrimary).copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.caption(p.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
