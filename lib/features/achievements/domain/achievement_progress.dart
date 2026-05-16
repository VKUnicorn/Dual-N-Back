import 'package:meta/meta.dart';

/// Output of evaluating one achievement against the user's history.
///
/// `current` and `target` are only set for achievements that show a
/// numerical progress bar (`tracksProgress = true`). For binary
/// achievements they're null and only [earned] matters.
@immutable
class AchievementProgress {
  const AchievementProgress({
    required this.earned,
    this.current,
    this.target,
  });

  /// Earned-without-progress (binary).
  const AchievementProgress.binary({required this.earned})
      : current = null,
        target = null;

  /// Tracked progress with explicit numerator/denominator.
  const AchievementProgress.tracked({
    required this.current,
    required this.target,
  }) : earned = current != null && target != null && current >= target;

  final bool earned;
  final int? current;
  final int? target;

  /// 0..1 fraction filled. Returns 1.0 once earned regardless of `current`
  /// (we don't display "120/100"); 0 when there's no target.
  double get fraction {
    if (earned) return 1;
    if (current == null || target == null || target! <= 0) return 0;
    final f = current! / target!;
    return f.clamp(0.0, 1.0);
  }
}
