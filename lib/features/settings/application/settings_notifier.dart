import 'package:dual_n_back/core/constants/app_theme_mode.dart';
import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/data/settings_repository.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bound to the actual [SharedPreferences] instance during app
/// initialization in `main.dart`. Tests override this with an in-memory
/// instance via [SharedPreferences.setMockInitialValues].
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsModel>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsModel> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  SettingsModel build() => _repo.load();

  Future<void> updateChannels(Set<ChannelType> channels) async {
    state = state.copyWith(defaultChannels: channels);
    await _repo.save(state);
  }

  Future<void> updateChannelLayout(List<ChannelType> layout) async {
    state = state.copyWith(channelLayout: layout);
    await _repo.save(state);
  }

  Future<void> updateInitialN(int n) async {
    state = state.copyWith(initialN: n);
    await _repo.save(state);
  }

  Future<void> updateNRange(int min, int max) async {
    state = state.copyWith(
      minN: min,
      maxN: max,
      // Clamp initialN inside the new range.
      initialN: state.initialN.clamp(min, max),
    );
    await _repo.save(state);
  }

  Future<void> updateTrialsPerSession(int trials) async {
    state = state.copyWith(trialsPerSession: trials);
    await _repo.save(state);
  }

  Future<void> updateStimulusDuration(int ms) async {
    state = state.copyWith(stimulusDurationMs: ms);
    await _repo.save(state);
  }

  Future<void> updateIsi(int ms) async {
    state = state.copyWith(isiMs: ms);
    await _repo.save(state);
  }

  Future<void> updateMatchProbability(double probability) async {
    state = state.copyWith(matchProbability: probability.clamp(0.0, 1.0));
    await _repo.save(state);
  }

  Future<void> updateMatchProbabilityJitter(double jitter) async {
    state = state.copyWith(
      matchProbabilityJitter: jitter.clamp(0.0, 1.0),
    );
    await _repo.save(state);
  }

  Future<void> updateAdaptiveMode({required bool enabled}) async {
    state = state.copyWith(adaptiveMode: enabled);
    await _repo.save(state);
  }

  /// Updates the per-channel accuracy thresholds used by adaptive mode.
  /// Both values are snapped to [SettingsModel.accuracyThresholdStep]
  /// and clamped to `[minAccuracyThreshold, maxAccuracyThreshold]`. If
  /// the resulting gap shrinks below
  /// [SettingsModel.minAccuracyThresholdGap], [regress] is pushed down
  /// to preserve `regress + minGap <= advance`.
  Future<void> updateAdaptiveThresholds({
    required double regress,
    required double advance,
  }) async {
    const step = SettingsModel.accuracyThresholdStep;
    const lo = SettingsModel.minAccuracyThreshold;
    const hi = SettingsModel.maxAccuracyThreshold;
    const minGap = SettingsModel.minAccuracyThresholdGap;

    double snap(double v) => ((v.clamp(lo, hi) / step).round() * step)
        .clamp(lo, hi);
    final snappedAdvance = snap(advance);
    var snappedRegress = snap(regress);
    if (snappedAdvance - snappedRegress < minGap) {
      snappedRegress = (snappedAdvance - minGap).clamp(lo, hi);
    }
    state = state.copyWith(
      advanceThreshold: snappedAdvance,
      regressThreshold: snappedRegress,
    );
    await _repo.save(state);
  }

  Future<void> updateVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _repo.save(state);
  }

  Future<void> updateAudioVoice(AudioVoice voice) async {
    state = state.copyWith(audioVoice: voice);
    await _repo.save(state);
  }

  /// Replaces a single entry in the custom color palette. [index] must
  /// be in `[0, colorCount)`; [argb] is the 32-bit ARGB value.
  Future<void> updateColor(int index, int argb) async {
    if (index < 0 || index >= SettingsModel.colorCount) return;
    final next = [...state.colors];
    if (next.length != SettingsModel.colorCount) {
      // Defensive: a corrupted persisted list could be shorter; rebuild
      // from defaults before mutating the slot.
      next
        ..clear()
        ..addAll(NBackDefaults.colorPalette);
    }
    next[index] = argb;
    state = state.copyWith(colors: next);
    await _repo.save(state);
  }

  /// Restores the color palette to [NBackDefaults.colorPalette].
  Future<void> resetColors() async {
    state = state.copyWith(colors: NBackDefaults.colorPalette);
    await _repo.save(state);
  }

  /// Replaces the active audio-letter set. Silently rejects updates that
  /// would shrink the selection below [SettingsModel.minAudioLetters].
  Future<void> updateAudioLetters(List<String> letters) async {
    if (letters.length < SettingsModel.minAudioLetters) return;
    final allowed = SettingsModel.availableAudioLetters.toSet();
    final filtered = [
      for (final letter in letters)
        if (allowed.contains(letter)) letter,
    ];
    if (filtered.length < SettingsModel.minAudioLetters) return;
    state = state.copyWith(audioLetters: filtered);
    await _repo.save(state);
  }

  Future<void> updateGridStyle(GridStyle style) async {
    state = state.copyWith(gridStyle: style);
    await _repo.save(state);
  }

  Future<void> updateShowFixationCross({required bool enabled}) async {
    state = state.copyWith(showFixationCross: enabled);
    await _repo.save(state);
  }

  Future<void> updateAllowCenterPosition({required bool enabled}) async {
    state = state.copyWith(allowCenterPosition: enabled);
    await _repo.save(state);
  }

  Future<void> updateDailyGoalSessions(int sessions) async {
    final clamped = sessions.clamp(
      SettingsModel.minDailyGoalSessions,
      SettingsModel.maxDailyGoalSessions,
    );
    state = state.copyWith(dailyGoalSessions: clamped);
    await _repo.save(state);
  }

  /// Replaces the rest-day weekday set. Filters to valid `DateTime.weekday`
  /// values (1..7) and caps at [SettingsModel.maxRestDays]. The cap is
  /// load-bearing: the streak walk-back loop in `currentStreakProvider`
  /// would never terminate if every weekday were a rest day.
  Future<void> updateRestDays(Set<int> days) async {
    final filtered = <int>{
      for (final d in days)
        if (d >= 1 && d <= 7) d,
    };
    final capped = filtered.length > SettingsModel.maxRestDays
        ? filtered.take(SettingsModel.maxRestDays).toSet()
        : filtered;
    state = state.copyWith(restDays: capped);
    await _repo.save(state);
  }

  /// Updates the stimulus fade-in/out duration. Clamped to the allowed
  /// range and snapped to the configured step so the slider only persists
  /// values that match what the UI offers.
  Future<void> updateStimulusFadeMs(int ms) async {
    final clamped = ms.clamp(
      SettingsModel.minStimulusFadeMs,
      SettingsModel.maxStimulusFadeMs,
    );
    const step = SettingsModel.stimulusFadeStepMs;
    final snapped = (clamped / step).round() * step;
    state = state.copyWith(stimulusFadeMs: snapped);
    await _repo.save(state);
  }

  /// Toggles the daily-reminder local notification.
  Future<void> updateNotificationsEnabled({required bool enabled}) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _repo.save(state);
  }

  /// Sets the time-of-day for the daily reminder. [hour] 0..23,
  /// [minute] 0..59 — values outside the range are clamped.
  Future<void> updateNotificationTime({
    required int hour,
    required int minute,
  }) async {
    final h = hour.clamp(0, 23);
    final m = minute.clamp(0, 59);
    state = state.copyWith(notificationTimeMinutes: h * 60 + m);
    await _repo.save(state);
  }

  Future<void> updateLocale(String? localeCode) async {
    state = state.copyWith(localeCode: () => localeCode);
    await _repo.save(state);
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.save(state);
  }

  Future<void> updateFeedbackVisualOnPress({required bool enabled}) async {
    state = state.copyWith(feedbackVisualOnPress: enabled);
    await _repo.save(state);
  }

  Future<void> updateFeedbackAudioOnPress({required bool enabled}) async {
    state = state.copyWith(feedbackAudioOnPress: enabled);
    await _repo.save(state);
  }

  Future<void> updateFeedbackVisualOnMiss({required bool enabled}) async {
    state = state.copyWith(feedbackVisualOnMiss: enabled);
    await _repo.save(state);
  }

  Future<void> updateFeedbackAudioOnMiss({required bool enabled}) async {
    state = state.copyWith(feedbackAudioOnMiss: enabled);
    await _repo.save(state);
  }

  Future<void> resetToDefaults() async {
    state = SettingsModel.defaults();
    await _repo.clear();
  }

  /// Restores only the active audio-letter set to the Jaeggi default.
  Future<void> resetAudioLetters() async {
    state = state.copyWith(audioLetters: NBackDefaults.audioLetters);
    await _repo.save(state);
  }

  /// Restores only the "Level N" group: initial N, N range, match
  /// probability, and adaptive-mode toggle.
  Future<void> resetLevelN() async {
    state = state.copyWith(
      initialN: NBackDefaults.initialN,
      minN: NBackDefaults.minN,
      maxN: NBackDefaults.initialMaxN,
      matchProbability: NBackDefaults.matchProbability,
      matchProbabilityJitter: NBackDefaults.matchProbabilityJitter,
      adaptiveMode: false,
      advanceThreshold: NBackDefaults.advanceThreshold,
      regressThreshold: NBackDefaults.regressThreshold,
    );
    await _repo.save(state);
  }

  /// Restores only the "Timings" group: trials per session, stimulus
  /// duration, stimulus fade, and ISI.
  Future<void> resetTimings() async {
    state = state.copyWith(
      trialsPerSession: NBackDefaults.trialsPerSession,
      stimulusDurationMs: NBackDefaults.stimulusDurationMs,
      stimulusFadeMs: SettingsModel.defaultStimulusFadeMs,
      isiMs: NBackDefaults.isiMs,
    );
    await _repo.save(state);
  }
}
