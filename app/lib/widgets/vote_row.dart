import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_text.dart';
import 'avatar.dart';

/// One row of the VoteList: avatar, name, a dot per vote received.
/// Highlights with a danger outline once it's the leading suspect.
class VoteRow extends StatelessWidget {
  const VoteRow({
    super.key,
    required this.name,
    required this.colorIndex,
    required this.voteCount,
    required this.isLeading,
    this.onTap,
  });

  final String name;
  final int colorIndex;
  final int voteCount;
  final bool isLeading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final highlighted = isLeading && voteCount > 0;
    return Material(
      color: highlighted ? p.danger.withValues(alpha: .1) : p.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: highlighted ? p.danger : p.outlineVariant, width: highlighted ? 2 : 1),
          ),
          child: Row(
            children: [
              AvatarCircle(initial: name.isEmpty ? '?' : name[0].toUpperCase(), colorIndex: colorIndex, size: 44, fontSize: 18),
              const SizedBox(width: 14),
              Expanded(child: Text(name, style: AppText.title(p.textPrimary).copyWith(fontSize: 20, fontWeight: FontWeight.w600))),
              Row(
                children: List.generate(
                  voteCount.clamp(0, 5),
                  (_) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(width: 12, height: 12, decoration: BoxDecoration(color: p.danger, shape: BoxShape.circle)),
                  ),
                ).ifEmpty(() => [Padding(padding: EdgeInsets.zero, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: p.outline, shape: BoxShape.circle)))]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _IfEmpty<T> on List<T> {
  List<T> ifEmpty(List<T> Function() fallback) => isEmpty ? fallback() : this;
}
