import 'dart:async';

import 'package:dual_n_back/core/notifications/notification_provider.dart';
import 'package:dual_n_back/core/router.dart';
import 'package:dual_n_back/core/theme/app_theme.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DualNBackApp extends ConsumerWidget {
  DualNBackApp({super.key});

  final GoRouter _router = buildRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeCode = ref.watch(
      settingsProvider.select((s) => s.localeCode),
    );

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: localeCode != null ? Locale(localeCode) : null,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      builder: (context, child) => _NotificationSyncObserver(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// Watches the settings provider and asks `NotificationService` to
/// re-sync whenever any notification-relevant field changes
/// (`notificationsEnabled`, `notificationTimeMinutes`, `restDays`).
///
/// Lives inside `MaterialApp.router.builder` so it can read
/// [AppLocalizations] for the notification title/body in the user's
/// current locale; a one-shot post-frame callback re-runs the sync once
/// at startup with the persisted settings, since `ref.listen` only
/// fires on subsequent changes.
class _NotificationSyncObserver extends ConsumerStatefulWidget {
  const _NotificationSyncObserver({required this.child});

  final Widget child;

  @override
  ConsumerState<_NotificationSyncObserver> createState() =>
      _NotificationSyncObserverState();
}

class _NotificationSyncObserverState
    extends ConsumerState<_NotificationSyncObserver> {
  bool _initialSyncScheduled = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    ref.listen<SettingsModel>(settingsProvider, (prev, next) {
      if (prev == null) return;
      if (prev.notificationsEnabled != next.notificationsEnabled ||
          prev.notificationTimeMinutes != next.notificationTimeMinutes ||
          !_restDaysEqual(prev.restDays, next.restDays)) {
        unawaited(_sync(next, l));
      }
    });

    if (!_initialSyncScheduled) {
      _initialSyncScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final s = ref.read(settingsProvider);
        unawaited(_sync(s, l));
      });
    }

    return widget.child;
  }

  Future<void> _sync(SettingsModel s, AppLocalizations l) async {
    final svc = ref.read(notificationServiceProvider);
    if (s.notificationsEnabled) {
      // Android 13+: shows the system permission dialog the first time
      // the user enables notifications; subsequent calls return the
      // current state without UI.
      await svc.requestPermission();
    }
    await svc.sync(
      enabled: s.notificationsEnabled,
      timeMinutes: s.notificationTimeMinutes,
      restDays: s.restDays,
      title: l.notificationTitle,
      body: l.notificationBody,
    );
  }

  bool _restDaysEqual(Set<int> a, Set<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final v in a) {
      if (!b.contains(v)) return false;
    }
    return true;
  }
}
