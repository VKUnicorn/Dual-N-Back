import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/data/settings_repository.dart';
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
}
