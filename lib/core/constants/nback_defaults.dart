/// Default parameters for N-back sessions, based on Jaeggi et al. (2008).
class NBackDefaults {
  NBackDefaults._();

  /// Initial N value for a new player.
  static const int initialN = 2;

  /// Lower bound for adaptive N.
  static const int minN = 1;

  /// Upper bound for adaptive N
  static const int maxN = 20;

  /// Upper bound for default max N (sane ceiling for working memory).
  static const int initialMaxN = 9;

  /// Number of trials per session, on top of `n` warm-up trials.
  /// Total trials = n + trialsPerSession.
  static const int trialsPerSession = 20;

  /// Stimulus visible duration in milliseconds.
  static const int stimulusDurationMs = 500;

  /// Total inter-stimulus interval (display + blank) in milliseconds.
  static const int isiMs = 2500;

  /// Probability that a given trial is a match on a given channel.
  static const double matchProbability = 0.3;

  /// Threshold to increase N (per-channel min accuracy).
  static const double advanceThreshold = 0.9;

  /// Threshold to decrease N (per-channel min accuracy).
  static const double regressThreshold = 0.7;

  /// Audio letters used as stimuli (Jaeggi protocol).
  static const List<String> audioLetters = ['c', 'h', 'k', 'l', 'q', 'r', 'p', 't'];

  /// Available colors for the color channel.
  static const List<int> colorPalette = [
    0xFFF52F27, // red
    0xFF50DE4E, // green
    0xFF0A88F0, // blue
    0xFFFCAF0A, // orange
    0xFFF7E72D, // yellow
    0xFFBF3AF0, // purple
    0xFFF75CA7, // pink
    0xFF1C1C1C, // black
  ];

  /// Available shapes for the shape channel (count, indexes 0..n-1).
  /// Must match the length of `kShapeIcons` in `grid_widget.dart` —
  /// `NBackGrid.build` asserts this in debug mode.
  static const int shapeCount = 8;

  /// Grid size for the position channel (3x3 = 9 cells).
  static const int gridSize = 3;
}
