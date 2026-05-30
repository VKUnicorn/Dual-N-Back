import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:meta/meta.dart';

/// The preset-scoped subset of [SettingsModel] — every field that belongs
/// to a named preset (grid style, sound, colors, channels, level-N,
/// timings, feedback). The global fields (language, theme, daily goal,
/// notifications) live only on [SettingsModel] and are never carried here.
///
/// A preset stores one of these payloads. The active preset's payload is
/// mirrored into the flat [SettingsModel] consumed by the rest of the app,
/// so consumers never need to know presets exist.
@immutable
class PresetSettings {
  const PresetSettings({
    required this.defaultChannels,
    required this.channelLayout,
    required this.initialN,
    required this.minN,
    required this.maxN,
    required this.trialsPerSession,
    required this.stimulusDurationMs,
    required this.isiMs,
    required this.matchProbability,
    required this.matchProbabilityJitter,
    required this.adaptiveMode,
    required this.advanceThreshold,
    required this.regressThreshold,
    required this.volume,
    required this.audioVoice,
    required this.audioLetters,
    required this.colors,
    required this.gridStyle,
    required this.showFixationCross,
    required this.allowCenterPosition,
    required this.stimulusFadeMs,
    required this.feedbackVisualOnPress,
    required this.feedbackAudioOnPress,
    required this.feedbackVisualOnMiss,
    required this.feedbackAudioOnMiss,
  });

  /// Defaults for a fresh preset — kept in lock-step with
  /// [SettingsModel.defaults] (which delegates its preset-scoped fields
  /// here) so the two never drift.
  factory PresetSettings.defaults() => const PresetSettings(
        defaultChannels: {ChannelType.position, ChannelType.audio},
        channelLayout: SettingsModel.defaultChannelLayout,
        initialN: NBackDefaults.initialN,
        minN: NBackDefaults.minN,
        maxN: NBackDefaults.initialMaxN,
        trialsPerSession: NBackDefaults.trialsPerSession,
        stimulusDurationMs: NBackDefaults.stimulusDurationMs,
        isiMs: NBackDefaults.isiMs,
        matchProbability: NBackDefaults.matchProbability,
        matchProbabilityJitter: NBackDefaults.matchProbabilityJitter,
        adaptiveMode: false,
        advanceThreshold: NBackDefaults.advanceThreshold,
        regressThreshold: NBackDefaults.regressThreshold,
        volume: 1,
        audioVoice: AudioVoice.female,
        audioLetters: NBackDefaults.audioLetters,
        colors: NBackDefaults.colorPalette,
        gridStyle: GridStyle.classic,
        showFixationCross: true,
        allowCenterPosition: false,
        stimulusFadeMs: SettingsModel.defaultStimulusFadeMs,
        feedbackVisualOnPress: true,
        feedbackAudioOnPress: true,
        feedbackVisualOnMiss: true,
        feedbackAudioOnMiss: true,
      );

  /// Extracts the preset-scoped fields from a flat [SettingsModel].
  factory PresetSettings.fromSettings(SettingsModel s) => PresetSettings(
        defaultChannels: s.defaultChannels,
        channelLayout: s.channelLayout,
        initialN: s.initialN,
        minN: s.minN,
        maxN: s.maxN,
        trialsPerSession: s.trialsPerSession,
        stimulusDurationMs: s.stimulusDurationMs,
        isiMs: s.isiMs,
        matchProbability: s.matchProbability,
        matchProbabilityJitter: s.matchProbabilityJitter,
        adaptiveMode: s.adaptiveMode,
        advanceThreshold: s.advanceThreshold,
        regressThreshold: s.regressThreshold,
        volume: s.volume,
        audioVoice: s.audioVoice,
        audioLetters: s.audioLetters,
        colors: s.colors,
        gridStyle: s.gridStyle,
        showFixationCross: s.showFixationCross,
        allowCenterPosition: s.allowCenterPosition,
        stimulusFadeMs: s.stimulusFadeMs,
        feedbackVisualOnPress: s.feedbackVisualOnPress,
        feedbackAudioOnPress: s.feedbackAudioOnPress,
        feedbackVisualOnMiss: s.feedbackVisualOnMiss,
        feedbackAudioOnMiss: s.feedbackAudioOnMiss,
      );

  /// Rebuilds a payload from persisted JSON, replicating the same
  /// validation `SettingsRepository` applies to legacy per-field keys —
  /// any malformed / unknown / out-of-spec value silently falls back to
  /// the matching default, so a corrupt or forward-version payload can
  /// never violate the invariants the app relies on (`colorCount == 8`,
  /// `minAudioLetters`, layout completeness, …).
  factory PresetSettings.fromJson(Map<String, dynamic> json) {
    final d = PresetSettings.defaults();
    return PresetSettings(
      defaultChannels:
          _parseChannels(json['defaultChannels']) ?? d.defaultChannels,
      channelLayout: _parseLayout(json['channelLayout']) ?? d.channelLayout,
      initialN: _asInt(json['initialN']) ?? d.initialN,
      minN: _asInt(json['minN']) ?? d.minN,
      maxN: _asInt(json['maxN']) ?? d.maxN,
      trialsPerSession:
          _asInt(json['trialsPerSession']) ?? d.trialsPerSession,
      stimulusDurationMs:
          _asInt(json['stimulusDurationMs']) ?? d.stimulusDurationMs,
      isiMs: _asInt(json['isiMs']) ?? d.isiMs,
      matchProbability:
          _asDouble(json['matchProbability']) ?? d.matchProbability,
      matchProbabilityJitter: _asDouble(json['matchProbabilityJitter']) ??
          d.matchProbabilityJitter,
      adaptiveMode: _asBool(json['adaptiveMode']) ?? d.adaptiveMode,
      advanceThreshold:
          _asDouble(json['advanceThreshold']) ?? d.advanceThreshold,
      regressThreshold:
          _asDouble(json['regressThreshold']) ?? d.regressThreshold,
      volume: _asDouble(json['volume']) ?? d.volume,
      audioVoice: _parseEnum(AudioVoice.values, json['audioVoice']) ??
          d.audioVoice,
      audioLetters: _parseAudioLetters(json['audioLetters']) ?? d.audioLetters,
      colors: _parseColors(json['colors']) ?? d.colors,
      gridStyle:
          _parseEnum(GridStyle.values, json['gridStyle']) ?? d.gridStyle,
      showFixationCross:
          _asBool(json['showFixationCross']) ?? d.showFixationCross,
      allowCenterPosition:
          _asBool(json['allowCenterPosition']) ?? d.allowCenterPosition,
      stimulusFadeMs: _asInt(json['stimulusFadeMs']) ?? d.stimulusFadeMs,
      feedbackVisualOnPress:
          _asBool(json['feedbackVisualOnPress']) ?? d.feedbackVisualOnPress,
      feedbackAudioOnPress:
          _asBool(json['feedbackAudioOnPress']) ?? d.feedbackAudioOnPress,
      feedbackVisualOnMiss:
          _asBool(json['feedbackVisualOnMiss']) ?? d.feedbackVisualOnMiss,
      feedbackAudioOnMiss:
          _asBool(json['feedbackAudioOnMiss']) ?? d.feedbackAudioOnMiss,
    );
  }

  final Set<ChannelType> defaultChannels;
  final List<ChannelType> channelLayout;
  final int initialN;
  final int minN;
  final int maxN;
  final int trialsPerSession;
  final int stimulusDurationMs;
  final int isiMs;
  final double matchProbability;
  final double matchProbabilityJitter;
  final bool adaptiveMode;
  final double advanceThreshold;
  final double regressThreshold;
  final double volume;
  final AudioVoice audioVoice;
  final List<String> audioLetters;
  final List<int> colors;
  final GridStyle gridStyle;
  final bool showFixationCross;
  final bool allowCenterPosition;
  final int stimulusFadeMs;
  final bool feedbackVisualOnPress;
  final bool feedbackAudioOnPress;
  final bool feedbackVisualOnMiss;
  final bool feedbackAudioOnMiss;

  Map<String, dynamic> toJson() => {
        'defaultChannels': [for (final c in defaultChannels) c.name],
        'channelLayout': [for (final c in channelLayout) c.name],
        'initialN': initialN,
        'minN': minN,
        'maxN': maxN,
        'trialsPerSession': trialsPerSession,
        'stimulusDurationMs': stimulusDurationMs,
        'isiMs': isiMs,
        'matchProbability': matchProbability,
        'matchProbabilityJitter': matchProbabilityJitter,
        'adaptiveMode': adaptiveMode,
        'advanceThreshold': advanceThreshold,
        'regressThreshold': regressThreshold,
        'volume': volume,
        'audioVoice': audioVoice.name,
        'audioLetters': audioLetters,
        // Hex strings — mirrors the legacy per-field encoding so colors
        // round-trip without signed-int / leading-zero quirks.
        'colors': [for (final c in colors) c.toRadixString(16).padLeft(8, '0')],
        'gridStyle': gridStyle.name,
        'showFixationCross': showFixationCross,
        'allowCenterPosition': allowCenterPosition,
        'stimulusFadeMs': stimulusFadeMs,
        'feedbackVisualOnPress': feedbackVisualOnPress,
        'feedbackAudioOnPress': feedbackAudioOnPress,
        'feedbackVisualOnMiss': feedbackVisualOnMiss,
        'feedbackAudioOnMiss': feedbackAudioOnMiss,
      };

  static int? _asInt(Object? v) => v is int ? v : (v is num ? v.toInt() : null);

  static double? _asDouble(Object? v) => v is num ? v.toDouble() : null;

  static bool? _asBool(Object? v) => v is bool ? v : null;

  static T? _parseEnum<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String) return null;
    for (final v in values) {
      if (v.name == raw) return v;
    }
    return null;
  }

  static Set<ChannelType>? _parseChannels(Object? raw) {
    if (raw is! List) return null;
    final out = <ChannelType>{};
    for (final name in raw) {
      final c = _parseEnum(ChannelType.values, name);
      if (c != null) out.add(c);
    }
    return out;
  }

  /// Mirrors `SettingsRepository._loadLayout`: must list every
  /// [ChannelType] exactly once, else fall back to default.
  static List<ChannelType>? _parseLayout(Object? raw) {
    if (raw is! List) return null;
    if (raw.length != ChannelType.values.length) return null;
    final layout = <ChannelType>[];
    for (final name in raw) {
      final c = _parseEnum(ChannelType.values, name);
      if (c == null) return null;
      layout.add(c);
    }
    if (layout.toSet().length != ChannelType.values.length) return null;
    return layout;
  }

  /// Mirrors `SettingsRepository._loadAudioLetters`: keep only valid
  /// letters, reject if below [SettingsModel.minAudioLetters].
  static List<String>? _parseAudioLetters(Object? raw) {
    if (raw is! List) return null;
    final allowed = SettingsModel.availableAudioLetters.toSet();
    final filtered = [
      for (final letter in raw)
        if (letter is String && allowed.contains(letter)) letter,
    ];
    if (filtered.length < SettingsModel.minAudioLetters) return null;
    return filtered;
  }

  /// Mirrors `SettingsRepository._loadColors`: exactly `colorCount` hex
  /// entries, else fall back to the default palette.
  static List<int>? _parseColors(Object? raw) {
    if (raw is! List) return null;
    if (raw.length != SettingsModel.colorCount) return null;
    final out = <int>[];
    for (final entry in raw) {
      if (entry is! String) return null;
      final parsed = int.tryParse(entry, radix: 16);
      if (parsed == null) return null;
      out.add(parsed);
    }
    return out;
  }
}
