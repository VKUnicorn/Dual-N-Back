# Audio assets

All audio used by the app lives here. Layout:

```
assets/audio/
  female/        — female-voice letter recordings (default)
  male/          — male-voice letter recordings
  correct.mp3    — response feedback: correct match press
  incorrect.mp3  — response feedback: false-alarm press
  missed.mp3     — response feedback: missed match
  play.mp3       — UI cue: play button pressed (before countdown)
  victory.mp3    — UI cue: session ended with accuracy >= 90%
  fail.mp3       — UI cue: session ended with accuracy <= 70%
```

If any file is missing the app still runs — the audio service logs the
miss and no-ops for that clip.

## Letter recordings

Short (200–400 ms) MP3 per letter, named `{letter}.mp3` inside the
voice folder (e.g. `female/c.mp3`). The full English alphabet `a–z`
may sit in each folder; the *active* set is configurable in
Settings → Sound → Letters (4–26 letters, 8 recommended). The default
seed is the 8 non-confusable Jaeggi letters: `c h k l q r s t`.

Voice is switched in Settings → Sound → Voice (default `female`).
Switching voices drops the loaded-player cache and reloads from the new
folder; changing the active letter set only loads newly-added letters
and keeps everything else cached.

The active-set default and the path scheme are defined in:
- `lib/core/constants/nback_defaults.dart` — `audioLetters` default
- `lib/core/audio/audio_service.dart` — `_defaultAssetPath`

Letter playback uses `audioplayers` in `PlayerMode.lowLatency`
(SoundPool on Android) — the right tool for short SFX with frequent
rapid replay and no buffer warm-up.

## Response feedback clips

Played at the moment the player presses (correctly or wrongly) or
misses a match. Voice-independent — placed directly under
`assets/audio/`. Each clip is gated by an independent setting toggle
(visual/audio × press/miss = 4 booleans in Settings → Feedback).

Playback uses the default `MediaPlayer` mode with a pool of 3 players
per clip and round-robin selection, so back-to-back fires in
multi-channel sessions actually overlap instead of cutting each other
off. `MediaPlayer` (not lowLatency) is intentional — see the
`_feedbackPool` doc comment in `audio_service.dart` for the rationale.

## UI cue sounds

One-shot clips played outside the per-trial feedback flow:

- `play.mp3` — fires from `GameNotifier.play()` the moment the user
  taps the in-grid Play button, right before the 3-2-1 countdown.
- `victory.mp3` / `fail.mp3` — fired once on the result screen based
  on `score.overallAccuracy`: victory at `>= 90%` (alongside confetti),
  fail at `<= 70%`. The 70–90% middle band stays silent.

These are not gated by user settings (intentional — they're part of
the app's core feedback rhythm). Playback uses `MediaPlayer` with one
player per sound (no pool — these clips never overlap).
