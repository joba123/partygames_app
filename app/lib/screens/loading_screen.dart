import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_palette.dart';
import '../theme/app_text.dart';
import '../widgets/app_logo.dart';
import '../widgets/grid_background.dart';
import 'hub_screen.dart';

/// Screen 01 — the loading screen.
///
/// It really loads: the stored roster, settings and Pro status come off disk
/// here, so the hub never renders with defaults that are about to be replaced.
/// The bar is held for a minimum beat as well — on a fast device the read
/// finishes in a few milliseconds and a bar that flashes past reads as a bug.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, this.minimumDuration = const Duration(milliseconds: 1100)});

  final Duration minimumDuration;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.minimumDuration)..forward();

  String _status = 'Runde wird vorbereitet';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  Future<void> _boot() async {
    final appState = context.read<AppState>();
    final started = DateTime.now();

    try {
      // A wedged platform channel must not become a permanent splash screen.
      await appState.load().timeout(const Duration(seconds: 5));
    } catch (error) {
      // A broken preferences store must not keep anyone out of the app —
      // defaults are perfectly playable.
      if (mounted) setState(() => _status = 'Mit Standardeinstellungen weiter');
    }

    final elapsed = DateTime.now().difference(started);
    final remaining = widget.minimumDuration - elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);

    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, a, b) => const HubScreen(),
        transitionsBuilder: (context, animation, a, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: GridBackground(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.56),
              radius: 1.1,
              colors: [Color.lerp(p.surface, p.background, 0.15)!, p.background],
              stops: const [0, 0.62],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                const AppLogoMark(size: 132),
                const SizedBox(height: 28),
                Text('Imposter', style: AppText.display(p.textPrimary).copyWith(fontSize: 40)),
                const SizedBox(height: 10),
                Text('OFFLINE PARTYSPIELE',
                    style: AppText.labelMono(p.textFaint, size: 12).copyWith(letterSpacing: 12 * 0.24)),
                const Spacer(flex: 3),
                SizedBox(
                  width: 120,
                  height: 4,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _controller.value,
                        backgroundColor: p.outlineVariant,
                        valueColor: AlwaysStoppedAnimation(p.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(_status.toUpperCase(), style: AppText.labelMono(p.textDim, size: 11)),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
