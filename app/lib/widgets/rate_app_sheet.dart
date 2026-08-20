import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'buttons.dart';

/// Play Store listing for this package. Swap the id if the application id
/// ever changes — it is the same one as in android/app/build.gradle.kts.
final storeListing = Uri.parse(
  'https://play.google.com/store/apps/details?id=com.imposterparty.imposter_party',
);

/// The rating prompt.
///
/// Asked once, after five finished rounds, and only ever between rounds. The
/// two-step shape is deliberate: people who are not enjoying the app get an
/// exit that does not send them to a public review form, which is both kinder
/// and better for the rating average than a blunt "rate us now".
class RateAppSheet extends StatelessWidget {
  const RateAppSheet({super.key, this.onOpenStore});

  /// Injected by tests; production opens the real store listing.
  final Future<bool> Function(Uri url)? onOpenStore;

  static Future<void> present(BuildContext context, {Future<bool> Function(Uri url)? onOpenStore}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RateAppSheet(onOpenStore: onOpenStore),
    );
  }

  Future<void> _rate(BuildContext context) async {
    final appState = context.read<AppState>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    appState.setRatingState(2);
    final open = onOpenStore ?? (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

    var opened = false;
    try {
      opened = await open(storeListing);
    } catch (_) {
      opened = false;
    }

    navigator.pop();
    if (!opened) {
      // No store on this device (emulator, sideloaded build) — say so instead
      // of leaving the tap looking broken.
      messenger.showSnackBar(const SnackBar(content: Text('Store lässt sich hier nicht öffnen.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.read<AppState>();

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        border: Border.all(color: p.outlineVariant),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 14, AppSpacing.xl, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(color: p.outline, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(Icons.star_rounded, size: 26, color: p.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('${appState.roundsFinished} Runden gespielt',
              style: AppText.labelMono(p.textMuted, size: 11)),
          const SizedBox(height: 10),
          Text('Läuft es gut?', textAlign: TextAlign.center, style: AppText.headline(p.textPrimary)),
          const SizedBox(height: 10),
          Text(
            'Eine Bewertung im Store hilft uns mehr als alles andere — und dauert '
            'kürzer als eine Runde Bombe.',
            textAlign: TextAlign.center,
            style: AppText.bodySmall(p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Klar, bewerten',
            size: AppButtonSize.large,
            onPressed: () => _rate(context),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Später',
                  filled: false,
                  onPressed: () {
                    appState.setRatingState(1);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Nicht fragen',
                  filled: false,
                  onPressed: () {
                    appState.setRatingState(2);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
