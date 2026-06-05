import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart';

/// Direction the N value should move after a session.
enum NAdjustment { advance, hold, regress }

/// Which accuracy figure the adaptive rule judges a session by.
enum AdaptiveCriterion {
  /// Worst per-channel accuracy ([SessionScore.minAccuracy]). The
  /// original Jaeggi et al. (2008) protocol — and the default.
  minAccuracy,

  /// Overall pooled accuracy ([SessionScore.overallAccuracy]) — the
  /// number shown on the result screen.
  overallAccuracy,
}

/// Adaptive-N rule, adapted from Jaeggi et al. (2008):
///
/// - If the chosen accuracy ([criterion]) >= [advanceThreshold] → N + 1
/// - If it is <= [regressThreshold] → max(minN, N - 1)
/// - Otherwise → unchanged
///
/// Both thresholds are inclusive, so accuracy that lands exactly on
/// either rail moves N (or holds at the clamp). The result is clamped
/// to [[minN], [maxN]].
///
/// [criterion] selects between the original Jaeggi *worst per-channel*
/// accuracy (default) and overall (pooled) accuracy. Overall matches the
/// number the user sees on the result screen, so the on-screen value and
/// the adjustment never disagree; min-accuracy is stricter and is the
/// canonical Jaeggi behaviour.
class AdaptiveN {
  const AdaptiveN({
    this.advanceThreshold = NBackDefaults.advanceThreshold,
    this.regressThreshold = NBackDefaults.regressThreshold,
    this.minN = NBackDefaults.minN,
    this.maxN = NBackDefaults.maxN,
    this.criterion = AdaptiveCriterion.minAccuracy,
  });

  final double advanceThreshold;
  final double regressThreshold;
  final int minN;
  final int maxN;
  final AdaptiveCriterion criterion;

  ({int n, NAdjustment adjustment}) next({
    required int currentN,
    required SessionScore score,
  }) {
    final acc = switch (criterion) {
      AdaptiveCriterion.minAccuracy => score.minAccuracy,
      AdaptiveCriterion.overallAccuracy => score.overallAccuracy,
    };
    if (acc >= advanceThreshold && currentN < maxN) {
      return (n: currentN + 1, adjustment: NAdjustment.advance);
    }
    if (acc <= regressThreshold && currentN > minN) {
      return (n: currentN - 1, adjustment: NAdjustment.regress);
    }
    return (n: currentN, adjustment: NAdjustment.hold);
  }
}
