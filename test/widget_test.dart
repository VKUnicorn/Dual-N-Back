import 'package:dual_n_back/app.dart';
import 'package:dual_n_back/core/notifications/notification_provider.dart';
import 'package:dual_n_back/core/notifications/notification_service.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home screen renders Start button', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(
            const NoOpNotificationService(),
          ),
        ],
        child: DualNBackApp(),
      ),
    );
    await tester.pumpAndSettle();

    // App uses platform locale (en in tests). Verify the localized
    // home screen renders the Start button (English).
    expect(find.text('Start session'), findsOneWidget);
  });
}
