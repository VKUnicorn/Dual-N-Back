import 'dart:async';

import 'package:dual_n_back/core/constants/app_theme_mode.dart';
import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/data/settings_repository.dart';
import 'package:dual_n_back/features/settings/domain/preset.dart';
import 'package:dual_n_back/features/settings/domain/preset_settings.dart';
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

  /// Ordered source of truth for presets. The active preset's payload is
  /// mirrored into the flat [state] (which the rest of the app reads).
  final List<Preset> _presets = [];

  @override
  SettingsModel build() {
    // Globals (and, for legacy users, the seed for the default preset)
    // come from the legacy per-field keys.
    final legacy = _repo.load();
    final loaded = _repo.loadPresets();

    _presets.clear();
    if (loaded == null) {
      // First launch on this build (or pre-presets install): seed a
      // Default preset from whatever the legacy per-field settings held.
      _presets.add(Preset.defaultPreset(PresetSettings.fromSettings(legacy)));
      unawaited(_repo.savePresets(_presets));
      unawaited(_repo.saveActivePresetId(Preset.defaultPresetId));
    } else {
      _presets.addAll(loaded);
    }

    var activeId = _repo.loadActivePresetId();
    if (!_presets.any((p) => p.id == activeId)) {
      activeId = Preset.defaultPresetId;
    }
    final activePayload = _presets
        .firstWhere(
          (p) => p.id == activeId,
          orElse: () => _presets.first,
        )
        .settings;

    return legacy.applyPreset(activePayload).copyWith(
          presets: _refs(),
          activePresetId: activeId,
        );
  }

  List<PresetRef> _refs() =>
      [for (final p in _presets) PresetRef(id: p.id, name: p.name)];

  /// Mirrors the just-mutated preset-scoped [next] back into the active
  /// preset payload and persists the preset list. Used by every
  /// preset-scoped update method.
  Future<void> _commitScoped(SettingsModel next) async {
    final idx = _presets.indexWhere((p) => p.id == next.activePresetId);
    if (idx >= 0) {
      _presets[idx] =
          _presets[idx].copyWith(settings: PresetSettings.fromSettings(next));
    }
    state = next;
    await _repo.savePresets(_presets);
  }

  // ---- Preset management ----

  /// Switches the active preset, mirroring its payload into [state].
  Future<void> selectPreset(String id) async {
    final preset = _presets.firstWhere(
      (p) => p.id == id,
      orElse: () => _presets.first,
    );
    state = state
        .applyPreset(preset.settings)
        .copyWith(activePresetId: preset.id);
    await _repo.saveActivePresetId(preset.id);
  }

  /// Creates a new preset copying the *current* active preset's settings,
  /// then makes it active. [name] is trimmed; empty names are rejected.
  Future<void> createPreset(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final id = Preset.generateId(_presets.map((p) => p.id));
    _presets.add(
      Preset(id: id, name: trimmed, settings: PresetSettings.fromSettings(state)),
    );
    state = state.copyWith(presets: _refs(), activePresetId: id);
    await _repo.savePresets(_presets);
    await _repo.saveActivePresetId(id);
  }

  /// Renames a preset. The default preset cannot be renamed.
  Future<void> renamePreset(String id, String name) async {
    if (id == Preset.defaultPresetId) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final idx = _presets.indexWhere((p) => p.id == id);
    if (idx < 0) return;
    _presets[idx] = _presets[idx].copyWith(name: trimmed);
    state = state.copyWith(presets: _refs());
    await _repo.savePresets(_presets);
  }

  /// Deletes a preset. The default preset cannot be deleted. If the active
  /// preset is removed, falls back to the default preset.
  Future<void> deletePreset(String id) async {
    if (id == Preset.defaultPresetId) return;
    final idx = _presets.indexWhere((p) => p.id == id);
    if (idx < 0) return;
    _presets.removeAt(idx);
    if (state.activePresetId == id) {
      final def = _presets.firstWhere((p) => p.isDefault);
      state = state.applyPreset(def.settings).copyWith(
            presets: _refs(),
            activePresetId: def.id,
          );
      await _repo.saveActivePresetId(def.id);
    } else {
      state = state.copyWith(presets: _refs());
    }
    await _repo.savePresets(_presets);
  }

  Future<void> updateChannels(Set<ChannelType> channels) async {
    await _commitScoped(state.copyWith(defaultChannels: channels));
  }

  Future<void> updateChannelLayout(List<ChannelType> layout) async {
    await _commitScoped(state.copyWith(channelLayout: layout));
  }

  Future<void> updateInitialN(int n) async {
    await _commitScoped(state.copyWith(initialN: n));
  }

  Future<void> updateNRange(int min, int max) async {
    await _commitScoped(
      state.copyWith(
        minN: min,
        maxN: max,
        // Clamp initialN inside the new range.
        initialN: state.initialN.clamp(min, max),
      ),
    );
  }

  Future<void> updateTrialsPerSession(int trials) async {
    await _commitScoped(state.copyWith(trialsPerSession: trials));
  }

  Future<void> updateStimulusDuration(int ms) async {
    await _commitScoped(state.copyWith(stimulusDurationMs: ms));
  }

  Future<void> updateIsi(int ms) async {
    await _commitScoped(state.copyWith(isiMs: ms));
  }

  Future<void> updateMatchProbability(double probability) async {
    await _commitScoped(
      state.copyWith(matchProbability: probability.clamp(0.0, 1.0)),
    );
  }

  Future<void> updateMatchProbabilityJitter(double jitter) async {
    await _commitScoped(
      state.copyWith(matchProbabilityJitter: jitter.clamp(0.0, 1.0)),
    );
  }

  Future<void> updateAdaptiveMode({required bool enabled}) async {
    await _commitScoped(state.copyWith(adaptiveMode: enabled));
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
    await _commitScoped(
      state.copyWith(
        advanceThreshold: snappedAdvance,
        regressThreshold: snappedRegress,
      ),
    );
  }

  Future<void> updateVolume(double volume) async {
    await _commitScoped(state.copyWith(volume: volume));
  }

  Future<void> updateAudioVoice(AudioVoice voice) async {
    await _commitScoped(state.copyWith(audioVoice: voice));
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
    await _commitScoped(state.copyWith(colors: next));
  }

  /// Restores the color palette to [NBackDefaults.colorPalette].
  Future<void> resetColors() async {
    await _commitScoped(state.copyWith(colors: NBackDefaults.colorPalette));
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
    await _commitScoped(state.copyWith(audioLetters: filtered));
  }

  Future<void> updateGridStyle(GridStyle style) async {
    await _commitScoped(state.copyWith(gridStyle: style));
  }

  Future<void> updateShowFixationCross({required bool enabled}) async {
    await _commitScoped(state.copyWith(showFixationCross: enabled));
  }

  Future<void> updateAllowCenterPosition({required bool enabled}) async {
    await _commitScoped(state.copyWith(allowCenterPosition: enabled));
  }

  Future<void> updateDailyGoalSessions(int sessions) async {
    final clamped = sessions.clamp(
      SettingsModel.minDailyGoalSessions,
      SettingsModel.maxDailyGoalSessions,
    );
    state = state.copyWith(dailyGoalSessions: clamped);
    await _repo.saveGlobals(state);
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
    await _repo.saveGlobals(state);
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
    await _commitScoped(state.copyWith(stimulusFadeMs: snapped));
  }

  /// Toggles the daily-reminder local notification.
  Future<void> updateNotificationsEnabled({required bool enabled}) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _repo.saveGlobals(state);
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
    await _repo.saveGlobals(state);
  }

  Future<void> updateLocale(String? localeCode) async {
    state = state.copyWith(localeCode: () => localeCode);
    await _repo.saveGlobals(state);
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.saveGlobals(state);
  }

  Future<void> updateFeedbackVisualOnPress({required bool enabled}) async {
    await _commitScoped(state.copyWith(feedbackVisualOnPress: enabled));
  }

  Future<void> updateFeedbackAudioOnPress({required bool enabled}) async {
    await _commitScoped(state.copyWith(feedbackAudioOnPress: enabled));
  }

  Future<void> updateFeedbackVisualOnMiss({required bool enabled}) async {
    await _commitScoped(state.copyWith(feedbackVisualOnMiss: enabled));
  }

  Future<void> updateFeedbackAudioOnMiss({required bool enabled}) async {
    await _commitScoped(state.copyWith(feedbackAudioOnMiss: enabled));
  }

  /// Resets the *active* preset's scoped settings to defaults AND the
  /// global settings to defaults. Other presets are left untouched.
  Future<void> resetToDefaults() async {
    final idx = _presets.indexWhere((p) => p.id == state.activePresetId);
    if (idx >= 0) {
      _presets[idx] = _presets[idx].copyWith(settings: PresetSettings.defaults());
    }
    final defaults = SettingsModel.defaults();
    state = state.applyPreset(PresetSettings.defaults()).copyWith(
          dailyGoalSessions: defaults.dailyGoalSessions,
          restDays: defaults.restDays,
          notificationsEnabled: defaults.notificationsEnabled,
          notificationTimeMinutes: defaults.notificationTimeMinutes,
          themeMode: defaults.themeMode,
          localeCode: () => defaults.localeCode,
        );
    await _repo.savePresets(_presets);
    await _repo.saveGlobals(state);
  }

  /// Restores only the active audio-letter set to the Jaeggi default.
  Future<void> resetAudioLetters() async {
    await _commitScoped(state.copyWith(audioLetters: NBackDefaults.audioLetters));
  }

  /// Restores only the "Level N" group: initial N, N range, match
  /// probability, and adaptive-mode toggle.
  Future<void> resetLevelN() async {
    await _commitScoped(
      state.copyWith(
        initialN: NBackDefaults.initialN,
        minN: NBackDefaults.minN,
        maxN: NBackDefaults.initialMaxN,
        matchProbability: NBackDefaults.matchProbability,
        matchProbabilityJitter: NBackDefaults.matchProbabilityJitter,
        adaptiveMode: false,
        advanceThreshold: NBackDefaults.advanceThreshold,
        regressThreshold: NBackDefaults.regressThreshold,
      ),
    );
  }

  /// Restores only the "Timings" group: trials per session, stimulus
  /// duration, stimulus fade, and ISI.
  Future<void> resetTimings() async {
    await _commitScoped(
      state.copyWith(
        trialsPerSession: NBackDefaults.trialsPerSession,
        stimulusDurationMs: NBackDefaults.stimulusDurationMs,
        stimulusFadeMs: SettingsModel.defaultStimulusFadeMs,
        isiMs: NBackDefaults.isiMs,
      ),
    );
  }
}
