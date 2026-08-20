import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_text.dart';
import 'avatar.dart';

/// One row in the shared PlayerSetupSheet: avatar initial, name, remove.
class PlayerListTile extends StatelessWidget {
  const PlayerListTile({
    super.key,
    required this.name,
    required this.colorIndex,
    this.onRemove,
    this.dragHandle,
  });

  final String name;
  final int colorIndex;
  final VoidCallback? onRemove;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.outlineVariant),
      ),
      child: Row(
        children: [
          AvatarCircle(initial: name.isEmpty ? '?' : name[0].toUpperCase(), colorIndex: colorIndex),
          const SizedBox(width: 14),
          Expanded(child: Text(name, style: AppText.nameLabel(p.textPrimary))),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close_rounded, size: 18, color: p.textFaint),
              splashRadius: 20,
            ),
          ?dragHandle,
        ],
      ),
    );
  }
}
