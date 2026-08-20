import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/buttons.dart';
import '../premium_screen.dart';

/// The one interruption the app allows itself: a full-screen pitch for Pro,
/// shown between rounds.
///
/// It is our own promo, not a third-party ad — see the note in the monetization
/// section of the commit. It is dismissible on the first frame: a forced
/// countdown would buy a couple of extra seconds of attention and cost the
/// good will of a group that is mid-party.
class HouseAdScreen extends StatelessWidget {
  const HouseAdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 0),
              child: Row(
                children: [
                  Text('IN EIGENER SACHE', style: AppText.labelMono(p.textDim, size: 10)),
                  const Spacer(),
                  AppIconButton(icon: Icons.close_rounded, onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogoMark(size: 84),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Noch eine Runde?',
                          textAlign: TextAlign.center, style: AppText.display(p.textPrimary).copyWith(fontSize: 36)),
                      const SizedBox(height: 14),
                      Text(
                        'Mit Pro läuft der Abend ohne Unterbrechung — und "Für Mutige" '
                        'ist in allen Modi freigeschaltet.',
                        textAlign: TextAlign.center,
                        style: AppText.bodySmall(p.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const _Perk(text: 'Keine Hinweise mehr wie dieser'),
                      const SizedBox(height: 10),
                      const _Perk(text: '„Für Mutige" in jedem Modus'),
                      const SizedBox(height: 10),
                      const _Perk(text: 'Alle Bonuskarten in jedem Deck'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 12, AppSpacing.screenPadding, 28),
              child: Column(
                children: [
                  AppButton(
                    label: 'Pro ansehen',
                    size: AppButtonSize.large,
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
                    },
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Weiterspielen',
                    filled: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the promo and records it, so the policy can pace the next one.
  static Future<void> present(BuildContext context) async {
    context.read<AppState>().markAdShown();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HouseAdScreen(), fullscreenDialog: true),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Icon(Icons.check_rounded, size: 18, color: p.accentSafe),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppText.bodySmall(p.textPrimary))),
      ],
    );
  }
}
