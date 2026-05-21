/// Standalone UI cue sounds, played outside the per-trial feedback flow.
///
/// Each value maps to `assets/audio/{name}.mp3` (voice-independent) and
/// plays as a one-shot via `AudioService.playUiSound`. Unlike
/// `FeedbackKind`, these clips are never overlapped, so the service
/// keeps a single MediaPlayer per sound (no round-robin pool).
enum UiSound { play, victory, fail }
