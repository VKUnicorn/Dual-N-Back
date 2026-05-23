import 'package:flutter/material.dart';

/// Common accuracy-tier colour used by the sessions-list bubble and the
/// day-mode heatmap tiles. Single source of truth for the thresholds:
///
/// - `accuracy < 0.7`            → red   (`colorScheme.error`)
/// - `0.7 ≤ accuracy ≤ 0.85`     → blue  (`colorScheme.primary`)
/// - `accuracy > 0.85`           → green (Material green 600)
///
/// Material 3's `ColorScheme` has no green slot, so we use a constant
/// rather than overloading `tertiary` (which carries its own semantic
/// role and may be themed to non-green hues by future palette tweaks).
Color accuracyTierColor(ThemeData theme, double accuracy) {
  if (accuracy > 0.85) return _accuracyGreen;
  if (accuracy < 0.7) return theme.colorScheme.error;
  return theme.colorScheme.primary;
}

/// Material green 600 — same hue both light and dark themes can read
/// against the muted backgrounds we use for accuracy chips.
const Color _accuracyGreen = Color(0xFF43A047);
