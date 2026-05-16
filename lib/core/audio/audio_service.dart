import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:flutter/foundation.dart';

/// Plays N-back audio stimuli (one short clip per letter).
///
/// File layout: `assets/audio/{voice}/{letter}.mp3` for each letter in
/// [NBackDefaults.audioLetters]. If a file is missing the service
/// silently no-ops instead of crashing — this lets the app run
/// before real recordings are dropped in (notably the male variant).
abstract class AudioService {
  /// Eagerly preloads all available letter clips for the active voice.
  /// Safe to call multiple times; subsequent calls are no-ops.
  Future<void> preload();

  /// Plays the clip for the letter at [letterIndex] in the currently
  /// active letter set (see [setLetters]). No-op if the clip is unavailable.
  Future<void> playLetter(int letterIndex);

  /// Plays the clip for [letter] regardless of whether it is in the active
  /// set — used by the settings screen to preview a letter the user just
  /// toggled on. No-op if the clip is unavailable.
  Future<void> playLetterByName(String letter);

  /// Sets the playback volume (0.0 — silent, 1.0 — max).
  Future<void> setVolume(double volume);

  /// Switches to a different voice variant. Disposes all loaded players
  /// and reloads the active set from the new voice's folder. No-op if
  /// the requested voice is already active.
  Future<void> setVoice(AudioVoice voice);

  /// Replaces the active letter set. The order matters — index `i` in
  /// [playLetter] maps to `letters[i]`. Lazily loads any letter that
  /// hasn't been seen before; existing cached players are reused, so
  /// toggling a single letter on/off does not disturb the others.
  Future<void> setLetters(List<String> letters);

  Future<void> dispose();
}

/// Builds the asset path for [letter] under [voice]. Returned paths are
/// relative to the `assets/` directory and exclude the leading
/// `assets/` segment, as required by `AudioPlayer.play(AssetSource(...))`.
typedef AudioAssetPathBuilder = String Function(
  AudioVoice voice,
  String letter,
);

String _defaultAssetPath(AudioVoice voice, String letter) =>
    'audio/${voice.name}/$letter.mp3';

/// Low-latency implementation backed by `audioplayers`.
///
/// Uses [PlayerMode.lowLatency] which routes to SoundPool on Android — the
/// right tool for short SFX (≤1 s clips, no buffer warm-up, glitch-free
/// rapid replay). On iOS this falls back to the AVAudioPlayer-based path,
/// which is also adequate for short clips.
///
/// Players are cached by letter name (not by active-set index) so changing
/// the active set in settings only loads new letters; previously loaded
/// players are reused. Voice changes are the only operation that drops
/// the cache and reloads from scratch.
class AudioPlayersAudioService implements AudioService {
  AudioPlayersAudioService({
    AudioVoice voice = AudioVoice.female,
    List<String>? letters,
    this.assetPathBuilder = _defaultAssetPath,
  })  : _voice = voice,
        _letters = List.unmodifiable(letters ?? NBackDefaults.audioLetters);

  AudioVoice _voice;
  double _volume = 1;
  List<String> _letters;

  final AudioAssetPathBuilder assetPathBuilder;

  /// Letter → loaded player cache. `null` value means the asset failed to
  /// load (e.g. missing file); the entry is kept to skip retry attempts.
  /// Cache is cleared only on voice change or [dispose].
  final Map<String, AudioPlayer?> _cache = {};

  /// Per-letter inflight load futures. Lets concurrent callers (e.g. a
  /// game-trial play and a settings-screen preview of the same letter)
  /// share a single load instead of racing two `setSource` calls.
  final Map<String, Future<AudioPlayer?>> _loading = {};

  /// Serializes voice swaps so a rapid double-tap can't tear down the
  /// cache twice in parallel.
  Future<void> _opChain = Future.value();

  Future<void> _enqueue(Future<void> Function() op) {
    final next = _opChain.catchError((_) {}).then((_) => op());
    _opChain = next;
    return next;
  }

  @override
  Future<void> preload() async {
    // Kick off loads for the active set in parallel; missing files are
    // logged inside [_loadPlayer] and become null entries.
    await Future.wait(_letters.map(_ensureLoaded));
  }

  /// Returns a player for [letter], loading it on first request and
  /// caching the result. Concurrent callers share the same load future.
  Future<AudioPlayer?> _ensureLoaded(String letter) {
    if (_cache.containsKey(letter)) {
      return Future.value(_cache[letter]);
    }
    final inflight = _loading[letter];
    if (inflight != null) return inflight;
    final future = _loadPlayer(letter).then((player) {
      _cache[letter] = player;
      // Removing the inflight entry returns the very Future we're inside,
      // which is already completing — nothing to await.
      // ignore: discarded_futures
      _loading.remove(letter);
      return player;
    });
    _loading[letter] = future;
    return future;
  }

  Future<AudioPlayer?> _loadPlayer(String letter) async {
    final player = AudioPlayer();
    try {
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource(assetPathBuilder(_voice, letter)));
      return player;
    } on Object catch (e) {
      debugPrint(
        'AudioService: missing asset for "${_voice.name}/$letter": $e',
      );
      await _safeDispose(player);
      return null;
    }
  }

  @override
  Future<void> playLetter(int letterIndex) async {
    if (letterIndex < 0 || letterIndex >= _letters.length) return;
    final letter = _letters[letterIndex];
    final player = await _ensureLoaded(letter);
    if (player == null) return;
    await _play(player);
  }

  @override
  Future<void> playLetterByName(String letter) async {
    final player = await _ensureLoaded(letter);
    if (player == null) return;
    await _play(player);
  }

  Future<void> _play(AudioPlayer player) async {
    try {
      await player.setVolume(_volume);
      await player.stop();
      await player.resume();
    } on Object catch (e) {
      debugPrint('AudioService: play failed: $e');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
  }

  @override
  Future<void> setVoice(AudioVoice voice) {
    return _enqueue(() async {
      if (voice == _voice) return;
      _voice = voice;
      // Voice change invalidates every cached player. Drop the cache and
      // re-warm the active set with the new voice's assets.
      final stale = List<AudioPlayer?>.from(_cache.values);
      _cache.clear();
      _loading.clear();
      await Future.wait(_letters.map(_ensureLoaded));
      for (final player in stale) {
        await _safeDispose(player);
      }
    });
  }

  @override
  Future<void> setLetters(List<String> letters) async {
    if (_letters.length == letters.length) {
      var same = true;
      for (var i = 0; i < letters.length; i++) {
        if (_letters[i] != letters[i]) {
          same = false;
          break;
        }
      }
      if (same) return;
    }
    _letters = List.unmodifiable(letters);
    // Lazy-load only the letters we haven't seen yet. Existing cached
    // players (including for letters that were just removed) stay loaded —
    // 26 short clips are cheap to keep around and reactivating a letter
    // becomes instant.
    for (final letter in _letters) {
      if (!_cache.containsKey(letter) && !_loading.containsKey(letter)) {
        unawaited(_ensureLoaded(letter));
      }
    }
  }

  Future<void> _safeDispose(AudioPlayer? player) async {
    if (player == null) return;
    try {
      await player.dispose();
    } on Object catch (e) {
      debugPrint('AudioService: dispose failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    final stale = List<AudioPlayer?>.from(_cache.values);
    _cache.clear();
    _loading.clear();
    for (final player in stale) {
      await _safeDispose(player);
    }
  }
}

/// No-op implementation for tests and contexts where audio is unavailable.
class SilentAudioService implements AudioService {
  int playedCount = 0;
  final List<int> playedLetters = [];
  final List<String> playedPreviewLetters = [];
  AudioVoice voice = AudioVoice.female;
  List<String> letters = List.unmodifiable(NBackDefaults.audioLetters);

  @override
  Future<void> preload() async {}

  @override
  Future<void> playLetter(int letterIndex) async {
    playedCount++;
    playedLetters.add(letterIndex);
  }

  @override
  Future<void> playLetterByName(String letter) async {
    playedPreviewLetters.add(letter);
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setVoice(AudioVoice voice) async {
    this.voice = voice;
  }

  @override
  Future<void> setLetters(List<String> letters) async {
    this.letters = List.unmodifiable(letters);
  }

  @override
  Future<void> dispose() async {}
}
