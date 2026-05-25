import 'dart:async';
import 'dart:math';

import 'package:dual_n_back/core/audio/audio_provider.dart';
import 'package:dual_n_back/core/audio/audio_service.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/achievements/application/achievement.dart';
import 'package:dual_n_back/features/achievements/application/achievements_catalog.dart';
import 'package:dual_n_back/features/achievements/data/eval_session_adapter.dart';
import 'package:dual_n_back/features/game/domain/adaptive_n.dart';
import 'package:dual_n_back/features/game/domain/game_session.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/domain/stimulus_generator.dart';
import 'package:dual_n_back/features/game/domain/trial.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configurable side-effects + dependencies, mostly for testability.
class GameNotifierConfig {
  const GameNotifierConfig({
    this.stimulusDuration = const Duration(
      milliseconds: NBackDefaults.stimulusDurationMs,
    ),
    this.trialDuration = const Duration(
      milliseconds: NBackDefaults.isiMs,
    ),
    this.countdownTickDuration = const Duration(seconds: 1),
    this.firstStimulusDelay = const Duration(milliseconds: 500),
    this.matchProbability = NBackDefaults.matchProbability,
    this.trialsPerSession = NBackDefaults.trialsPerSession,
    this.adaptiveN = const AdaptiveN(),
    this.evaluator = const ResponseEvaluator(),
    this.random,
  });

  final Duration stimulusDuration;
  final Duration trialDuration;
  final Duration countdownTickDuration;

  /// Delay between the end of the 3-2-1 countdown and the first stimulus
  /// of the session. Without this delay the first stimulus appears the
  /// same frame the countdown overlay disappears, which feels abrupt
  /// because the user has just seen "1" vanish.
  final Duration firstStimulusDelay;
  final double matchProbability;
  final int trialsPerSession;
  final AdaptiveN adaptiveN;
  final ResponseEvaluator evaluator;
  final Random? random;
}

/// Provider for the game session state.
final gameNotifierProvider =
    NotifierProvider<GameNotifier, GameSession>(GameNotifier.new);

class GameNotifier extends Notifier<GameSession> {
  GameNotifierConfig? _configOverride;

  /// True between [_beginRunning] arming the first-stimulus delay and the
  /// delay timer firing. Used so pause-during-delay → resume re-arms the
  /// delay rather than silently skipping the first stimulus via
  /// [_scheduleNextTrial].
  bool _pendingFirstStimulus = false;
  Timer? _stimulusTimer;
  Timer? _trialTimer;

  /// Per-channel timers that clear the response-feedback flash after
  /// [_feedbackDuration] elapses. Reset on pause / abort / reset.
  final Map<ChannelType, Timer> _feedbackTimers = {};

  /// Duration of the post-press / post-miss button flash.
  static const Duration _feedbackDuration = Duration(milliseconds: 500);

  /// Status to restore when [resume] is called. Set on [pause].
  GameStatus? _resumeTo;

  /// Returns the test override if set, otherwise builds a fresh config
  /// from the current user settings.
  GameNotifierConfig get _config {
    if (_configOverride != null) return _configOverride!;
    // Best-effort read: in tests where settingsProvider isn't overridden
    // the default is used (no exception because Notifier.build won't run).
    try {
      final s = ref.read(settingsProvider);
      return GameNotifierConfig(
        stimulusDuration: Duration(milliseconds: s.stimulusDurationMs),
        trialDuration: Duration(milliseconds: s.isiMs),
        matchProbability: s.matchProbability,
        trialsPerSession: s.trialsPerSession,
        adaptiveN: AdaptiveN(
          minN: s.minN,
          maxN: s.maxN,
          advanceThreshold: s.advanceThreshold,
          regressThreshold: s.regressThreshold,
        ),
      );
    } on Object {
      return const GameNotifierConfig();
    }
  }

  AudioService get _audio => ref.read(audioServiceProvider);

  @override
  GameSession build() {
    ref.onDispose(() {
      _cancelTimers();
      for (final t in _feedbackTimers.values) {
        t.cancel();
      }
      _feedbackTimers.clear();
    });
    // Best-effort preload; missing files are logged and ignored.
    unawaited(_audio.preload());
    return GameSession.idle();
  }

  /// Test-only override of the config. Production code uses settings.
  // ignore: use_setters_to_change_properties
  void overrideConfig(GameNotifierConfig config) {
    _configOverride = config;
  }

  /// Builds the trial list and moves the session into the
  /// [GameStatus.preparing] state — the grid is on screen but stimuli
  /// don't start until [play] is invoked.
  void start({
    required int n,
    required Set<ChannelType> activeChannels,
  }) {
    if (n < 1) {
      throw ArgumentError.value(n, 'n', 'must be >= 1');
    }
    if (activeChannels.isEmpty) {
      throw ArgumentError.value(
        activeChannels,
        'activeChannels',
        'must not be empty',
      );
    }
    _cancelTimers();
    _pendingFirstStimulus = false;

    // Apply current volume setting to the audio service.
    try {
      final volume = ref.read(settingsProvider).volume;
      unawaited(_audio.setVolume(volume));
    } on Object {
      // Settings not available (tests) — keep default volume.
    }

    final generator = StimulusGenerator(random: _config.random);
    final trialCount = n + _config.trialsPerSession;
    final trials = generator.generate(
      n: n,
      trialCount: trialCount,
      activeChannels: activeChannels,
      matchProbability: _config.matchProbability,
      cardinalityOverrides: _channelCardinalityOverrides(),
    );

    state = GameSession(
      status: GameStatus.preparing,
      n: n,
      activeChannels: activeChannels,
      trials: trials,
      currentTrialIndex: 0,
      stimulusVisible: false,
      responses: {for (final c in activeChannels) c: <int>{}},
      lockedChannels: const {},
    );
  }

  /// Triggered by the in-grid Play button. Runs the 3-2-1 countdown
  /// and then begins presenting stimuli. No-op outside [GameStatus.preparing].
  void play() {
    if (state.status != GameStatus.preparing) return;
    unawaited(_audio.playUiSound(UiSound.play));
    _startCountdown(3);
  }

  void _startCountdown(int from) {
    _cancelTimers();
    state = state.copyWith(
      status: GameStatus.countdown,
      countdownValue: from,
    );
    _trialTimer = Timer.periodic(_config.countdownTickDuration, (timer) {
      final current = state.countdownValue;
      if (current == null || state.status != GameStatus.countdown) {
        timer.cancel();
        return;
      }
      if (current > 1) {
        state = state.copyWith(countdownValue: current - 1);
      } else {
        timer.cancel();
        _beginRunning();
      }
    });
  }

  void _beginRunning() {
    final s = state;
    final delay = _config.firstStimulusDelay;
    if (delay <= Duration.zero) {
      _pendingFirstStimulus = false;
      state = s.copyWith(
        status: GameStatus.running,
        stimulusVisible: true,
        clearCountdown: true,
      );
      _playAudioFor(s.trials.first);
      _scheduleStimulusHide();
      _scheduleNextTrial();
      return;
    }
    // Drop the countdown overlay immediately so the grid is on screen
    // (status=running, no stimulus yet), then arm a one-shot timer that
    // fires the first stimulus after [firstStimulusDelay].
    _pendingFirstStimulus = true;
    state = s.copyWith(
      status: GameStatus.running,
      stimulusVisible: false,
      clearCountdown: true,
    );
    _trialTimer = Timer(delay, _fireFirstStimulus);
  }

  void _fireFirstStimulus() {
    if (state.status != GameStatus.running) return;
    _pendingFirstStimulus = false;
    state = state.copyWith(stimulusVisible: true);
    _playAudioFor(state.trials.first);
    _scheduleStimulusHide();
    _scheduleNextTrial();
  }

  /// User pressed the "match" button for [channel] during the current trial.
  /// No-op if not running or already pressed for this channel this trial.
  void registerMatch(ChannelType channel) {
    final s = state;
    if (s.status != GameStatus.running) return;
    if (!s.activeChannels.contains(channel)) return;
    if (s.lockedChannels.contains(channel)) return;
    // Warm-up trials (index < n) have no n-back reference yet, so a press
    // there is neither a hit nor a false alarm — record the press without
    // emitting feedback.
    final isWarmup = s.currentTrialIndex < s.n;

    final updated = {
      for (final entry in s.responses.entries)
        entry.key: {...entry.value},
    };
    updated[channel]!.add(s.currentTrialIndex);

    state = s.copyWith(
      responses: updated,
      lockedChannels: {...s.lockedChannels, channel},
    );

    if (!isWarmup) {
      final wasMatch = s.trials[s.currentTrialIndex].isMatchOn(channel);
      _emitFeedback(
        channel,
        wasMatch ? FeedbackKind.correct : FeedbackKind.incorrect,
      );
    }
  }

  /// Pauses an active session. No-op outside running/countdown.
  /// Cancels timers; the current trial / countdown value is preserved
  /// in state so [resume] can restart from there.
  void pause() {
    final currentStatus = state.status;
    if (currentStatus != GameStatus.running &&
        currentStatus != GameStatus.countdown) {
      return;
    }
    _cancelTimers();
    _clearFeedback();
    _resumeTo = currentStatus;
    // Build the next state off the LIVE [state] so the empty
    // channelFeedback that _clearFeedback just wrote survives — using
    // an earlier snapshot would clobber it with the pre-clear value
    // and the green/red/orange flash would stay stuck through resume.
    state = state.copyWith(
      status: GameStatus.paused,
      stimulusVisible: false,
    );
  }

  /// Resumes a paused session. Restarts countdown from its saved value
  /// or continues the running session from the current trial without
  /// replaying the stimulus that was on screen when the user paused.
  void resume() {
    final s = state;
    if (s.status != GameStatus.paused) return;
    final target = _resumeTo;
    _resumeTo = null;
    if (target == GameStatus.countdown) {
      _startCountdown(s.countdownValue ?? 3);
    } else if (_pendingFirstStimulus) {
      // Pause hit during the post-countdown delay — re-arm the delay so
      // the user actually sees the first stimulus instead of skipping it.
      state = s.copyWith(
        status: GameStatus.running,
        stimulusVisible: false,
      );
      _trialTimer = Timer(_config.firstStimulusDelay, _fireFirstStimulus);
    } else {
      // Don't re-show the stimulus or replay audio — that confuses the user.
      // Just schedule the next-trial timer; the current trial is finished
      // visually and any unanswered match counts as a miss.
      state = s.copyWith(
        status: GameStatus.running,
        stimulusVisible: false,
      );
      _scheduleNextTrial();
    }
  }

  /// Cancels the running session without scoring.
  void abort() {
    _cancelTimers();
    _clearFeedback();
    _resumeTo = null;
    _pendingFirstStimulus = false;
    state = GameSession.idle().copyWith(status: GameStatus.aborted);
  }

  /// Returns to the idle (pre-session) state from any non-running state.
  void reset() {
    _cancelTimers();
    _clearFeedback();
    _resumeTo = null;
    _pendingFirstStimulus = false;
    state = GameSession.idle();
  }

  void _scheduleStimulusHide() {
    _stimulusTimer = Timer(_config.stimulusDuration, () {
      if (state.status != GameStatus.running) return;
      state = state.copyWith(stimulusVisible: false);
    });
  }

  void _scheduleNextTrial() {
    _trialTimer = Timer(_config.trialDuration, _advance);
  }

  void _advance() {
    final s = state;
    if (s.status != GameStatus.running) return;

    // Detect misses on the just-completed trial before advancing.
    // Warm-up trials don't have an n-back reference, so we skip them.
    // Audio plays at most once per advance even if multiple channels
    // missed (the visual orange flash still lands on every missed
    // channel) — a stack of overlapping `missed.mp3` plays sounds messy
    // and adds nothing the user can parse.
    if (s.currentTrialIndex >= s.n) {
      final trial = s.trials[s.currentTrialIndex];
      var playedMissAudio = false;
      for (final channel in s.activeChannels) {
        final pressed =
            s.responses[channel]?.contains(s.currentTrialIndex) ?? false;
        if (trial.isMatchOn(channel) && !pressed) {
          _emitFeedback(
            channel,
            FeedbackKind.missed,
            playAudio: !playedMissAudio,
          );
          playedMissAudio = true;
        }
      }
    }

    final next = s.currentTrialIndex + 1;
    if (next >= s.trials.length) {
      _finish();
      return;
    }

    // Build the next state off the LIVE [state] rather than the snapshot
    // `s` captured before miss detection — otherwise the channelFeedback
    // entries that _emitFeedback just wrote get clobbered here and the
    // orange flash never reaches the UI.
    state = state.copyWith(
      currentTrialIndex: next,
      stimulusVisible: true,
      lockedChannels: const {},
    );
    _playAudioFor(s.trials[next]);
    _scheduleStimulusHide();
    _scheduleNextTrial();
  }

  void _playAudioFor(Trial trial) {
    final s = state;
    if (!s.activeChannels.contains(ChannelType.audio)) return;
    final letter = trial.frame[ChannelType.audio];
    unawaited(_audio.playLetter(letter));
  }

  void _finish() {
    _cancelTimers();
    final s = state;
    final score = _config.evaluator.evaluate(
      trials: s.trials,
      n: s.n,
      responses: s.responses,
    );
    // If adaptive mode is off, keep N as-is.
    final adaptive = _adaptiveModeEnabled();
    final newN = adaptive
        ? _config.adaptiveN.next(currentN: s.n, score: score).n
        : s.n;

    state = s.copyWith(
      status: GameStatus.finished,
      stimulusVisible: false,
      finalScore: score,
      newN: newN,
    );

    unawaited(_evaluateAndPersist(s, score, newN));
  }

  /// End-of-session pipeline:
  /// 1. snapshot history (still without the just-finished session),
  /// 2. evaluate achievements before vs. after to find newly earned ones,
  /// 3. update state with the new ids,
  /// 4. persist the session row.
  ///
  /// Wrapped in a single try/catch so a failure in any step (e.g. DB not
  /// ready in tests) leaves the session in its `finished` state without
  /// crashing the game.
  Future<void> _evaluateAndPersist(
    GameSession s,
    SessionScore score,
    int newN,
  ) async {
    try {
      final repo = ref.read(statisticsRepositoryProvider);
      final now = DateTime.now();

      var newlyEarnedIds = const <String>[];
      try {
        final previous = await repo.loadAll();
        final dailyGoal = _dailyGoal();
        final restDays = _restDays();
        final catalog = buildAchievementsCatalog();

        final synthetic = EvalSessionAdapter.fromCurrent(
          session: s,
          score: score,
          startedAt: now,
        );
        final prevEvals =
            previous.map(EvalSessionAdapter.fromSaved).toList();
        final beforeCtx = EvalContext(
          sessions: prevEvals,
          dailyGoal: dailyGoal,
          restDays: restDays,
          now: now,
        );
        final afterCtx = EvalContext(
          sessions: [synthetic, ...prevEvals],
          dailyGoal: dailyGoal,
          restDays: restDays,
          now: now,
        );
        final before = evaluateAchievements(catalog, beforeCtx);
        final after = evaluateAchievements(catalog, afterCtx);
        newlyEarnedIds = [
          for (final a in catalog)
            if ((after[a.id]?.earned ?? false) &&
                !(before[a.id]?.earned ?? false))
              a.id,
        ];
      } on Object {
        // Achievements are best-effort; never fail persistence on this.
        newlyEarnedIds = const [];
      }

      if (state.status == GameStatus.finished &&
          newlyEarnedIds.isNotEmpty) {
        state = state.copyWith(newlyEarnedAchievements: newlyEarnedIds);
      }

      await repo.saveSession(
        startedAt: now,
        n: s.n,
        newN: newN,
        activeChannels: s.activeChannels,
        totalTrials: s.trials.length,
        stimulusDurationMs: _config.stimulusDuration.inMilliseconds,
        isiMs: _config.trialDuration.inMilliseconds,
        score: score,
      );
    } on Object {
      // Best-effort: in tests where statisticsRepositoryProvider isn't
      // overridden the database isn't available. Don't crash the game.
    }
  }

  int _dailyGoal() {
    try {
      return ref.read(settingsProvider).dailyGoalSessions;
    } on Object {
      return SettingsModel.defaultDailyGoalSessions;
    }
  }

  Set<int> _restDays() {
    try {
      return ref.read(settingsProvider).restDays;
    } on Object {
      return const <int>{};
    }
  }

  /// Per-channel cardinality overrides driven by user settings:
  /// - audio: honour the active letter set (vs. the static Jaeggi default)
  /// - position: 9 cells (incl. center) when `allowCenterPosition` is on,
  ///   otherwise the default of 8 (center excluded) is used.
  ///
  /// Returns an empty map when settings aren't available (tests that
  /// don't override [settingsProvider]) so the generator falls back to
  /// each channel's static [ChannelType.cardinality].
  Map<ChannelType, int> _channelCardinalityOverrides() {
    try {
      final settings = ref.read(settingsProvider);
      final out = <ChannelType, int>{};
      if (settings.audioLetters.isNotEmpty) {
        out[ChannelType.audio] = settings.audioLetters.length;
      }
      if (settings.allowCenterPosition) {
        out[ChannelType.position] =
            NBackDefaults.gridSize * NBackDefaults.gridSize;
      }
      return out;
    } on Object {
      return const {};
    }
  }

  bool _adaptiveModeEnabled() {
    if (_configOverride != null) return true;
    try {
      return ref.read(settingsProvider).adaptiveMode;
    } on Object {
      return true;
    }
  }

  void _cancelTimers() {
    _stimulusTimer?.cancel();
    _stimulusTimer = null;
    _trialTimer?.cancel();
    _trialTimer = null;
  }

  /// Emits a response-feedback event for [channel]. Honours the user's
  /// per-event audio / visual toggles (so a fully-disabled feedback is
  /// a free no-op). Audio side fires-and-forgets; visual side writes
  /// to [GameSession.channelFeedback] and arms a one-shot timer that
  /// clears the entry after [_feedbackDuration].
  void _emitFeedback(
    ChannelType channel,
    FeedbackKind kind, {
    bool playAudio = true,
  }) {
    final settings = _settingsOrNull();
    final isPress =
        kind == FeedbackKind.correct || kind == FeedbackKind.incorrect;
    final audioEnabled = settings != null &&
        (isPress
            ? settings.feedbackAudioOnPress
            : settings.feedbackAudioOnMiss);
    final visualEnabled = settings != null &&
        (isPress
            ? settings.feedbackVisualOnPress
            : settings.feedbackVisualOnMiss);

    if (playAudio && audioEnabled) {
      unawaited(_audio.playFeedback(kind));
    }
    if (!visualEnabled) return;

    final next = Map<ChannelType, FeedbackKind>.from(state.channelFeedback);
    next[channel] = kind;
    state = state.copyWith(channelFeedback: next);

    _feedbackTimers[channel]?.cancel();
    _feedbackTimers[channel] = Timer(_feedbackDuration, () {
      _feedbackTimers.remove(channel);
      final current = state.channelFeedback;
      if (current[channel] != kind) return;
      final cleared = Map<ChannelType, FeedbackKind>.from(current)
        ..remove(channel);
      state = state.copyWith(channelFeedback: cleared);
    });
  }

  /// Cancels every active feedback timer and clears any visible flashes.
  void _clearFeedback() {
    for (final t in _feedbackTimers.values) {
      t.cancel();
    }
    _feedbackTimers.clear();
    if (state.channelFeedback.isNotEmpty) {
      state = state.copyWith(channelFeedback: const {});
    }
  }

  /// Best-effort settings read for the feedback path. Returns null in
  /// test contexts where [settingsProvider] isn't overridden — callers
  /// treat null as "all feedback disabled" so tests using the default
  /// container don't pull SharedPreferences into the test setup.
  SettingsModel? _settingsOrNull() {
    try {
      return ref.read(settingsProvider);
    } on Object {
      return null;
    }
  }
}
