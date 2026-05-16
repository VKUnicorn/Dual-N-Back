import 'dart:math';

import 'package:drift/native.dart';
import 'package:dual_n_back/core/audio/audio_provider.dart';
import 'package:dual_n_back/core/audio/audio_service.dart';
import 'package:dual_n_back/features/game/application/game_notifier.dart';
import 'package:dual_n_back/features/game/domain/game_session.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _stimulus = Duration(milliseconds: 500);
const _trial = Duration(milliseconds: 2500);
const _countdownTick = Duration(milliseconds: 1);
// Total countdown is 3 ticks; advance by this to skip the 3-2-1 phase.
const _countdownTotal = Duration(milliseconds: 4);

GameNotifierConfig _config({int trials = 5}) => GameNotifierConfig(
      trialsPerSession: trials,
      countdownTickDuration: _countdownTick,
      firstStimulusDelay: Duration.zero,
      random: Random(0),
    );

late SharedPreferences _prefs;

({ProviderContainer container, SilentAudioService audio}) _container() {
  final audio = SilentAudioService();
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final container = ProviderContainer(
    overrides: [
      audioServiceProvider.overrideWithValue(audio),
      sharedPreferencesProvider.overrideWithValue(_prefs),
      appDatabaseProvider.overrideWithValue(db),
    ],
  );
  addTearDown(container.dispose);
  return (container: container, audio: audio);
}

({
  GameNotifier notifier,
  ProviderContainer container,
  SilentAudioService audio,
}) _prepare({
  int n = 2,
  Set<ChannelType> channels = const {ChannelType.position},
  GameNotifierConfig? config,
}) {
  final (:container, :audio) = _container();
  final notifier = container.read(gameNotifierProvider.notifier)
    ..overrideConfig(config ?? _config())
    ..start(n: n, activeChannels: channels);
  return (notifier: notifier, container: container, audio: audio);
}

/// Goes through start → play → countdown → running in one shot.
({
  GameNotifier notifier,
  ProviderContainer container,
  SilentAudioService audio,
}) _start({
  required FakeAsync async,
  int n = 2,
  Set<ChannelType> channels = const {ChannelType.position},
  GameNotifierConfig? config,
}) {
  final r = _prepare(n: n, channels: channels, config: config);
  r.notifier.play();
  async.elapse(_countdownTotal);
  return r;
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  group('GameNotifier lifecycle', () {
    test('starts in idle state', () {
      final (:container, audio: _) = _container();
      final session = container.read(gameNotifierProvider);
      expect(session.status, GameStatus.idle);
      expect(session.trials, isEmpty);
    });

    test('start: builds trials and waits in preparing state', () {
      final r = _prepare();
      final s = r.container.read(gameNotifierProvider);
      expect(s.status, GameStatus.preparing);
      expect(s.n, 2);
      expect(s.trials.length, 2 + 5);
      expect(s.currentTrialIndex, 0);
      expect(s.stimulusVisible, isFalse);
    });

    test('play: runs countdown and then begins stimuli', () {
      fakeAsync((async) {
        final r = _prepare();
        r.notifier.play();
        // Right after play, we are in countdown with value 3.
        var s = r.container.read(gameNotifierProvider);
        expect(s.status, GameStatus.countdown);
        expect(s.countdownValue, 3);

        // Skip the 3-2-1 ticks.
        async.elapse(_countdownTotal);
        s = r.container.read(gameNotifierProvider);
        expect(s.status, GameStatus.running);
        expect(s.stimulusVisible, isTrue);
        expect(s.countdownValue, isNull);
      });
    });

    test('play is a no-op outside preparing state', () {
      final r = _prepare();
      r.notifier
        ..play() // ok, enters countdown
        ..play(); // second call ignored
      // Still valid: state is countdown, not jumped to running.
      final s = r.container.read(gameNotifierProvider);
      expect(s.status, GameStatus.countdown);
    });

    test('stimulus hides after stimulusDuration', () {
      fakeAsync((async) {
        final r = _start(async: async);
        async.elapse(_stimulus);
        final s = r.container.read(gameNotifierProvider);
        expect(s.stimulusVisible, isFalse);
        expect(s.currentTrialIndex, 0);
      });
    });

    test('advances to next trial after trialDuration', () {
      fakeAsync((async) {
        final r = _start(async: async);
        async.elapse(_trial);
        final s = r.container.read(gameNotifierProvider);
        expect(s.currentTrialIndex, 1);
        expect(s.stimulusVisible, isTrue);
        expect(s.lockedChannels, isEmpty);
      });
    });

    test('finishes after total session duration', () {
      fakeAsync((async) {
        final r = _start(async: async);
        async.elapse(_trial * 7);
        final s = r.container.read(gameNotifierProvider);
        expect(s.status, GameStatus.finished);
        expect(s.finalScore, isNotNull);
        expect(s.newN, isNotNull);
      });
    });
  });

  group('audio playback', () {
    test('plays a letter on every trial when audio channel is active', () {
      fakeAsync((async) {
        final r = _start(
          async: async,
          channels: const {ChannelType.position, ChannelType.audio},
        );
        // 2 + 5 = 7 trials => 7 audio plays.
        async.elapse(_trial * 7);
        expect(r.audio.playedCount, 7);
        expect(r.audio.playedLetters.every((i) => i >= 0 && i < 8), isTrue);
      });
    });

    test('does not play audio when audio channel is inactive', () {
      fakeAsync((async) {
        // Default channels set is position only.
        final r = _start(async: async);
        async.elapse(_trial * 7);
        expect(r.audio.playedCount, 0);
      });
    });

    test('does not play audio during preparing or countdown', () {
      fakeAsync((async) {
        final r = _prepare(
          channels: const {ChannelType.position, ChannelType.audio},
        );
        // Still in preparing — no audio yet.
        expect(r.audio.playedCount, 0);
        r.notifier.play();
        // First tick of countdown — still no audio.
        async.elapse(_countdownTick);
        expect(r.audio.playedCount, 0);
      });
    });
  });

  group('registerMatch', () {
    test('records the press for current trial only once', () {
      fakeAsync((async) {
        final r = _start(async: async);
        async.elapse(_trial * 2);
        expect(r.container.read(gameNotifierProvider).currentTrialIndex, 2);

        r.notifier
          ..registerMatch(ChannelType.position)
          ..registerMatch(ChannelType.position); // ignored

        final s = r.container.read(gameNotifierProvider);
        expect(s.responses[ChannelType.position], {2});
        expect(s.lockedChannels.contains(ChannelType.position), isTrue);
      });
    });

    test('lock clears at the start of the next trial', () {
      fakeAsync((async) {
        final r = _start(async: async);
        async.elapse(_trial * 2);
        r.notifier.registerMatch(ChannelType.position);
        async.elapse(_trial); // next trial begins

        final s = r.container.read(gameNotifierProvider);
        expect(s.currentTrialIndex, 3);
        expect(s.lockedChannels, isEmpty);
      });
    });

    test('does nothing when not running', () {
      final (:container, audio: _) = _container();
      container
          .read(gameNotifierProvider.notifier)
          .registerMatch(ChannelType.position);
      expect(container.read(gameNotifierProvider).status, GameStatus.idle);
    });

    test('does nothing during preparing or countdown', () {
      fakeAsync((async) {
        final r = _prepare();
        r.notifier.registerMatch(ChannelType.position);
        expect(
          r.container
              .read(gameNotifierProvider)
              .responses[ChannelType.position],
          isEmpty,
        );
        r.notifier
          ..play()
          ..registerMatch(ChannelType.position);
        // Still in countdown — match should not register.
        expect(
          r.container
              .read(gameNotifierProvider)
              .responses[ChannelType.position],
          isEmpty,
        );
        async.elapse(_countdownTotal);
      });
    });

    test('records matches per channel independently', () {
      fakeAsync((async) {
        final r = _start(
          async: async,
          channels: const {
            ChannelType.position,
            ChannelType.audio,
            ChannelType.color,
            ChannelType.shape,
          },
        );
        async.elapse(_trial * 2);

        r.notifier
          ..registerMatch(ChannelType.position)
          ..registerMatch(ChannelType.color);

        final s = r.container.read(gameNotifierProvider);
        expect(s.responses[ChannelType.position], {2});
        expect(s.responses[ChannelType.color], {2});
        expect(s.responses[ChannelType.audio], <int>{});
        expect(s.responses[ChannelType.shape], <int>{});
      });
    });
  });

  group('abort', () {
    test('cancels timers and moves to aborted state', () {
      fakeAsync((async) {
        final r = _start(async: async);
        r.notifier.abort();
        async.elapse(_trial * 100);
        expect(r.container.read(gameNotifierProvider).status, GameStatus.aborted);
      });
    });

    test('also aborts during countdown', () {
      fakeAsync((async) {
        final r = _prepare();
        r.notifier
          ..play()
          ..abort();
        async.elapse(_countdownTotal * 10);
        expect(
          r.container.read(gameNotifierProvider).status,
          GameStatus.aborted,
        );
      });
    });
  });

  group('pause / resume', () {
    test('pause from running freezes the session and cancels timers', () {
      fakeAsync((async) {
        final r = _start(async: async);
        async.elapse(_trial); // advance to trial 1
        expect(
          r.container.read(gameNotifierProvider).currentTrialIndex,
          1,
        );

        r.notifier.pause();
        final paused = r.container.read(gameNotifierProvider);
        expect(paused.status, GameStatus.paused);
        expect(paused.stimulusVisible, isFalse);

        // Long elapse should not change anything while paused.
        async.elapse(_trial * 100);
        final still = r.container.read(gameNotifierProvider);
        expect(still.status, GameStatus.paused);
        expect(still.currentTrialIndex, 1);
      });
    });

    test('resume from running-pause continues without re-showing stimulus',
        () {
      fakeAsync((async) {
        final r = _start(
          async: async,
          channels: const {ChannelType.position, ChannelType.audio},
        );
        async.elapse(_trial); // trial 1 active
        final audioBefore = r.audio.playedCount;
        r.notifier.pause();

        async.elapse(_trial * 50); // ignored during pause
        r.notifier.resume();

        final resumed = r.container.read(gameNotifierProvider);
        expect(resumed.status, GameStatus.running);
        expect(resumed.stimulusVisible, isFalse);
        expect(resumed.currentTrialIndex, 1);
        // Audio for the current trial must NOT replay on resume.
        expect(r.audio.playedCount, audioBefore);

        async.elapse(_trial); // next trial fires
        expect(
          r.container.read(gameNotifierProvider).currentTrialIndex,
          2,
        );
      });
    });

    test('pause during countdown preserves countdownValue', () {
      fakeAsync((async) {
        final r = _prepare();
        r.notifier.play();
        // Tick once: countdown 3 -> 2
        async.elapse(_countdownTick);
        expect(
          r.container.read(gameNotifierProvider).countdownValue,
          2,
        );

        r.notifier.pause();
        final paused = r.container.read(gameNotifierProvider);
        expect(paused.status, GameStatus.paused);
        expect(paused.countdownValue, 2);

        // No further changes while paused.
        async.elapse(_countdownTotal * 50);
        expect(
          r.container.read(gameNotifierProvider).status,
          GameStatus.paused,
        );

        r.notifier.resume();
        // Countdown restarts at the saved value (2).
        expect(
          r.container.read(gameNotifierProvider).countdownValue,
          2,
        );
        expect(
          r.container.read(gameNotifierProvider).status,
          GameStatus.countdown,
        );

        async.elapse(_countdownTotal);
        expect(
          r.container.read(gameNotifierProvider).status,
          GameStatus.running,
        );
      });
    });

    test('pause is a no-op outside running/countdown', () {
      // From idle.
      final (:container, audio: _) = _container();
      final notifier = container.read(gameNotifierProvider.notifier)
        ..pause();
      expect(
        container.read(gameNotifierProvider).status,
        GameStatus.idle,
      );

      // From preparing.
      notifier
        ..overrideConfig(_config())
        ..start(n: 2, activeChannels: const {ChannelType.position})
        ..pause();
      expect(
        container.read(gameNotifierProvider).status,
        GameStatus.preparing,
      );
    });

    test('resume is a no-op outside paused state', () {
      fakeAsync((async) {
        final r = _start(async: async);
        r.notifier.resume(); // already running
        expect(
          r.container.read(gameNotifierProvider).status,
          GameStatus.running,
        );
      });
    });
  });
}
