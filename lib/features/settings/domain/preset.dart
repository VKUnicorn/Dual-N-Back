import 'dart:math';

import 'package:dual_n_back/features/settings/domain/preset_settings.dart';
import 'package:meta/meta.dart';

/// A named bundle of preset-scoped settings ([PresetSettings]) plus an
/// identity (stable [id]) and a user-facing [name].
///
/// The preset with id [defaultPresetId] is special: it always exists, can
/// never be renamed or deleted, and its display name is resolved from
/// localization (`l.presetDefaultName`) rather than [name] (which is empty
/// for it). User-created presets carry their literal [name].
@immutable
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.settings,
  });

  factory Preset.fromJson(Map<String, dynamic> json) => Preset(
        id: json['id'] as String? ?? defaultPresetId,
        name: json['name'] as String? ?? '',
        settings: PresetSettings.fromJson(
          (json['settings'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{},
        ),
      );

  /// Builds the always-present default preset from default settings.
  factory Preset.defaultPreset([PresetSettings? settings]) => Preset(
        id: defaultPresetId,
        name: '',
        settings: settings ?? PresetSettings.defaults(),
      );

  /// Reserved id of the non-deletable, non-renamable default preset.
  static const String defaultPresetId = 'default';

  /// Generates a unique id not already present in [existing]. Uses a
  /// timestamp plus a random suffix so rapid successive creates can't
  /// collide; loops on the (astronomically unlikely) clash.
  static String generateId(Iterable<String> existing) {
    final taken = existing.toSet();
    final rng = Random();
    while (true) {
      final id =
          'p_${DateTime.now().microsecondsSinceEpoch}_${rng.nextInt(1 << 30)}';
      if (id != defaultPresetId && !taken.contains(id)) return id;
    }
  }

  final String id;
  final String name;
  final PresetSettings settings;

  bool get isDefault => id == defaultPresetId;

  Preset copyWith({String? name, PresetSettings? settings}) => Preset(
        id: id,
        name: name ?? this.name,
        settings: settings ?? this.settings,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'settings': settings.toJson(),
      };
}

/// Lightweight (id + name) view of a preset, carried on `SettingsModel`
/// for the selector UI. Kept small so copying it on every settings change
/// stays cheap. Value equality so list diffing / model equality behaves.
@immutable
class PresetRef {
  const PresetRef({required this.id, required this.name});

  final String id;
  final String name;

  bool get isDefault => id == Preset.defaultPresetId;

  @override
  bool operator ==(Object other) =>
      other is PresetRef && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
