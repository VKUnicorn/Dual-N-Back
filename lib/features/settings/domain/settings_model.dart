import 'package:dual_n_back/core/constants/app_theme_mode.dart';
import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:meta/meta.dart';

/// User-configurable settings persisted across app launches.
///
/// All fields have sane defaults derived from [NBackDefaults] (Jaeggi 2008
/// protocol). The settings page is the only place where these are mutated;
/// the game session reads them at start time.
@immutable
class SettingsModel {
  const SettingsModel({
    required this.defaultChannels,
    required this.channelLayout,
    required this.initialN,
    required this.minN,
    required this.maxN,
    required this.trialsPerSession,
    required this.stimulusDurationMs,
    required this.isiMs,
    required this.matchProbability,
    required this.adaptiveMode,
    required this.volume,
    required this.audioVoice,
    required this.audioLetters,
    required this.gridStyle,
    required this.dailyGoalSessions,
    required this.restDays,
    required this.stimulusFadeMs,
    required this.notificationsEnabled,
    required this.notificationTimeMinutes,
    required this.themeMode,
    required this.feedbackVisualOnPress,
    required this.feedbackAudioOnPress,
    required this.feedbackVisualOnMiss,
    required this.feedbackAudioOnMiss,
    this.localeCode,
  });

  /// Sensible defaults — match the Jaeggi protocol.
  factory SettingsModel.defaults() => const SettingsModel(
        defaultChannels: {ChannelType.position, ChannelType.audio},
        channelLayout: defaultChannelLayout,
        initialN: NBackDefaults.initialN,
        minN: NBackDefaults.minN,
        maxN: NBackDefaults.initialMaxN,
        trialsPerSession: NBackDefaults.trialsPerSession,
        stimulusDurationMs: NBackDefaults.stimulusDurationMs,
        isiMs: NBackDefaults.isiMs,
        matchProbability: NBackDefaults.matchProbability,
        adaptiveMode: false,
        volume: 1,
        audioVoice: AudioVoice.female,
        audioLetters: NBackDefaults.audioLetters,
        gridStyle: GridStyle.classic,
        dailyGoalSessions: defaultDailyGoalSessions,
        restDays: <int>{},
        stimulusFadeMs: defaultStimulusFadeMs,
        notificationsEnabled: false,
        notificationTimeMinutes: defaultNotificationTimeMinutes,
        themeMode: AppThemeMode.system,
        feedbackVisualOnPress: true,
        feedbackAudioOnPress: true,
        feedbackVisualOnMiss: true,
        feedbackAudioOnMiss: true,
      );

  /// Bounds and default for the daily-goal slider on the settings screen.
  static const int minDailyGoalSessions = 1;
  static const int maxDailyGoalSessions = 30;
  static const int defaultDailyGoalSessions = 20;

  /// Maximum number of weekdays the user can mark as rest days. Capped at
  /// 6 to keep at least one non-rest day in the streak window — the streak
  /// algorithms rely on this invariant (otherwise the walk-back loop in
  /// `currentStreakProvider` would never terminate).
  static const int maxRestDays = 6;

  /// Bounds and default for the stimulus fade-in/out slider in the
  /// timings section. 0 = instant on/off; values up to 200 ms ease the
  /// snap on slower-feeling perception. Step is 10 ms.
  static const int minStimulusFadeMs = 0;
  static const int maxStimulusFadeMs = 200;
  static const int stimulusFadeStepMs = 10;
  static const int defaultStimulusFadeMs = 50;

  /// Default time-of-day for the "time to train" notification, expressed
  /// as minutes from midnight. 540 = 09:00 — chosen as a workable morning
  /// slot most users can absorb a session into.
  static const int defaultNotificationTimeMinutes = 540;

  /// Minimum number of selected letters required for the audio channel.
  static const int minAudioLetters = 4;

  /// Recommended number of selected letters (Jaeggi protocol).
  static const int recommendedAudioLetters = 8;

  /// All letters that can possibly be selected — the English alphabet,
  /// matching the available recordings under `assets/audio/{voice}/`.
  static const List<String> availableAudioLetters = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
    'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
    's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
  ];

  /// Default 2x2 layout: top-left → top-right → bottom-left → bottom-right.
  static const List<ChannelType> defaultChannelLayout = [
    ChannelType.position,
    ChannelType.audio,
    ChannelType.color,
    ChannelType.shape,
  ];

  /// Channels enabled by default at the start of a new session.
  final Set<ChannelType> defaultChannels;

  /// 2x2 layout of match buttons during a session, indexed
  /// `[topLeft, topRight, bottomLeft, bottomRight]`. Always contains all
  /// 4 [ChannelType] values exactly once; channels not in
  /// [defaultChannels] keep their assigned slot but are hidden in-game.
  final List<ChannelType> channelLayout;

  /// Starting N for a new training arc (also re-used after each session
  /// when adaptive mode is OFF).
  final int initialN;

  /// Lower bound for adaptive-N adjustment.
  final int minN;

  /// Upper bound for adaptive-N adjustment.
  final int maxN;

  /// Scoring trials per session (added on top of `n` warm-up trials).
  final int trialsPerSession;

  /// Stimulus visible duration in milliseconds.
  final int stimulusDurationMs;

  /// Total inter-stimulus interval (display + blank) in milliseconds.
  final int isiMs;

  /// Probability that a given trial is a match on a given channel
  /// (clamped to [0, 1]).
  final double matchProbability;

  /// Whether N auto-adjusts after each session (Jaeggi protocol).
  final bool adaptiveMode;

  /// Sound volume (0.0 — silent, 1.0 — max).
  final double volume;

  /// Voice variant used for letter recordings on the audio channel.
  final AudioVoice audioVoice;

  /// Subset of [availableAudioLetters] currently used as audio stimuli.
  /// Order matters — index into this list is the integer stimulus value
  /// emitted by the generator and consumed by `AudioService.playLetter`.
  /// Always contains at least [minAudioLetters] entries.
  final List<String> audioLetters;

  /// Visual style of the in-game 3x3 grid.
  final GridStyle gridStyle;

  /// Target number of completed sessions per day, shown as a progress
  /// counter on the home screen. Clamped to
  /// [[minDailyGoalSessions], [maxDailyGoalSessions]].
  final int dailyGoalSessions;

  /// Weekdays the user marks as rest. Each entry is `DateTime.weekday`
  /// (Monday = 1 .. Sunday = 7). Rest days are fully transparent in
  /// streak calculations — they neither extend nor break the streak,
  /// regardless of how many sessions were completed that day. Capped at
  /// [maxRestDays] entries.
  final Set<int> restDays;

  /// Duration (in milliseconds) of the visual stimulus fade-in/out on
  /// the game grid. 0 means snap on/off (the legacy behaviour); larger
  /// values smooth the appearance/disappearance. Clamped to
  /// `[minStimulusFadeMs, maxStimulusFadeMs]`.
  final int stimulusFadeMs;

  /// When true, schedule a daily "time to train" local notification.
  /// Rest days ([restDays]) are skipped.
  final bool notificationsEnabled;

  /// Local-time-of-day for the notification, expressed as minutes from
  /// midnight (0..1439). Default is `defaultNotificationTimeMinutes`
  /// (09:00).
  final int notificationTimeMinutes;

  /// App theme preference. Mapped to Flutter's `ThemeMode` in `app.dart`.
  /// Default is [AppThemeMode.system] — follow the OS light/dark setting.
  final AppThemeMode themeMode;

  /// Locale override. `null` means follow system locale.
  final String? localeCode;

  /// When true, the match button briefly flashes green on a correct press
  /// and red on a false-alarm press. Default true.
  final bool feedbackVisualOnPress;

  /// When true, a short SFX is played on every match-button press —
  /// `correct.mp3` on a hit, `incorrect.mp3` on a false alarm.
  /// Default true.
  final bool feedbackAudioOnPress;

  /// When true, the match button of a missed channel briefly flashes
  /// orange when the trial advances. Default true.
  final bool feedbackVisualOnMiss;

  /// When true, `missed.mp3` is played when the trial advances and a
  /// signal was present but no press was made. Default true.
  final bool feedbackAudioOnMiss;

  SettingsModel copyWith({
    Set<ChannelType>? defaultChannels,
    List<ChannelType>? channelLayout,
    int? initialN,
    int? minN,
    int? maxN,
    int? trialsPerSession,
    int? stimulusDurationMs,
    int? isiMs,
    double? matchProbability,
    bool? adaptiveMode,
    double? volume,
    AudioVoice? audioVoice,
    List<String>? audioLetters,
    GridStyle? gridStyle,
    int? dailyGoalSessions,
    Set<int>? restDays,
    int? stimulusFadeMs,
    bool? notificationsEnabled,
    int? notificationTimeMinutes,
    AppThemeMode? themeMode,
    bool? feedbackVisualOnPress,
    bool? feedbackAudioOnPress,
    bool? feedbackVisualOnMiss,
    bool? feedbackAudioOnMiss,
    String? Function()? localeCode,
  }) {
    return SettingsModel(
      defaultChannels: defaultChannels ?? this.defaultChannels,
      channelLayout: channelLayout ?? this.channelLayout,
      initialN: initialN ?? this.initialN,
      minN: minN ?? this.minN,
      maxN: maxN ?? this.maxN,
      trialsPerSession: trialsPerSession ?? this.trialsPerSession,
      stimulusDurationMs: stimulusDurationMs ?? this.stimulusDurationMs,
      isiMs: isiMs ?? this.isiMs,
      matchProbability: matchProbability ?? this.matchProbability,
      adaptiveMode: adaptiveMode ?? this.adaptiveMode,
      volume: volume ?? this.volume,
      audioVoice: audioVoice ?? this.audioVoice,
      audioLetters: audioLetters ?? this.audioLetters,
      gridStyle: gridStyle ?? this.gridStyle,
      dailyGoalSessions: dailyGoalSessions ?? this.dailyGoalSessions,
      restDays: restDays ?? this.restDays,
      stimulusFadeMs: stimulusFadeMs ?? this.stimulusFadeMs,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      notificationTimeMinutes:
          notificationTimeMinutes ?? this.notificationTimeMinutes,
      themeMode: themeMode ?? this.themeMode,
      feedbackVisualOnPress:
          feedbackVisualOnPress ?? this.feedbackVisualOnPress,
      feedbackAudioOnPress:
          feedbackAudioOnPress ?? this.feedbackAudioOnPress,
      feedbackVisualOnMiss:
          feedbackVisualOnMiss ?? this.feedbackVisualOnMiss,
      feedbackAudioOnMiss:
          feedbackAudioOnMiss ?? this.feedbackAudioOnMiss,
      localeCode: localeCode != null ? localeCode() : this.localeCode,
    );
  }
}
