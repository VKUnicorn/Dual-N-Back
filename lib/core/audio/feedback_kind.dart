/// Categories of in-session response feedback.
///
/// Each kind maps to a short SFX clip under `assets/audio/{name}.mp3`
/// (voice-independent) and to a 500 ms button-flash colour defined in
/// `core/constants/feedback_colors.dart`. Visibility of either side
/// effect is gated by the per-event toggles in the user settings.
enum FeedbackKind { correct, incorrect, missed }
