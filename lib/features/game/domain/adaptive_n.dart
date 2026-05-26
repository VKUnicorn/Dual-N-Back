import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart';

/// Direction the N value should move after a session.
enum NAdjustment { advance, hold, regress }

/// Adaptive-N rule, adapted from Jaeggi et al. (2008):
///
/// - If the session's [SessionScore.overallAccuracy] >= [advanceThreshold]
///   → N + 1
/// - If it is <= [regressThreshold] → max(minN, N - 1)
/// - Otherwise → unchanged
///
/// Both thresholds are inclusive, so accuracy that lands exactly on
/// either rail moves N (or holds at the clamp). The result is clamped
/// to [[minN], [maxN]].
///
/// Note: the original Jaeggi protocol uses the *worst per-channel*
/// accuracy. This implementation deliberately uses overall (pooled)
/// accuracy instead — the number shown on the result screen — so the
/// adjustment the user sees on the result screen always matches the
/// number they were judged on.
class AdaptiveN {
  const AdaptiveN({
    this.advanceThreshold = NBackDefaults.advanceThreshold,
    this.regressThreshold = NBackDefaults.regressThreshold,
    this.minN = NBackDefaults.minN,
    this.maxN = NBackDefaults.maxN,
  });

  final double advanceThreshold;
  final double regressThreshold;
  final int minN;
  final int maxN;

  ({int n, NAdjustment adjustment}) next({
    required int currentN,
    required SessionScore score,
  }) {
    final acc = score.overallAccuracy;
    if (acc >= advanceThreshold && currentN < maxN) {
      return (n: currentN + 1, adjustment: NAdjustment.advance);
    }
    if (acc <= regressThreshold && currentN > minN) {
      return (n: currentN - 1, adjustment: NAdjustment.regress);
    }
    return (n: currentN, adjustment: NAdjustment.hold);
  }
}
