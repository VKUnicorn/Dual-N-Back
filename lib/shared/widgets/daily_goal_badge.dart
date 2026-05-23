import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pill showing today's session count against the configured daily goal.
///
/// Designed for use in an [AppBar.actions] slot — sized for the home
/// screen header where the title is absent. Reactively rebuilds whenever
/// new sessions land in the statistics database or settings change.
class DailyGoalBadge extends ConsumerWidget {
  const DailyGoalBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final goal = ref.watch(
      settingsProvider.select((s) => s.dailyGoalSessions),
    );
    final restDays = ref.watch(
      settingsProvider.select((s) => s.restDays),
    );
    final count = ref.watch(sessionsTodayCountProvider);
    final reached = count >= goal;
    // Rest-day label only fires when there's no obligation to play
    // today — i.e. today's weekday is in the user's rest-day set AND
    // the goal isn't already met (don't undermine a real completion).
    final isRestDayToday =
        restDays.contains(DateTime.now().weekday) && !reached;
    final color = reached
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Center(
        child: Tooltip(
          message: l.homeDailyGoalTooltip,
          // On Android the default trigger is long-press; the user wants
          // a single tap to surface the hint.
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videogame_asset_rounded,
                    size: 40,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.homeDailyProgress(count, goal),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (isRestDayToday)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    l.homeRestDayLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
