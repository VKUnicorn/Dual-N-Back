import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the daily "time to train" local notifications.
///
/// Abstract so widget/unit tests can swap in [NoOpNotificationService]
/// instead of the real plugin-backed implementation, which can't run
/// without a platform channel.
abstract class NotificationService {
  Future<void> init();

  /// Asks the user for the runtime POST_NOTIFICATIONS permission
  /// (Android 13+). On older Androids it's a no-op (granted at install
  /// time). Returns true if currently granted.
  Future<bool> requestPermission();

  /// Reconciles the scheduled notifications with the latest settings.
  /// Cancels everything first, then re-schedules one weekly entry per
  /// non-rest weekday if [enabled].
  Future<void> sync({
    required bool enabled,
    required int timeMinutes,
    required Set<int> restDays,
    required String title,
    required String body,
  });
}

/// Production implementation backed by `flutter_local_notifications`.
///
/// Implementation notes:
/// - Each weekday gets its own scheduled notification with a stable ID
///   in [_idForWeekday] (1..7 = Mon..Sun). Rest days are simply not
///   scheduled. This is preferred over a single daily notification with
///   a runtime "is today a rest day?" check because local notifications
///   fire automatically — there's no callback to suppress them once
///   armed.
/// - We use `AndroidScheduleMode.inexactAllowWhileIdle` so the user
///   doesn't need to grant `SCHEDULE_EXACT_ALARM`; Android may delay
///   the fire by up to ~15 minutes but that's acceptable for a training
///   reminder.
/// - `DateTimeComponents.dayOfWeekAndTime` repeats the schedule weekly
///   on the same weekday.
class PluginNotificationService implements NotificationService {
  PluginNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily reminder';
  static const String _channelDescription =
      'Daily nudge to play an N-back session.';

  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } on Object catch (e) {
      // Fall back to UTC if the device's zone name can't be resolved.
      // Worst case the user gets the reminder offset by their UTC bias —
      // still better than crashing on boot.
      debugPrint('NotificationService: timezone init failed: $e');
    }

    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(init);
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission() ?? true;
    return granted;
  }

  @override
  Future<void> sync({
    required bool enabled,
    required int timeMinutes,
    required Set<int> restDays,
    required String title,
    required String body,
  }) async {
    await _plugin.cancelAll();
    if (!enabled) return;

    final hour = timeMinutes ~/ 60;
    final minute = timeMinutes % 60;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
      ),
    );

    for (var weekday = 1; weekday <= 7; weekday++) {
      if (restDays.contains(weekday)) continue;
      final scheduled = _nextInstanceOfWeekdayTime(weekday, hour, minute);
      try {
        await _plugin.zonedSchedule(
          _idForWeekday(weekday),
          title,
          body,
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } on Object catch (e) {
        // Best-effort: a single failed day shouldn't stop the rest.
        debugPrint(
          'NotificationService: schedule weekday=$weekday failed: $e',
        );
      }
    }
  }

  /// Computes the next [tz.TZDateTime] in the user's local zone matching
  /// the given [weekday] (`DateTime.weekday`: 1=Mon..7=Sun) and time.
  /// Falls back to "tomorrow's slot" when today's time has already
  /// passed.
  tz.TZDateTime _nextInstanceOfWeekdayTime(
    int weekday,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Maps `DateTime.weekday` (1..7) to a stable notification id used by
  /// `cancelAll`/`zonedSchedule`. Kept low (1..7) so it doesn't collide
  /// with future ad-hoc notifications.
  int _idForWeekday(int weekday) => weekday;
}

/// Silent implementation used in widget/unit tests so the
/// `_NotificationSyncObserver` can run without a platform channel.
class NoOpNotificationService implements NotificationService {
  const NoOpNotificationService();

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> sync({
    required bool enabled,
    required int timeMinutes,
    required Set<int> restDays,
    required String title,
    required String body,
  }) async {}
}
