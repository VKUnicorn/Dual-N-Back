# Audio assets

Letter recordings (200–400 ms each) used by the audio channel.

The N-back protocol expects a fixed set of 8 non-confusable letters
(`c`, `h`, `k`, `l`, `q`, `r`, `s`, `t`) — the same as Jaeggi et al.
(2008). Only these 8 are loaded at runtime; the rest of the alphabet
may sit alongside them and is ignored.

## Voice variants

Recordings are organised by voice in two sibling folders:

```
assets/audio/
  female/   — female-voice recordings (default)
  male/     — male-voice recordings
```

Each folder contains one MP3 per letter named `{letter}.mp3`. The
active voice is selected in Settings → Sound. The default is `female`.

If a file is missing the app still runs — `AudioService.playLetter`
no-ops for unavailable letters. This is how the `male/` folder can ship
empty until recordings are added.

The set of letters is configured in
`lib/core/constants/nback_defaults.dart` (`NBackDefaults.audioLetters`).
The file extension and asset path are configured in
`lib/core/audio/audio_service.dart` (`_defaultPathBuilder`).
Playback uses `audioplayers` in `PlayerMode.lowLatency` — on Android
this routes to SoundPool, which is the right tool for short SFX clips.
