import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/domain/preset_settings.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PresetSettings', () {
    test('defaults match SettingsModel preset-scoped defaults', () {
      final p = PresetSettings.defaults();
      final s = SettingsModel.defaults();
      expect(p.defaultChannels, s.defaultChannels);
      expect(p.channelLayout, s.channelLayout);
      expect(p.initialN, s.initialN);
      expect(p.minN, s.minN);
      expect(p.maxN, s.maxN);
      expect(p.trialsPerSession, s.trialsPerSession);
      expect(p.stimulusDurationMs, s.stimulusDurationMs);
      expect(p.isiMs, s.isiMs);
      expect(p.matchProbability, s.matchProbability);
      expect(p.matchProbabilityJitter, s.matchProbabilityJitter);
      expect(p.adaptiveMode, s.adaptiveMode);
      expect(p.advanceThreshold, s.advanceThreshold);
      expect(p.regressThreshold, s.regressThreshold);
      expect(p.volume, s.volume);
      expect(p.audioVoice, s.audioVoice);
      expect(p.audioLetters, s.audioLetters);
      expect(p.colors, s.colors);
      expect(p.gridStyle, s.gridStyle);
      expect(p.showFixationCross, s.showFixationCross);
      expect(p.allowCenterPosition, s.allowCenterPosition);
      expect(p.stimulusFadeMs, s.stimulusFadeMs);
      expect(p.feedbackVisualOnPress, s.feedbackVisualOnPress);
      expect(p.feedbackAudioOnPress, s.feedbackAudioOnPress);
      expect(p.feedbackVisualOnMiss, s.feedbackVisualOnMiss);
      expect(p.feedbackAudioOnMiss, s.feedbackAudioOnMiss);
    });

    test('fromSettings / applyPreset round-trip', () {
      final s = SettingsModel.defaults().copyWith(
        defaultChannels: {ChannelType.position, ChannelType.shape},
        initialN: 5,
        minN: 2,
        maxN: 7,
        volume: 0.5,
        audioVoice: AudioVoice.male,
        gridStyle: GridStyle.tile,
        colors: List<int>.generate(SettingsModel.colorCount, (i) => i + 1),
      );
      final payload = PresetSettings.fromSettings(s);
      final rebuilt = SettingsModel.defaults().applyPreset(payload);

      expect(rebuilt.defaultChannels, s.defaultChannels);
      expect(rebuilt.initialN, s.initialN);
      expect(rebuilt.minN, s.minN);
      expect(rebuilt.maxN, s.maxN);
      expect(rebuilt.volume, s.volume);
      expect(rebuilt.audioVoice, s.audioVoice);
      expect(rebuilt.gridStyle, s.gridStyle);
      expect(rebuilt.colors, s.colors);
    });

    test('toJson / fromJson round-trip (colors hex, enums, channels)', () {
      final original = PresetSettings.fromSettings(
        SettingsModel.defaults().copyWith(
          defaultChannels: {ChannelType.audio, ChannelType.color},
          channelLayout: const [
            ChannelType.shape,
            ChannelType.color,
            ChannelType.audio,
            ChannelType.position,
          ],
          audioVoice: AudioVoice.male,
          gridStyle: GridStyle.tile,
          audioLetters: const ['a', 'b', 'c', 'd', 'e'],
          colors: const [
            0xFF112233,
            0xFF000000,
            0xFFFFFFFF,
            0xFFAABBCC,
            0xFF010203,
            0xFF040506,
            0xFF070809,
            0xFF0A0B0C,
          ],
          initialN: 6,
          adaptiveMode: true,
        ),
      );
      final restored = PresetSettings.fromJson(original.toJson());

      expect(restored.defaultChannels, original.defaultChannels);
      expect(restored.channelLayout, original.channelLayout);
      expect(restored.audioVoice, original.audioVoice);
      expect(restored.gridStyle, original.gridStyle);
      expect(restored.audioLetters, original.audioLetters);
      expect(restored.colors, original.colors);
      expect(restored.initialN, original.initialN);
      expect(restored.adaptiveMode, original.adaptiveMode);
    });

    group('fromJson validation falls back to defaults', () {
      final d = PresetSettings.defaults();

      test('unknown enum names', () {
        final p = PresetSettings.fromJson({
          'audioVoice': 'robotic',
          'gridStyle': 'hologram',
        });
        expect(p.audioVoice, d.audioVoice);
        expect(p.gridStyle, d.gridStyle);
      });

      test('layout missing a channel', () {
        final p = PresetSettings.fromJson({
          'channelLayout': ['position', 'audio', 'color'],
        });
        expect(p.channelLayout, d.channelLayout);
      });

      test('audio letters below minimum', () {
        final p = PresetSettings.fromJson({
          'audioLetters': ['a', 'b'],
        });
        expect(p.audioLetters, d.audioLetters);
      });

      test('colors wrong length', () {
        final p = PresetSettings.fromJson({
          'colors': ['FF000000', 'FF111111'],
        });
        expect(p.colors, d.colors);
      });

      test('colors malformed hex', () {
        final p = PresetSettings.fromJson({
          'colors': List<String>.filled(SettingsModel.colorCount, 'zzzz'),
        });
        expect(p.colors, d.colors);
      });

      test('empty json yields full defaults', () {
        final p = PresetSettings.fromJson(const {});
        expect(p.initialN, d.initialN);
        expect(p.colors, d.colors);
        expect(p.audioLetters, d.audioLetters);
        expect(p.channelLayout, d.channelLayout);
      });
    });
  });
}
