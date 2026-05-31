import 'package:dual_n_back/features/achievements/application/achievement.dart';
import 'package:dual_n_back/features/achievements/application/achievements_provider.dart';
import 'package:dual_n_back/features/achievements/domain/achievement_group.dart';
import 'package:dual_n_back/features/achievements/domain/achievement_progress.dart';
import 'package:dual_n_back/features/achievements/presentation/achievement_icon.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(achievementsCatalogProvider);
    final progress = ref.watch(achievementsProgressProvider);

    final byGroup = <AchievementGroup, List<Achievement>>{
      for (final g in AchievementGroup.values) g: <Achievement>[],
    };
    for (final a in catalog) {
      byGroup[a.group]!.add(a);
    }

    final earnedCount =
        progress.values.where((p) => p.earned).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.achievementsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: _EarnedCounter(
                earned: earnedCount,
                total: catalog.length,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            for (final group in AchievementGroup.values) ...[
              _GroupHeader(group: group),
              for (final a in byGroup[group]!)
                _AchievementCard(
                  achievement: a,
                  progress: progress[a.id] ??
                      const AchievementProgress.binary(earned: false),
                ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact "earned / total" pill in the AppBar's trailing slot. Lights up
/// once at least one achievement is earned; stays dim before that to avoid
/// visually competing with the title for a fresh user.
class _EarnedCounter extends StatelessWidget {
  const _EarnedCounter({required this.earned, required this.total});

  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final color = earned > 0
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.emoji_events_outlined, size: 22, color: color),
        const SizedBox(width: 6),
        Text(
          l.achProgressLabel(earned, total),
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final AchievementGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
      child: Text(
        _groupTitle(l, group),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

String _groupTitle(AppLocalizations l, AchievementGroup g) => switch (g) {
      AchievementGroup.milestones => l.achGroupMilestones,
      AchievementGroup.performance => l.achGroupPerformance,
      AchievementGroup.consistency => l.achGroupConsistency,
      AchievementGroup.resilience => l.achGroupResilience,
      AchievementGroup.exploration => l.achGroupExploration,
    };

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    required this.progress,
  });

  final Achievement achievement;
  final AchievementProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final earned = progress.earned;
    final iconColor = earned
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final titleColor = earned
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final showProgressBar =
        achievement.tracksProgress && !earned && progress.target != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AchievementIcon(
              id: achievement.id,
              earned: earned,
              size: 44,
              fallbackIcon: achievement.icon,
              fallbackColor: iconColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.localizedTitle(l),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                      ),
                      if (earned)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.check_circle,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.localizedDescription(l),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (showProgressBar) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.fraction,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.achProgressLabel(
                        progress.current ?? 0,
                        progress.target ?? 0,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
