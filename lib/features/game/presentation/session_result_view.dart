import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:dual_n_back/core/audio/audio_provider.dart';
import 'package:dual_n_back/core/audio/audio_service.dart';
import 'package:dual_n_back/features/achievements/application/achievement.dart';
import 'package:dual_n_back/features/achievements/application/achievements_provider.dart';
import 'package:dual_n_back/features/game/application/game_notifier.dart';
import 'package:dual_n_back/features/game/domain/adaptive_n.dart';
import 'package:dual_n_back/features/game/domain/game_session.dart';
import 'package:dual_n_back/features/game/domain/response_evaluator.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/presentation/game_screen.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Accuracy threshold above which the result screen fires a celebratory
/// confetti burst + `victory.mp3`. Tuned for the current accuracy
/// formula (`hits / (hits + misses + falseAlarms)`) where >=90%
/// indicates a near-flawless session.
const double _celebrationAccuracy = 0.9;

/// Accuracy threshold at or below which the result screen plays
/// `fail.mp3`. Mirrors the celebration cutoff at the other extreme so
/// the user gets explicit audio feedback for both very good and very
/// poor sessions; middle-band sessions stay silent.
const double _failAccuracy = 0.7;

class SessionResultView extends ConsumerStatefulWidget {
  const SessionResultView({required this.session, super.key});

  final GameSession session;

  @override
  ConsumerState<SessionResultView> createState() => _SessionResultViewState();
}

class _SessionResultViewState extends ConsumerState<SessionResultView> {
  late final ConfettiController _leftConfetti;
  late final ConfettiController _rightConfetti;
  bool _outcomeAnnounced = false;

  @override
  void initState() {
    super.initState();
    _leftConfetti = ConfettiController(duration: const Duration(seconds: 1));
    _rightConfetti = ConfettiController(duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceOutcome());
  }

  @override
  void dispose() {
    _leftConfetti.dispose();
    _rightConfetti.dispose();
    super.dispose();
  }

  /// Fires the appropriate end-of-session effects exactly once per
  /// result screen: confetti + `victory.mp3` for >=90% accuracy,
  /// `fail.mp3` for <=70%, silent middle band otherwise. Guarded by
  /// [_outcomeAnnounced] so a rebuild (e.g. theme/locale change) doesn't
  /// replay the burst or re-trigger the sound.
  void _announceOutcome() {
    if (_outcomeAnnounced) return;
    final score = widget.session.finalScore;
    if (score == null) return;
    final accuracy = score.overallAccuracy;
    if (accuracy >= _celebrationAccuracy) {
      _outcomeAnnounced = true;
      _leftConfetti.play();
      _rightConfetti.play();
      unawaited(ref.read(audioServiceProvider).playUiSound(UiSound.victory));
    } else if (accuracy <= _failAccuracy) {
      _outcomeAnnounced = true;
      unawaited(ref.read(audioServiceProvider).playUiSound(UiSound.fail));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final session = widget.session;
    final score = session.finalScore!;
    final newN = session.newN!;
    final adjustment = _adjustment(session.n, newN);
    final adaptiveMode = ref.watch(
      settingsProvider.select((s) => s.adaptiveMode),
    );
    // The just-finished session is already persisted by the time this
    // screen builds, so `sessionsTodayCountProvider` reflects it. Show
    // the daily-goal banner on every result screen after the goal is
    // hit (not just the threshold-crossing session) — it's a quick
    // positive confirmation that today's quota is in the bag.
    final dailyGoal = ref.watch(
      settingsProvider.select((s) => s.dailyGoalSessions),
    );
    final sessionsToday = ref.watch(sessionsTodayCountProvider);
    final dailyGoalReached = dailyGoal > 0 && sessionsToday >= dailyGoal;
    // Confetti reuses the player's customised stimulus palette so the
    // celebration matches the colours they just saw in-game.
    final confettiPalette = [
      for (final c in ref.watch(settingsProvider.select((s) => s.colors)))
        Color(c),
    ];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(child: _AccuracyGauge(accuracy: score.overallAccuracy)),
              const SizedBox(height: 16),
              Text(
                l.resultTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              if (adaptiveMode) ...[
                const SizedBox(height: 16),
                _AdjustmentBadge(
                  currentN: session.n,
                  newN: newN,
                  adjustment: adjustment,
                ),
              ],
              if (dailyGoalReached) ...[
                const SizedBox(height: 16),
                Text(
                  l.resultDailyGoalReached,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
              if (session.newlyEarnedAchievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                _NewlyEarnedSection(ids: session.newlyEarnedAchievements),
              ],
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (final entry in score.perChannel.entries)
                      _ChannelCard(channel: entry.key, score: entry.value),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(gameNotifierProvider.notifier).reset();
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text(l.resultClose),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref.read(gameNotifierProvider.notifier).start(
                              n: newN,
                              activeChannels: session.activeChannels,
                            );
                      },
                      child: Text(l.resultAgain),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Two cannons fixed in the upper corners, blasting toward the
        // center-down. IgnorePointer so they never intercept taps on the
        // buttons below.
        IgnorePointer(
          child: Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _leftConfetti,
              blastDirection: math.pi / 4, // down-right
              emissionFrequency: 0.04,
              maxBlastForce: 28,
              minBlastForce: 12,
              gravity: 0.25,
              colors: confettiPalette,
            ),
          ),
        ),
        IgnorePointer(
          child: Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _rightConfetti,
              blastDirection: 3 * math.pi / 4, // down-left
              emissionFrequency: 0.04,
              maxBlastForce: 28,
              minBlastForce: 12,
              gravity: 0.25,
              colors: confettiPalette,
            ),
          ),
        ),
      ],
    );
  }

  NAdjustment _adjustment(int oldN, int newN) {
    if (newN > oldN) return NAdjustment.advance;
    if (newN < oldN) return NAdjustment.regress;
    return NAdjustment.hold;
  }
}


class _AccuracyGauge extends StatelessWidget {
  const _AccuracyGauge({required this.accuracy});

  /// 0..1
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final clamped = accuracy.clamp(0.0, 1.0);
    final color = clamped >= 0.8
        ? scheme.primary
        : (clamped < 0.5 ? scheme.error : scheme.tertiary);

    return SizedBox(
      width: 160,
      height: 160,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 12,
                  color: scheme.surfaceContainerHighest,
                ),
              ),
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  color: color,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.resultAccuracyLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(value * 100).round()}%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdjustmentBadge extends StatelessWidget {
  const _AdjustmentBadge({
    required this.currentN,
    required this.newN,
    required this.adjustment,
  });

  final int currentN;
  final int newN;
  final NAdjustment adjustment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = AppLocalizations.of(context);
    final (icon, color) = switch (adjustment) {
      NAdjustment.advance => (Icons.trending_up, scheme.primary),
      NAdjustment.regress => (Icons.trending_down, scheme.error),
      NAdjustment.hold => (Icons.trending_flat, scheme.tertiary),
    };
    final labelStyle = TextStyle(
      color: color,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
    final numberStyle = labelStyle.copyWith(fontWeight: FontWeight.w700);

    // For advance/regress: "{label} {oldN} {icon} {newN}".
    // For hold: keep the single "Level held: N = {n}" string with the
    // trending_flat icon as a prefix — there's no second number to put
    // the icon between.
    final Widget content;
    switch (adjustment) {
      case NAdjustment.advance:
      case NAdjustment.regress:
        final label = adjustment == NAdjustment.advance
            ? l.resultLevelUpLabel
            : l.resultLevelDownLabel;
        content = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(width: 8),
            Text('$currentN', style: numberStyle),
            const SizedBox(width: 8),
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text('$newN', style: numberStyle),
          ],
        );
      case NAdjustment.hold:
        // Hold-case has no second N to put an arrow between, so we
        // skip the trending_flat icon entirely — the bare label reads
        // better than label + irrelevant horizontal-arrow glyph.
        content = Text(l.resultLevelHold(currentN), style: labelStyle);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Center(child: content),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.channel, required this.score});

  final ChannelType channel;
  final ChannelScore score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  channelLabel(context, channel),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(score.accuracy * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score.accuracy,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _stat(l.statHits, score.hits),
                _stat(l.statMisses, score.misses),
                _stat(l.statFalseAlarms, score.falseAlarms),
                _stat(l.statCorrectRejections, score.correctRejections),
                _stat(l.statDPrime, score.dPrime.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, Object value) => Text(
        '$label: $value',
        style: const TextStyle(fontSize: 13),
      );
}

/// Compact horizontal strip of achievements that flipped from un-earned
/// to earned by completing the current session. Hidden by the parent when
/// the list is empty, so this widget can assume `ids` is non-empty.
class _NewlyEarnedSection extends ConsumerWidget {
  const _NewlyEarnedSection({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(achievementsCatalogProvider);
    final byId = {for (final a in catalog) a.id: a};
    final achievements = [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
    if (achievements.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.resultAchievementsUnlockedTitle(achievements.length),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          // 20% shorter than the original 96px to keep the strip compact
          // now that each chip carries an extra description line.
          height: 77,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: achievements.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) =>
                _NewlyEarnedChip(achievement: achievements[i]),
          ),
        ),
      ],
    );
  }
}

class _NewlyEarnedChip extends StatelessWidget {
  const _NewlyEarnedChip({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(achievement.icon, size: 28, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.localizedTitle(l),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.localizedDescription(l),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.75),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
