import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/presentation/game_screen.dart';
import 'package:flutter/material.dart';

/// 2x2 grid that lets the user toggle which [ChannelType]s are active.
/// Selected cells are highlighted; unselected ones are muted. No checkboxes —
/// the visual state alone communicates selection.
class ChannelSelectionGrid extends StatelessWidget {
  const ChannelSelectionGrid({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Set<ChannelType> selected;
  final ValueChanged<Set<ChannelType>> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final c in ChannelType.values)
          _ChannelCell(
            channel: c,
            selected: selected.contains(c),
            onTap: () {
              final next = {...selected};
              if (next.contains(c)) {
                next.remove(c);
              } else {
                next.add(c);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _ChannelCell extends StatelessWidget {
  const _ChannelCell({
    required this.channel,
    required this.selected,
    required this.onTap,
  });

  final ChannelType channel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final fg = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final borderColor = selected ? scheme.primary : scheme.outlineVariant;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              channelLabel(context, channel),
              style: TextStyle(
                color: fg,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
