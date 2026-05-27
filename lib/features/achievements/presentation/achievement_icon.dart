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

/// Renders a custom PNG for an achievement when available, falling back to
/// the catalog's [IconData] otherwise.
///
/// Expects `assets/achievements/{id}_locked.png` and
/// `assets/achievements/{id}_unlocked.png`. Either or both may be missing —
/// the corresponding state simply renders the fallback icon.
class AchievementIcon extends ConsumerWidget {
  const AchievementIcon({
    required this.id,
    required this.earned,
    required this.size,
    required this.fallbackIcon,
    required this.fallbackColor,
    super.key,
  });

  final String id;
  final bool earned;
  final double size;
  final IconData fallbackIcon;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(achievementAssetsProvider).asData?.value;
    final path =
        'assets/achievements/${id}_${earned ? 'unlocked' : 'locked'}.png';
    if (assets != null && assets.contains(path)) {
      return Image.asset(path, width: size, height: size);
    }
    return Icon(fallbackIcon, size: size, color: fallbackColor);
  }
}
