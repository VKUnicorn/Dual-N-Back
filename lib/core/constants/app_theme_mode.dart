/// Theme preference for the app.
///
/// Kept in the pure-Dart constants layer (no Flutter import) so the
/// settings domain stays Flutter-free. It is mapped to Flutter's
/// `ThemeMode` in `app.dart`, which is the single place that needs to
/// know about the framework enum.
///
/// - [system]: follow the OS light/dark setting (default).
/// - [light]: force light theme regardless of OS setting.
/// - [dark]: force dark theme regardless of OS setting.
enum AppThemeMode { system, light, dark }
