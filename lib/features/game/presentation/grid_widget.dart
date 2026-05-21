import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:flutter/material.dart';

/// A renderer that paints one shape filling the available space, using
/// the given color.
typedef ShapeRenderer = Widget Function(Color color);

Widget _iconShape(IconData icon, Color color) =>
    FittedBox(child: Icon(icon, color: color));

/// Visual recipe for a single shape on the shape channel: how to paint it
/// and an optional per-shape size tweak.
///
/// [sizeFactor] is multiplied with the global [kShapeSizeFactor] when the
/// shape is rendered, so individual icons that visually look smaller or
/// larger than the rest can be compensated for without affecting others.
/// Default is 1.0 (no adjustment).
class ShapeStyle {
  const ShapeStyle({required this.builder, this.sizeFactor = 1.0});

  final ShapeRenderer builder;
  final double sizeFactor;
}

/// Recipes for each shape, in the order used by the stimulus generator
/// (0..[NBackDefaults.shapeCount] − 1). Length must equal
/// [NBackDefaults.shapeCount] (asserted in [NBackGrid.build]).
final List<ShapeStyle> kShapeBuilders = [
  ShapeStyle(builder: (c) => _iconShape(Icons.circle_rounded, c), sizeFactor: 1.1),
  ShapeStyle(builder: (c) => _iconShape(Icons.square_rounded, c), sizeFactor: 1.1),
  ShapeStyle(builder: (c) => _iconShape(Icons.star_rounded, c), sizeFactor: 1.15),
  ShapeStyle(builder: (c) => _iconShape(Icons.favorite_rounded, c)),
  ShapeStyle(builder: (c) => _iconShape(Icons.shield_rounded, c)),
  ShapeStyle(builder: (c) => _iconShape(Icons.audiotrack_rounded, c), sizeFactor: 1.05),
  ShapeStyle(builder: (c) => _iconShape(Icons.cloud_rounded, c), sizeFactor: 0.9),
  ShapeStyle(builder: (c) => _iconShape(Icons.hexagon_rounded, c), sizeFactor: 1.1),
];

/// Index of the center cell in the 3×3 grid. Reserved for a fixation cross.
const int kCenterCellIndex = 4;

/// Fraction of the cell that the rendered shape (icon) fills.
const double kShapeSizeFactor = 0.92;

/// Fraction of the cell that the fixation "+" fills.
const double kFixationSizeFactor = 0.8;

/// Maps a position-channel value to a concrete cell index in the 3×3 grid.
///
/// When [centerAllowed] is false (default Jaeggi behaviour) the input range
/// is 0..7 mapped to the 8 non-center cells (the center is skipped).
/// When [centerAllowed] is true the input range is 0..8 and the mapping is
/// the identity — the center cell is a valid target.
int positionToGridCell(int position, {bool centerAllowed = false}) {
  if (centerAllowed) return position;
  return position < kCenterCellIndex ? position : position + 1;
}

/// Single-cell stimulus pane used when the position channel is OFF —
/// the stimulus fills the whole grid area instead of being placed in one
/// cell of a 3×3 layout.
class NBackSingleCell extends StatelessWidget {
  const NBackSingleCell({
    required this.highlight,
    required this.colorIndex,
    required this.shapeIndex,
    required this.fadeDuration,
    super.key,
  });

  /// True if the stimulus is currently visible (on its display window).
  final bool highlight;

  /// Index into [NBackDefaults.colorPalette] or null if color channel is off.
  final int? colorIndex;

  /// Index into [kShapeBuilders] or null if shape channel is off.
  final int? shapeIndex;

  /// Fade-in/out duration for stimulus appearance/disappearance.
  /// `Duration.zero` means snap on/off.
  final Duration fadeDuration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasShape = shapeIndex != null;
    final showShape = highlight && hasShape;
    final stimulusColor = colorIndex != null
        ? Color(NBackDefaults.colorPalette[colorIndex!])
        : scheme.primary;
    // When a shape is shown, the color belongs to the shape — the
    // panel stays neutral so the colored shape stands out.
    final cellColor = highlight && !showShape
        ? stimulusColor
        : scheme.surfaceContainerHighest;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedContainer(
          duration: fadeDuration,
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          // Always-mounted AnimatedOpacity: subsequent prop changes
          // animate, while AnimatedOpacity skips its very first build.
          child: hasShape
              ? AnimatedOpacity(
                  opacity: showShape ? 1 : 0,
                  duration: fadeDuration,
                  child: _shapeFor(shapeIndex!, stimulusColor),
                )
              : null,
        ),
      ),
    );
  }
}

/// Shared helper: paints shape #[shapeIndex] sized as
/// `kShapeSizeFactor * shape.sizeFactor` so per-shape tweaks compose
/// with the global factor.
Widget _shapeFor(int shapeIndex, Color color) {
  final shape = kShapeBuilders[shapeIndex];
  final factor = kShapeSizeFactor * shape.sizeFactor;
  return FractionallySizedBox(
    widthFactor: factor,
    heightFactor: factor,
    child: shape.builder(color),
  );
}

/// 3×3 grid that renders the active stimulus on one cell:
/// position (which cell), color (cell tint), and shape (icon inside).
/// Channels not listed here are simply omitted from the visual.
class NBackGrid extends StatelessWidget {
  const NBackGrid({
    required this.activeCellIndex,
    required this.highlight,
    required this.colorIndex,
    required this.shapeIndex,
    required this.fadeDuration,
    this.style = GridStyle.tile,
    this.showFixation = true,
    this.centerIsPositionTarget = false,
    super.key,
  });

  /// 0..8 index of the cell to highlight, or null if position channel is off.
  final int? activeCellIndex;

  /// True if the stimulus is currently visible (on its display window).
  final bool highlight;

  /// Index into [NBackDefaults.colorPalette] or null if color channel is off.
  final int? colorIndex;

  /// Index into [kShapeBuilders] or null if shape channel is off.
  final int? shapeIndex;

  /// Fade-in/out duration for the stimulus highlight (cell color +
  /// shape opacity). `Duration.zero` snaps on/off.
  final Duration fadeDuration;

  /// Visual style of the grid (cells vs. solid background).
  final GridStyle style;

  /// Whether the central fixation "+" should be drawn. Hidden during
  /// pre-session states (Play button visible, countdown) so it doesn't
  /// compete with the overlay.
  final bool showFixation;

  /// When true, the center cell is a valid position-channel target —
  /// stops the grid from special-casing it (no transparent shortcut in
  /// tile mode, no exclusion in classic mode's highlight pass).
  final bool centerIsPositionTarget;

  @override
  Widget build(BuildContext context) {
    assert(
      kShapeBuilders.length == NBackDefaults.shapeCount,
      'kShapeBuilders.length (${kShapeBuilders.length}) must match '
      'NBackDefaults.shapeCount (${NBackDefaults.shapeCount}).',
    );
    if (style == GridStyle.classic) {
      return _buildClassic(context);
    }
    return _buildTile(context);
  }

  Widget _buildTile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const size = NBackDefaults.gridSize;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: size * size,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final isActive = highlight && index == activeCellIndex;
            final isCenter = index == kCenterCellIndex;

            // Center cell (when not currently the stimulus and not a
            // valid position target) is transparent — only the fixation
            // "+" is shown, no surrounding box. When the fixation is
            // hidden (pre-session / countdown), the cell renders nothing
            // so it doesn't compete with the overlay. When the center IS
            // a position target we fall through and render it like any
            // other cell so the player can see it as a stimulus slot.
            if (isCenter && !isActive && !centerIsPositionTarget) {
              if (!showFixation) {
                return const SizedBox.shrink();
              }
              return FractionallySizedBox(
                widthFactor: kFixationSizeFactor,
                heightFactor: kFixationSizeFactor,
                child: FittedBox(
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant
                          .withValues(alpha: 0.35),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              );
            }

            final stimulusColor = colorIndex != null
                ? Color(NBackDefaults.colorPalette[colorIndex!])
                : scheme.primary;
            // When the shape channel is on the cell stays neutral —
            // the shape carries the colour. Otherwise the active cell
            // flashes with `stimulusColor`.
            final hasShapeChannel = shapeIndex != null;
            final cellColor = isActive && !hasShapeChannel
                ? stimulusColor
                : scheme.surfaceContainerHighest;
            // Render the shape on every (non-fixation) cell so that
            // AnimatedOpacity stays mounted across trials. Only the cell
            // whose index matches activeCellIndex sets opacity=1; the
            // other cells keep opacity=0 and therefore aren't visible.
            // This is what guarantees a smooth fade-in: AnimatedOpacity
            // doesn't animate on first build, so the widget MUST be
            // mounted continuously.
            final showShapeHere = isActive && hasShapeChannel;
            // Overlay the fixation "+" on the (idle) center tile when
            // the center is a valid position target — without this the
            // tile background would hide the cross that the original
            // early-return path used to draw.
            final showCenterFixation = isCenter &&
                !isActive &&
                centerIsPositionTarget &&
                showFixation;

            Widget? child;
            if (hasShapeChannel) {
              child = AnimatedOpacity(
                opacity: showShapeHere ? 1 : 0,
                duration: fadeDuration,
                child: _shapeFor(shapeIndex!, stimulusColor),
              );
            }
            if (showCenterFixation) {
              final fixation = FractionallySizedBox(
                widthFactor: kFixationSizeFactor,
                heightFactor: kFixationSizeFactor,
                child: FittedBox(
                  child: Text(
                    '+',
                    style: TextStyle(
                      color:
                          scheme.onSurfaceVariant.withValues(alpha: 0.35),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              );
              child = child == null
                  ? fixation
                  : Stack(
                      alignment: Alignment.center,
                      children: [fixation, child],
                    );
            }

            return AnimatedContainer(
              duration: fadeDuration,
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }

  Widget _buildClassic(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stimulusColor = colorIndex != null
        ? Color(NBackDefaults.colorPalette[colorIndex!])
        : scheme.primary;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellW = constraints.maxWidth / NBackDefaults.gridSize;
            final cellH = constraints.maxHeight / NBackDefaults.gridSize;
            const cellPadding = 6.0;
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (showFixation)
                  Positioned(
                    left: cellW,
                    top: cellH,
                    width: cellW,
                    height: cellH,
                    child: Padding(
                      padding: const EdgeInsets.all(cellPadding),
                      child: FittedBox(
                        child: Text(
                          '+',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant
                                .withValues(alpha: 0.35),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Always render the highlight cell (when position channel
                // is on and the active cell isn't the fixation center) so
                // its opacity can animate between trials. Between the
                // stimulus-on windows opacity sits at 0; activeCellIndex
                // updates while invisible, so the position snap to the
                // next trial's cell isn't visible.
                // Always render the highlight cell (when position channel
                // is on and the active cell isn't the fixation center) so
                // its opacity can animate continuously between trials.
                // AnimatedOpacity does NOT animate on its first build —
                // mounting it once and keeping it mounted is what makes
                // fade-in actually fire.
                if (activeCellIndex != null &&
                    (centerIsPositionTarget ||
                        activeCellIndex != kCenterCellIndex))
                  Positioned(
                    left: (activeCellIndex! % NBackDefaults.gridSize) * cellW,
                    top: (activeCellIndex! ~/ NBackDefaults.gridSize) * cellH,
                    width: cellW,
                    height: cellH,
                    child: Padding(
                      padding: const EdgeInsets.all(cellPadding),
                      child: AnimatedOpacity(
                        opacity: highlight ? 1 : 0,
                        duration: fadeDuration,
                        // When the shape channel is on the box stays
                        // transparent regardless of `highlight` — the
                        // shape itself carries the stimulus colour and
                        // the surrounding cell shouldn't flash.
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: shapeIndex != null
                                ? Colors.transparent
                                : stimulusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: shapeIndex != null
                              ? Align(
                                  child: _shapeFor(
                                    shapeIndex!,
                                    stimulusColor,
                                  ),
                                )
                              : const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
