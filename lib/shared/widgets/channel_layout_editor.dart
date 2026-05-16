import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/presentation/game_screen.dart';
import 'package:flutter/material.dart';

/// Editable 2x2 grid of channel slots. Tapping a cell toggles whether the
/// channel is enabled by default; long-press + drag onto another cell swaps
/// their positions.
class ChannelLayoutEditor extends StatelessWidget {
  const ChannelLayoutEditor({
    required this.layout,
    required this.selected,
    required this.onLayoutChanged,
    required this.onSelectionChanged,
    super.key,
  });

  final List<ChannelType> layout;
  final Set<ChannelType> selected;
  final ValueChanged<List<ChannelType>> onLayoutChanged;
  final ValueChanged<Set<ChannelType>> onSelectionChanged;

  void _swap(int from, int to) {
    if (from == to) return;
    final next = [...layout];
    final tmp = next[from];
    next[from] = next[to];
    next[to] = tmp;
    onLayoutChanged(next);
  }

  void _toggle(ChannelType channel) {
    final next = {...selected};
    if (next.contains(channel)) {
      next.remove(channel);
    } else {
      next.add(channel);
    }
    onSelectionChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const aspectRatio = 1.7;
        final cellWidth = (constraints.maxWidth - spacing) / 2;
        final cellHeight = cellWidth / aspectRatio;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspectRatio,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          children: [
            for (int i = 0; i < layout.length; i++)
              DragTarget<int>(
                onWillAcceptWithDetails: (d) => d.data != i,
                onAcceptWithDetails: (d) => _swap(d.data, i),
                builder: (ctx, candidates, _) {
                  final hover = candidates.isNotEmpty;
                  final channel = layout[i];
                  final isSelected = selected.contains(channel);
                  return LongPressDraggable<int>(
                    data: i,
                    feedback: SizedBox(
                      width: cellWidth,
                      height: cellHeight,
                      child: _LayoutCell(
                        channel: channel,
                        selected: isSelected,
                        elevated: true,
                      ),
                    ),
                    childWhenDragging: _LayoutCell(
                      channel: channel,
                      selected: isSelected,
                      ghost: true,
                    ),
                    child: _LayoutCell(
                      channel: channel,
                      selected: isSelected,
                      hover: hover,
                      onTap: () => _toggle(channel),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _LayoutCell extends StatelessWidget {
  const _LayoutCell({
    required this.channel,
    required this.selected,
    this.hover = false,
    this.ghost = false,
    this.elevated = false,
    this.onTap,
  });

  final ChannelType channel;
  final bool selected;
  final bool hover;
  final bool ghost;
  final bool elevated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color bg;
    if (hover) {
      bg = scheme.primary.withValues(alpha: 0.18);
    } else if (selected) {
      bg = scheme.primaryContainer;
    } else {
      bg = scheme.surfaceContainerLow;
    }
    final fg = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurface.withValues(alpha: 0.45);
    final borderColor = hover
        ? scheme.primary
        : (selected
            ? scheme.primary
            : scheme.outlineVariant.withValues(alpha: 0.5));
    final borderWidth = (hover || selected) ? 2.0 : 1.0;

    return Opacity(
      opacity: ghost ? 0.3 : 1,
      child: Material(
        color: bg,
        elevation: elevated ? 6 : 0,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(channelIcon(channel), size: 32, color: fg),
                const SizedBox(height: 6),
                Text(
                  channelLabel(context, channel),
                  style: TextStyle(color: fg, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
