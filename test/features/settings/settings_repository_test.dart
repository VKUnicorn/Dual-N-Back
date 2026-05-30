import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/data/settings_repository.dart';
import 'package:dual_n_back/features/settings/domain/preset.dart';
import 'package:dual_n_back/features/settings/domain/preset_settings.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsRepository> _repo([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return SettingsRepository(prefs);
}

void main() {
  group('SettingsRepository', () {
    test('returns defaults when no values are stored', () async {
      final repo = await _repo();
      final model = repo.load();
      final defaults = SettingsModel.defaults();

      expect(model.defaultChannels, defaults.defaultChannels);
      expect(model.initialN, defaults.initialN);
      expect(model.minN, defaults.minN);
      expect(model.maxN, defaults.maxN);
      expect(model.trialsPerSession, defaults.trialsPerSession);
      expect(model.stimulusDurationMs, defaults.stimulusDurationMs);
      expect(model.isiMs, defaults.isiMs);
      expect(model.adaptiveMode, defaults.adaptiveMode);
    });

    test('round-trips a saved model', () async {
      final repo = await _repo();
      final model = SettingsModel.defaults().copyWith(
        defaultChannels: {ChannelType.position, ChannelType.shape},
        initialN: 4,
        minN: 2,
        maxN: 7,
        trialsPerSession: 30,
        stimulusDurationMs: 600,
        isiMs: 3000,
        adaptiveMode: false,
      );
      await repo.save(model);

      final loaded = repo.load();
      expect(loaded.defaultChannels, model.defaultChannels);
      expect(loaded.initialN, model.initialN);
      expect(loaded.minN, model.minN);
      expect(loaded.maxN, model.maxN);
      expect(loaded.trialsPerSession, model.trialsPerSession);
      expect(loaded.stimulusDurationMs, model.stimulusDurationMs);
      expect(loaded.isiMs, model.isiMs);
      expect(loaded.adaptiveMode, model.adaptiveMode);
    });

    test('clear restores defaults', () async {
      final repo = await _repo();
      await repo.save(
        SettingsModel.defaults().copyWith(initialN: 9, adaptiveMode: false),
      );
      await repo.clear();

      final loaded = repo.load();
      expect(loaded.initialN, SettingsModel.defaults().initialN);
      expect(loaded.adaptiveMode, SettingsModel.defaults().adaptiveMode);
    });

    test('round-trips audio voice', () async {
      final repo = await _repo();
      // Default is female; persist male and reload.
      await repo.save(
        SettingsModel.defaults().copyWith(audioVoice: AudioVoice.male),
      );
      expect(repo.load().audioVoice, AudioVoice.male);
    });

    test('falls back to default voice when stored value is unknown', () async {
      final repo = await _repo({'settings.audioVoice': 'robotic'});
      expect(repo.load().audioVoice, SettingsModel.defaults().audioVoice);
    });

    test('ignores unknown channel names from a future version', () async {
      final repo = await _repo({
        'settings.channels': ['position', 'unknown_channel', 'shape'],
      });
      final loaded = repo.load();
      expect(
        loaded.defaultChannels,
        {ChannelType.position, ChannelType.shape},
      );
    });
  });

  group('SettingsRepository presets', () {
    test('loadPresets returns null when key is absent', () async {
      final repo = await _repo();
      expect(repo.loadPresets(), isNull);
    });

    test('savePresets / loadPresets round-trip', () async {
      final repo = await _repo();
      final presets = [
        Preset.defaultPreset(),
        Preset(
          id: 'p_1',
          name: 'Fast',
          settings: PresetSettings.fromSettings(
            SettingsModel.defaults().copyWith(initialN: 5, isiMs: 1500),
          ),
        ),
      ];
      await repo.savePresets(presets);

      final loaded = repo.loadPresets();
      expect(loaded, isNotNull);
      expect(loaded!.length, 2);
      expect(loaded[0].isDefault, isTrue);
      expect(loaded[1].id, 'p_1');
      expect(loaded[1].name, 'Fast');
      expect(loaded[1].settings.initialN, 5);
      expect(loaded[1].settings.isiMs, 1500);
    });

    test('loadPresets injects a default entry when missing', () async {
      final repo = await _repo();
      await repo.savePresets([
        Preset(id: 'p_1', name: 'Only', settings: PresetSettings.defaults()),
      ]);
      final loaded = repo.loadPresets()!;
      expect(loaded.any((p) => p.isDefault), isTrue);
    });

    test('loadPresets rebuilds default-only list on malformed JSON', () async {
      final repo = await _repo({'presets.payloads': 'not json {['});
      final loaded = repo.loadPresets()!;
      expect(loaded.length, 1);
      expect(loaded.single.isDefault, isTrue);
    });

    test('active id load + fallback to default', () async {
      final repo = await _repo();
      expect(repo.loadActivePresetId(), Preset.defaultPresetId);
      await repo.saveActivePresetId('p_xyz');
      expect(repo.loadActivePresetId(), 'p_xyz');
    });

    test('clear removes preset keys', () async {
      final repo = await _repo();
      await repo.savePresets([Preset.defaultPreset()]);
      await repo.saveActivePresetId('p_1');
      await repo.clear();
      expect(repo.loadPresets(), isNull);
      expect(repo.loadActivePresetId(), Preset.defaultPresetId);
    });

    test('saveGlobals persists only global fields', () async {
      final repo = await _repo();
      final model = SettingsModel.defaults().copyWith(
        dailyGoalSessions: 7,
        notificationsEnabled: true,
      );
      await repo.saveGlobals(model);
      final loaded = repo.load();
      expect(loaded.dailyGoalSessions, 7);
      expect(loaded.notificationsEnabled, isTrue);
    });
  });
}
