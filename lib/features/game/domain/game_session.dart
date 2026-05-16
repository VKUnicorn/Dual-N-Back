import 'package:dual_n_back/features/game/domain/response_evaluator.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/domain/trial.dart';
import 'package:meta/meta.dart';

/// High-level session lifecycle.
///
/// `preparing` — trials are built and the grid is on screen but the
/// session hasn't started yet (we're waiting for the user to hit Play).
/// `countdown` — Play has been pressed and a 3-2-1 countdown is running.
/// `running` — stimuli are being presented.
/// `paused` — user paused mid-session; timers cancelled, dialog shown.
enum GameStatus {
  idle,
  preparing,
  countdown,
  running,
  paused,
  finished,
  aborted,
}

/// Immutable state of a single N-back session.
@immutable
class GameSession {
  const GameSession({
    required this.status,
    required this.n,
    required this.activeChannels,
    required this.trials,
    required this.currentTrialIndex,
    required this.stimulusVisible,
    required this.responses,
    required this.lockedChannels,
    this.countdownValue,
    this.finalScore,
    this.newN,
    this.newlyEarnedAchievements = const [],
  });

  /// Initial state before any session has been started.
  factory GameSession.idle() => const GameSession(
        status: GameStatus.idle,
        n: 0,
        activeChannels: {},
        trials: [],
        currentTrialIndex: 0,
        stimulusVisible: false,
        responses: {},
        lockedChannels: {},
      );

  final GameStatus status;
  final int n;
  final Set<ChannelType> activeChannels;
  final List<Trial> trials;

  /// Index of the trial currently being presented.
  /// Valid only when [status] is [GameStatus.running].
  final int currentTrialIndex;

  /// True while the stimulus is on screen (first part of each trial).
  final bool stimulusVisible;

  /// Per-channel set of trial indices for which the user pressed "match".
  final Map<ChannelType, Set<int>> responses;

  /// Channels for which the user has already responded on the current trial.
  /// Cleared at the start of each new trial.
  final Set<ChannelType> lockedChannels;

  /// Active countdown value (3, 2, 1) while [status] is
  /// [GameStatus.countdown]; null otherwise.
  final int? countdownValue;

  /// Final per-channel score, available once [status] is [GameStatus.finished].
  final SessionScore? finalScore;

  /// New recommended N after the session, available with [finalScore].
  final int? newN;

  /// Achievement ids unlocked by completing this session. Populated
  /// asynchronously after [GameStatus.finished] by the achievements
  /// pipeline; defaults to empty when no achievements were newly earned
  /// (or while evaluation is still pending). The result screen displays
  /// this as a "newly earned" strip.
  final List<String> newlyEarnedAchievements;

  Trial? get currentTrial =>
      status == GameStatus.running && currentTrialIndex < trials.length
          ? trials[currentTrialIndex]
          : null;

  int get totalTrials => trials.length;

  /// 1-based number of the current trial for display.
  /// Returns 0 outside an active session (idle / preparing / countdown /
  /// finished / aborted).
  int get displayedTrialNumber {
    if (status == GameStatus.running || status == GameStatus.paused) {
      return currentTrialIndex + 1;
    }
    return 0;
  }

  GameSession copyWith({
    GameStatus? status,
    int? n,
    Set<ChannelType>? activeChannels,
    List<Trial>? trials,
    int? currentTrialIndex,
    bool? stimulusVisible,
    Map<ChannelType, Set<int>>? responses,
    Set<ChannelType>? lockedChannels,
    int? countdownValue,
    bool clearCountdown = false,
    SessionScore? finalScore,
    int? newN,
    List<String>? newlyEarnedAchievements,
  }) {
    return GameSession(
      status: status ?? this.status,
      n: n ?? this.n,
      activeChannels: activeChannels ?? this.activeChannels,
      trials: trials ?? this.trials,
      currentTrialIndex: currentTrialIndex ?? this.currentTrialIndex,
      stimulusVisible: stimulusVisible ?? this.stimulusVisible,
      responses: responses ?? this.responses,
      lockedChannels: lockedChannels ?? this.lockedChannels,
      countdownValue:
          clearCountdown ? null : (countdownValue ?? this.countdownValue),
      finalScore: finalScore ?? this.finalScore,
      newN: newN ?? this.newN,
      newlyEarnedAchievements:
          newlyEarnedAchievements ?? this.newlyEarnedAchievements,
    );
  }
}
