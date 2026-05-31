import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cached set of available achievement asset paths.
///
/// `AssetManifest` is loaded once per app session and filtered down to the
/// `assets/achievements/` folder. While the future is still resolving the
/// widget shows its fallback icon — this matches the no-asset case and
/// avoids a flash of empty space on the first frame.
final achievementAssetsProvider = FutureProvider<Set<String>>((ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest
      .listAssets()
      .where((p) => p.startsWith('assets/achievements/'))
      .toSet();
});

/// Tunable grayscale/dim treatment applied to the colour icon to render the
/// "locked" state at runtime — so a single `{id}.png` covers both states
/// instead of shipping a separate `*_locked.png` (halving the icon assets).
///
/// Builds a 4×5 colour matrix combining:
/// - [saturation]: `0` = full grayscale, `1` = original colour.
/// - [brightness]: RGB multiplier (`<1` dims, `>1` brightens).
/// - [opacity]: alpha multiplier for the whole image.
@immutable
class GrayscaleFilter {
  const GrayscaleFilter({
    this.saturation = 0,
    this.brightness = 1,
    this.opacity = 1,
  });

  /// Default treatment for a locked achievement: fully desaturated and
  /// slightly dimmed so it reads as "not yet earned" without disappearing.
  static const GrayscaleFilter locked =
      GrayscaleFilter(brightness: 0.9, opacity: 0.55);

  final double saturation;
  final double brightness;
  final double opacity;

  /// Rec. 709 luma weights — the standard perceptual grayscale mix.
  static const double _lr = 0.2126;
  static const double _lg = 0.7152;
  static const double _lb = 0.0722;

  ColorFilter toColorFilter() {
    final s = saturation.clamp(0.0, 1.0);
    final b = brightness;
    final inv = 1 - s;
    return ColorFilter.matrix(<double>[
      (_lr * inv + s) * b, (_lg * inv) * b, (_lb * inv) * b, 0, 0, //
      (_lr * inv) * b, (_lg * inv + s) * b, (_lb * inv) * b, 0, 0, //
      (_lr * inv) * b, (_lg * inv) * b, (_lb * inv + s) * b, 0, 0, //
      0, 0, 0, opacity, 0, //
    ]);
  }
}

/// Renders a custom PNG for an achievement when available, falling back to
/// the catalog's [IconData] otherwise.
///
/// Expects a single colour asset `assets/achievements/{id}.png`. The
/// "locked" state is generated at runtime by drawing that same image
/// through a [GrayscaleFilter] ([lockedFilter]) — no separate locked PNG is
/// needed. If the asset is missing the fallback [IconData] is rendered
/// (the caller is expected to pass an already-muted [fallbackColor] for the
/// locked state).
class AchievementIcon extends ConsumerWidget {
  const AchievementIcon({
    required this.id,
    required this.earned,
    required this.size,
    required this.fallbackIcon,
    required this.fallbackColor,
    this.lockedFilter = GrayscaleFilter.locked,
    super.key,
  });

  final String id;
  final bool earned;
  final double size;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final GrayscaleFilter lockedFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(achievementAssetsProvider).asData?.value;
    final path = 'assets/achievements/$id.png';
    if (assets != null && assets.contains(path)) {
      final image = Image.asset(path, width: size, height: size);
      if (earned) return image;
      return ColorFiltered(
        colorFilter: lockedFilter.toColorFilter(),
        child: image,
      );
    }
    return Icon(fallbackIcon, size: size, color: fallbackColor);
  }
}
