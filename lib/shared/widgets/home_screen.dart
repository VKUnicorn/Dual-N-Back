import 'dart:async';

import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:dual_n_back/shared/widgets/daily_goal_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const _StreakBadge(),
        leadingWidth: 100,
        actions: const [DailyGoalBadge()],
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 12, top: 4),
          child: _VersionLabel(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // Stretch the centered column to the available viewport when
          // possible; once the content exceeds it (e.g. small devices,
          // many buttons), let the scroll view take over.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 48,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            Text(
              'N-back\n${l.appTagline}',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () => context.push('/game'),
              icon: const Icon(Icons.play_arrow),
              label: Text(l.homeStartButton),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/info'),
              icon: const Icon(Icons.info_outline),
              label: Text(l.homeInfoButton),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/statistics'),
              icon: const Icon(Icons.bar_chart),
              label: Text(l.homeStatisticsButton),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/achievements'),
              icon: const Icon(Icons.emoji_events_outlined),
              label: Text(l.homeAchievementsButton),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings),
              label: Text(l.homeSettingsButton),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Top-left pill on the home AppBar showing the current daily-goal
/// streak. Tap to reveal an explanatory tooltip. Mirrors the styling of
/// [DailyGoalBadge] — same icon size, same text style, same tap-to-show
/// tooltip behaviour.
class _StreakBadge extends ConsumerWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final streak = ref.watch(currentStreakProvider);
    final color = streak > 0
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Center(
        child: Tooltip(
          message: l.homeStreakTooltip,
          triggerMode: TooltipTriggerMode.tap,
          // Default tap-trigger lifetime is ~1.5s; user wants ~2x.
          showDuration: const Duration(seconds: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars_rounded, size: 40, color: color),
              const SizedBox(width: 8),
              Text(
                '$streak',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionLabel extends StatefulWidget {
  const _VersionLabel();

  @override
  State<_VersionLabel> createState() => _VersionLabelState();
}

class _VersionLabelState extends State<_VersionLabel> {
  String? _version;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = _version == null ? '' : 'v${_version!}';
    return Text(
      text,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}
