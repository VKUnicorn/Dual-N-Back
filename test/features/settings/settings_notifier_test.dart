import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/settings/data/settings_repository.dart';
import 'package:dual_n_back/features/settings/domain/preset.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

SettingsModel _state(ProviderContainer c) => c.read(settingsProvider);
SettingsNotifier _notifier(ProviderContainer c) =>
    c.read(settingsProvider.notifier);

String _nonDefaultId(ProviderContainer c) =>
    _state(c).presets.firstWhere((r) => !r.isDefault).id;

void main() {
  group('SettingsNotifier presets', () {
    test('fresh install seeds a single default preset', () async {
      final c = await _container();
      final s = _state(c);
      expect(s.presets.length, 1);
      expect(s.presets.single.isDefault, isTrue);
      expect(s.activePresetId, Preset.defaultPresetId);
    });

    test('migrates legacy settings into the default preset', () async {
      final c = await _container({'settings.initialN': 6});
      final s = _state(c);
      expect(s.activePresetId, Preset.defaultPresetId);
      expect(s.initialN, 6);
      // Persisted so a future load sees presets (non-null).
      final prefs = await SharedPreferences.getInstance();
      expect(SettingsRepository(prefs).loadPresets(), isNotNull);
    });

    test('createPreset copies active settings and becomes active', () async {
      final c = await _container();
      await _notifier(c).updateInitialN(3);
      await _notifier(c).createPreset('Custom');

      final s = _state(c);
      expect(s.presets.length, 2);
      expect(s.activePresetId, isNot(Preset.defaultPresetId));
      // Copied from the previously active (default) preset.
      expect(s.initialN, 3);
    });

    test('selectPreset swaps the mirrored payload', () async {
      final c = await _container();
      await _notifier(c).updateInitialN(3); // default => 3
      await _notifier(c).createPreset('Custom'); // copy, active = custom
      final customId = _nonDefaultId(c);
      await _notifier(c).updateInitialN(7); // custom => 7

      await _notifier(c).selectPreset(Preset.defaultPresetId);
      expect(_state(c).initialN, 3); // default untouched

      await _notifier(c).selectPreset(customId);
      expect(_state(c).initialN, 7);
    });

    test('scoped update mutates only the active payload', () async {
      final c = await _container();
      await _notifier(c).createPreset('Custom'); // active = custom
      await _notifier(c).updateInitialN(8); // custom => 8

      await _notifier(c).selectPreset(Preset.defaultPresetId);
      expect(_state(c).initialN, SettingsModel.defaults().initialN);
    });

    test('global update does not touch preset payloads', () async {
      final c = await _container();
      await _notifier(c).createPreset('Custom');
      await _notifier(c).updateInitialN(8);
      await _notifier(c).updateDailyGoalSessions(5); // global

      // Daily goal is global: survives preset switches.
      await _notifier(c).selectPreset(Preset.defaultPresetId);
      expect(_state(c).dailyGoalSessions, 5);
      // Custom preset's initialN preserved.
      await _notifier(c).selectPreset(_nonDefaultId(c));
      expect(_state(c).initialN, 8);
      expect(_state(c).dailyGoalSessions, 5);
    });

    test('renamePreset updates the ref and rejects the default', () async {
      final c = await _container();
      await _notifier(c).createPreset('Custom');
      final id = _nonDefaultId(c);

      await _notifier(c).renamePreset(id, 'Renamed');
      expect(
        _state(c).presets.firstWhere((r) => r.id == id).name,
        'Renamed',
      );

      await _notifier(c).renamePreset(Preset.defaultPresetId, 'Nope');
      expect(
        _state(c).presets.firstWhere((r) => r.isDefault).name,
        '',
      );
    });

    test('deletePreset removes it and falls back to default', () async {
      final c = await _container();
      await _notifier(c).createPreset('Custom'); // active = custom
      final id = _nonDefaultId(c);

      await _notifier(c).deletePreset(id);
      final s = _state(c);
      expect(s.presets.length, 1);
      expect(s.activePresetId, Preset.defaultPresetId);
    });

    test('deletePreset rejects the default preset', () async {
      final c = await _container();
      await _notifier(c).deletePreset(Preset.defaultPresetId);
      expect(_state(c).presets.any((r) => r.isDefault), isTrue);
    });

    test('resetToDefaults resets active + globals, keeps other presets',
        () async {
      final c = await _container();
      // Custom preset with a distinct initialN.
      await _notifier(c).createPreset('Custom');
      await _notifier(c).updateInitialN(7);
      final customId = _nonDefaultId(c);

      // Back on default: change scoped + global, then reset.
      await _notifier(c).selectPreset(Preset.defaultPresetId);
      await _notifier(c).updateInitialN(3);
      await _notifier(c).updateDailyGoalSessions(9);
      await _notifier(c).resetToDefaults();

      final s = _state(c);
      expect(s.initialN, SettingsModel.defaults().initialN);
      expect(s.dailyGoalSessions, SettingsModel.defaults().dailyGoalSessions);
      expect(s.presets.length, 2); // custom preset survived

      // Custom preset unchanged.
      await _notifier(c).selectPreset(customId);
      expect(_state(c).initialN, 7);
    });

    test('updateNRange clamps initialN inside the new range', () async {
      final c = await _container();
      await _notifier(c).updateInitialN(8);
      await _notifier(c).updateNRange(1, 4);
      expect(_state(c).initialN, 4);
    });
  });
}
