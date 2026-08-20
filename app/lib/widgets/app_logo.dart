import 'package:flutter/material.dart';

/// Eye-in-a-circle mark, reduced to two shapes — the whole point being it
/// still reads at 48px in a launcher.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 54});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC49B), Color(0xFFE5B6F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.315),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.41,
        height: size * 0.41,
        decoration: const BoxDecoration(color: Color(0xFF141110), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Container(
          width: size * 0.148,
          height: size * 0.148,
          decoration: const BoxDecoration(color: Color(0xFFFFC49B), shape: BoxShape.circle),
        ),
      ),
    );
  }
}
