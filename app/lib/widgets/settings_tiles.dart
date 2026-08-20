import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_text.dart';

class CategoryToggleTile extends StatelessWidget {
  const CategoryToggleTile({
    super.key,
    required this.dotColor,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.showBorder = true,
  });

  final Color dotColor;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: showBorder ? Border(bottom: BorderSide(color: p.surfaceContainer)) : null,
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 14),
          Expanded(
            child: subtitle == null
                ? Text(label, style: AppText.nameLabel(p.textPrimary))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: AppText.nameLabel(p.textPrimary)),
                      const SizedBox(height: 3),
                      Text(subtitle!, style: AppText.caption(p.textFaint).copyWith(fontSize: 12)),
                    ],
                  ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class SimpleToggleTile extends StatelessWidget {
  const SimpleToggleTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showBorder = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: showBorder ? Border(bottom: BorderSide(color: p.surfaceContainer)) : null,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.nameLabel(p.textPrimary))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Dark/Light/Auto segmented control, wired to the real ThemeMode.
class DesignModeSegmented<T> extends StatelessWidget {
  const DesignModeSegmented({super.key, required this.value, required this.options, required this.onChanged});

  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.surfaceContainer, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.entries.map((e) {
          final selected = e.key == value;
          return GestureDetector(
            onTap: () => onChanged(e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? p.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(e.value, style: AppText.labelMono(selected ? p.onPrimary : p.textFaint, size: 11)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
