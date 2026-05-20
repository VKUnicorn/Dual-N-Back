import 'dart:async';

import 'package:dual_n_back/core/audio/audio_service.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Application-wide AudioService. Override in tests with [SilentAudioService].
///
/// The service is instantiated with the persisted voice from settings and
/// listens for subsequent voice changes — switching folders without
/// requiring an app restart.
final audioServiceProvider = Provider<AudioService>((ref) {
  final initialSettings = ref.read(settingsProvider);
  final service = AudioPlayersAudioService(
    voice: initialSettings.audioVoice,
    letters: initialSettings.audioLetters,
  );
  // Kick off preload + warm-up the moment the service is constructed.
  // Without this, a user who opens settings before ever entering the
  // game screen would only trigger AudioService creation here — but
  // letter players would still load lazily on the first preview tap,
  // costing ~1 s of UI lag. Firing preload now means the audio
  // pipeline (codecs, SoundPool, MediaPlayer warm-up) is primed by
  // the time any UI surface needs it.
  unawaited(service.preload());
  ref
    ..onDispose(service.dispose)
    ..listen(
      settingsProvider.select((s) => s.audioVoice),
      (_, next) => unawaited(service.setVoice(next)),
    )
    ..listen(
      settingsProvider.select((s) => s.audioLetters),
      (_, next) => unawaited(service.setLetters(next)),
    );
  return service;
});
