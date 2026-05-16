import 'package:dual_n_back/core/notifications/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single instance of [NotificationService] for the app. Bound to a real
/// instance in `main.dart` before `runApp`; tests can override with a
/// stub that no-ops [NotificationService.sync].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden in main()',
  );
});

/// Convenience factory used by `main.dart` to build the production
/// instance. Kept out of the provider so tests don't accidentally
/// instantiate the real Flutter-plugin-backed service.
NotificationService buildNotificationService() {
  return PluginNotificationService(FlutterLocalNotificationsPlugin());
}
