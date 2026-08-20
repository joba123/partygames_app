import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

enum AppButtonSize { standard, large }

/// Filled or outline button. No touch target under 48px; primary in-game
/// actions use [AppButtonSize.large] (64px) and sit in the bottom third.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.standard,
    this.filled = true,
    this.color,
    this.onColor,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool filled;
  final Color? color;
  final Color? onColor;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final height = size == AppButtonSize.large ? AppSpacing.primaryActionHeight : 56.0;
    final radius = size == AppButtonSize.large ? AppRadius.button + 2 : AppRadius.button;
    final disabled = onPressed == null;

    final bg = filled ? (color ?? p.primary) : Colors.transparent;
    final fg = filled ? (onColor ?? p.onPrimary) : p.textPrimary;
    final effectiveBg = disabled && filled ? p.surfaceContainer : bg;
    final effectiveFg = disabled ? p.textFaint : fg;

    final child = Text(
      label,
      textAlign: TextAlign.center,
      style: size == AppButtonSize.large
          ? AppText.buttonLabelLarge(effectiveFg)
          : AppText.buttonLabel(effectiveFg),
    );

    final button = Material(
      color: effectiveBg,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          alignment: Alignment.center,
          decoration: !filled
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: disabled ? p.outlineVariant : p.outline),
                )
              : null,
          child: child,
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Pill chip — 44px tall, used for filters and secondary choices.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.mono = false,
    this.color,
    this.onColor,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool mono;
  final Color? color;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = selected ? (color ?? p.primary) : p.surface;
    final fg = selected ? (onColor ?? p.onPrimary) : p.textSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: selected ? null : Border.all(color: p.outline),
          ),
          child: Text(
            label,
            style: mono
                ? AppText.labelMono(fg, size: 12)
                : TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                    color: fg,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Small square icon button (44–48px), used for back/close/menu affordances.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.outline),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: p.textSecondary),
        ),
      ),
    );
  }
}
