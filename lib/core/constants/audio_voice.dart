/// Voice variant used for the audio channel.
///
/// Letter recordings are stored under `assets/audio/{voice.name}/` —
/// each value here corresponds 1:1 to a folder name.
///
/// - [female]: default; the original recordings shipped with the app.
/// - [male]: alternative voice; assets may be missing, in which case
///   playback silently no-ops (see `AudioService.playLetter`).
enum AudioVoice { female, male }
