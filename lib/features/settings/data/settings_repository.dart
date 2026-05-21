import 'package:dual_n_back/core/constants/app_theme_mode.dart';
import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [SettingsModel] in [SharedPreferences].
///
/// Each field gets its own key so that a future migration can drop or
/// reinterpret individual fields without invalidating everything.
/// Missing keys fall back to [SettingsModel.defaults].
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kChannels = 'settings.channels';
  static const _kChannelLayout = 'settings.channelLayout';
  static const _kInitialN = 'settings.initialN';
  static const _kMinN = 'settings.minN';
  static const _kMaxN = 'settings.maxN';
  static const _kTrialsPerSession = 'settings.trialsPerSession';
  static const _kStimulusMs = 'settings.stimulusDurationMs';
  static const _kIsiMs = 'settings.isiMs';
  static const _kMatchProbability = 'settings.matchProbability';
  static const _kAdaptive = 'settings.adaptiveMode';
  static const _kVolume = 'settings.volume';
  static const _kAudioVoice = 'settings.audioVoice';
  static const _kAudioLetters = 'settings.audioLetters';
  static const _kGridStyle = 'settings.gridStyle';
  static const _kShowFixationCross = 'settings.showFixationCross';
  static const _kDailyGoal = 'settings.dailyGoalSessions';
  static const _kRestDays = 'settings.restDays';
  static const _kStimulusFadeMs = 'settings.stimulusFadeMs';
  static const _kNotificationsEnabled = 'settings.notificationsEnabled';
  static const _kNotificationTimeMinutes =
      'settings.notificationTimeMinutes';
  static const _kThemeMode = 'settings.themeMode';
  static const _kLocale = 'settings.localeCode';
  static const _kFeedbackVisualOnPress = 'settings.feedbackVisualOnPress';
  static const _kFeedbackAudioOnPress = 'settings.feedbackAudioOnPress';
  static const _kFeedbackVisualOnMiss = 'settings.feedbackVisualOnMiss';
  static const _kFeedbackAudioOnMiss = 'settings.feedbackAudioOnMiss';

  SettingsModel load() {
    final defaults = SettingsModel.defaults();
    return SettingsModel(
      defaultChannels: _loadChannels() ?? defaults.defaultChannels,
      channelLayout: _loadLayout() ?? defaults.channelLayout,
      initialN: _prefs.getInt(_kInitialN) ?? defaults.initialN,
      minN: _prefs.getInt(_kMinN) ?? defaults.minN,
      maxN: _prefs.getInt(_kMaxN) ?? defaults.maxN,
      trialsPerSession:
          _prefs.getInt(_kTrialsPerSession) ?? defaults.trialsPerSession,
      stimulusDurationMs:
          _prefs.getInt(_kStimulusMs) ?? defaults.stimulusDurationMs,
      isiMs: _prefs.getInt(_kIsiMs) ?? defaults.isiMs,
      matchProbability: _prefs.getDouble(_kMatchProbability) ??
          defaults.matchProbability,
      adaptiveMode: _prefs.getBool(_kAdaptive) ?? defaults.adaptiveMode,
      volume: _prefs.getDouble(_kVolume) ?? defaults.volume,
      audioVoice: _loadAudioVoice() ?? defaults.audioVoice,
      audioLetters: _loadAudioLetters() ?? defaults.audioLetters,
      gridStyle: _loadGridStyle() ?? defaults.gridStyle,
      showFixationCross:
          _prefs.getBool(_kShowFixationCross) ?? defaults.showFixationCross,
      dailyGoalSessions:
          _prefs.getInt(_kDailyGoal) ?? defaults.dailyGoalSessions,
      restDays: _loadRestDays() ?? defaults.restDays,
      stimulusFadeMs:
          _prefs.getInt(_kStimulusFadeMs) ?? defaults.stimulusFadeMs,
      notificationsEnabled: _prefs.getBool(_kNotificationsEnabled) ??
          defaults.notificationsEnabled,
      notificationTimeMinutes: _prefs.getInt(_kNotificationTimeMinutes) ??
          defaults.notificationTimeMinutes,
      themeMode: _loadThemeMode() ?? defaults.themeMode,
      feedbackVisualOnPress: _prefs.getBool(_kFeedbackVisualOnPress) ??
          defaults.feedbackVisualOnPress,
      feedbackAudioOnPress: _prefs.getBool(_kFeedbackAudioOnPress) ??
          defaults.feedbackAudioOnPress,
      feedbackVisualOnMiss: _prefs.getBool(_kFeedbackVisualOnMiss) ??
          defaults.feedbackVisualOnMiss,
      feedbackAudioOnMiss: _prefs.getBool(_kFeedbackAudioOnMiss) ??
          defaults.feedbackAudioOnMiss,
      localeCode: _prefs.getString(_kLocale),
    );
  }

  Future<void> save(SettingsModel model) async {
    await Future.wait([
      _prefs.setStringList(
        _kChannels,
        model.defaultChannels.map((c) => c.name).toList(),
      ),
      _prefs.setStringList(
        _kChannelLayout,
        model.channelLayout.map((c) => c.name).toList(),
      ),
      _prefs.setInt(_kInitialN, model.initialN),
      _prefs.setInt(_kMinN, model.minN),
      _prefs.setInt(_kMaxN, model.maxN),
      _prefs.setInt(_kTrialsPerSession, model.trialsPerSession),
      _prefs.setInt(_kStimulusMs, model.stimulusDurationMs),
      _prefs.setInt(_kIsiMs, model.isiMs),
      _prefs.setDouble(_kMatchProbability, model.matchProbability),
      _prefs.setBool(_kAdaptive, model.adaptiveMode),
      _prefs.setDouble(_kVolume, model.volume),
      _prefs.setString(_kAudioVoice, model.audioVoice.name),
      _prefs.setStringList(_kAudioLetters, model.audioLetters),
      _prefs.setString(_kGridStyle, model.gridStyle.name),
      _prefs.setBool(_kShowFixationCross, model.showFixationCross),
      _prefs.setInt(_kDailyGoal, model.dailyGoalSessions),
      _prefs.setStringList(
        _kRestDays,
        model.restDays.map((d) => d.toString()).toList(),
      ),
      _prefs.setInt(_kStimulusFadeMs, model.stimulusFadeMs),
      _prefs.setBool(
        _kNotificationsEnabled,
        model.notificationsEnabled,
      ),
      _prefs.setInt(
        _kNotificationTimeMinutes,
        model.notificationTimeMinutes,
      ),
      _prefs.setString(_kThemeMode, model.themeMode.name),
      _prefs.setBool(_kFeedbackVisualOnPress, model.feedbackVisualOnPress),
      _prefs.setBool(_kFeedbackAudioOnPress, model.feedbackAudioOnPress),
      _prefs.setBool(_kFeedbackVisualOnMiss, model.feedbackVisualOnMiss),
      _prefs.setBool(_kFeedbackAudioOnMiss, model.feedbackAudioOnMiss),
      if (model.localeCode != null)
        _prefs.setString(_kLocale, model.localeCode!)
      else
        _prefs.remove(_kLocale),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _prefs.remove(_kChannels),
      _prefs.remove(_kChannelLayout),
      _prefs.remove(_kInitialN),
      _prefs.remove(_kMinN),
      _prefs.remove(_kMaxN),
      _prefs.remove(_kTrialsPerSession),
      _prefs.remove(_kStimulusMs),
      _prefs.remove(_kIsiMs),
      _prefs.remove(_kMatchProbability),
      _prefs.remove(_kAdaptive),
      _prefs.remove(_kVolume),
      _prefs.remove(_kAudioVoice),
      _prefs.remove(_kAudioLetters),
      _prefs.remove(_kGridStyle),
      _prefs.remove(_kShowFixationCross),
      _prefs.remove(_kDailyGoal),
      _prefs.remove(_kRestDays),
      _prefs.remove(_kStimulusFadeMs),
      _prefs.remove(_kNotificationsEnabled),
      _prefs.remove(_kNotificationTimeMinutes),
      _prefs.remove(_kThemeMode),
      _prefs.remove(_kFeedbackVisualOnPress),
      _prefs.remove(_kFeedbackAudioOnPress),
      _prefs.remove(_kFeedbackVisualOnMiss),
      _prefs.remove(_kFeedbackAudioOnMiss),
      _prefs.remove(_kLocale),
    ]);
  }

  Set<ChannelType>? _loadChannels() {
    final names = _prefs.getStringList(_kChannels);
    if (names == null) return null;
    final channels = <ChannelType>{};
    for (final name in names) {
      for (final c in ChannelType.values) {
        if (c.name == name) {
          channels.add(c);
          break;
        }
      }
    }
    return channels;
  }

  /// Loads the persisted channel layout. Returns null (→ caller falls back
  /// to defaults) if the stored value is missing, malformed, or doesn't
  /// list every [ChannelType] exactly once.
  List<ChannelType>? _loadLayout() {
    final names = _prefs.getStringList(_kChannelLayout);
    if (names == null) return null;
    if (names.length != ChannelType.values.length) return null;
    final layout = <ChannelType>[];
    for (final name in names) {
      ChannelType? match;
      for (final c in ChannelType.values) {
        if (c.name == name) {
          match = c;
          break;
        }
      }
      if (match == null) return null;
      layout.add(match);
    }
    if (layout.toSet().length != ChannelType.values.length) return null;
    return layout;
  }

  GridStyle? _loadGridStyle() {
    final name = _prefs.getString(_kGridStyle);
    if (name == null) return null;
    for (final style in GridStyle.values) {
      if (style.name == name) return style;
    }
    return null;
  }

  /// Loads the persisted audio-letter selection. Returns null if missing
  /// or below the configured minimum (so the caller falls back to defaults
  /// rather than locking the user into an unusable game state).
  List<String>? _loadAudioLetters() {
    final stored = _prefs.getStringList(_kAudioLetters);
    if (stored == null) return null;
    final allowed = SettingsModel.availableAudioLetters.toSet();
    final filtered = [
      for (final letter in stored)
        if (allowed.contains(letter)) letter,
    ];
    if (filtered.length < SettingsModel.minAudioLetters) return null;
    return filtered;
  }

  /// Loads the persisted rest-day weekday set. Filters to ints in
  /// `[1, 7]` (`DateTime.weekday` range). Returns null only when the key
  /// is absent so the caller falls back to defaults; an explicitly empty
  /// stored list resolves to an empty set (the user opted out of all
  /// rest days).
  Set<int>? _loadRestDays() {
    final stored = _prefs.getStringList(_kRestDays);
    if (stored == null) return null;
    final out = <int>{};
    for (final raw in stored) {
      final n = int.tryParse(raw);
      if (n != null && n >= 1 && n <= 7) out.add(n);
    }
    return out;
  }

  AudioVoice? _loadAudioVoice() {
    final name = _prefs.getString(_kAudioVoice);
    if (name == null) return null;
    for (final voice in AudioVoice.values) {
      if (voice.name == name) return voice;
    }
    return null;
  }

  AppThemeMode? _loadThemeMode() {
    final name = _prefs.getString(_kThemeMode);
    if (name == null) return null;
    for (final mode in AppThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}
