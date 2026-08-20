import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_text.dart';
import '../widgets/app_logo.dart';
import '../widgets/grid_background.dart';
import 'hub_screen.dart';

/// Screen 01 — splash, ~1.2s, cross-fades into the Hub.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (context, a, b) => const HubScreen(),
            transitionsBuilder: (context, animation, a, child) => FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    });
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
                Text('OFFLINE PARTYSPIELE', style: AppText.labelMono(p.textFaint, size: 12).copyWith(letterSpacing: 12 * 0.24)),
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
                Text('KEIN INTERNET NÖTIG', style: AppText.labelMono(p.textDim, size: 11)),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
