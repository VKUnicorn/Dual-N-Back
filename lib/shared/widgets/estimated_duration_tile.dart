import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Read-only row that shows a wall-clock duration in `Xm Ys` / `Ys`
/// form. Used under the timings sliders in settings (predicted session
/// length) and under the N slider on the start view (so the player sees
/// today's session length as they tweak N).
///
/// Styling is intentionally muted (`onSurfaceVariant`) so the row reads
/// as informational, not as an interactive control like a slider tile.
class EstimatedDurationTile extends StatelessWidget {
  const EstimatedDurationTile({
    required this.ms,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    super.key,
  });

  final int ms;

  /// Outer padding around the row. Defaults to the inset that matches
  /// the surrounding `_SliderTile`s in the settings screen; callers
  /// embedding the tile inside an already-padded column (e.g. the start
  /// view, with its outer 24 px column padding) can pass
  /// `EdgeInsets.zero` to avoid a double-indent.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final totalSec = (ms / 1000).round();
    final mm = totalSec ~/ 60;
    final ss = totalSec % 60;
    final value =
        mm == 0 ? l.settingsSeconds(ss) : l.settingsMinutesSeconds(mm, ss);
    final mutedColor = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l.settingsEstimatedDuration,
            style: theme.textTheme.bodyLarge?.copyWith(color: mutedColor),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: mutedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
