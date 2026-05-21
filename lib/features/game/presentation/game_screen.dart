import 'dart:async';

import 'package:dual_n_back/core/audio/feedback_kind.dart';
import 'package:dual_n_back/core/constants/feedback_colors.dart';
import 'package:dual_n_back/features/game/application/game_notifier.dart';
import 'package:dual_n_back/features/game/domain/game_session.dart';
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/game/presentation/grid_widget.dart';
import 'package:dual_n_back/features/game/presentation/session_result_view.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:dual_n_back/shared/widgets/channel_selection_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Localized labels per channel.
String channelLabel(BuildContext context, ChannelType c) {
  final l = AppLocalizations.of(context);
  return switch (c) {
    ChannelType.position => l.channelPosition,
    ChannelType.audio => l.channelAudio,
    ChannelType.color => l.channelColor,
    ChannelType.shape => l.channelShape,
  };
}

/// Icon used to represent a channel across the app (in-game match buttons,
/// settings layout editor, etc.). Single source of truth — reuse this
/// rather than redefining the mapping at the call site.
IconData channelIcon(ChannelType c) => switch (c) {
      ChannelType.position => Icons.grid_3x3,
      ChannelType.audio => Icons.volume_up,
      ChannelType.color => Icons.palette,
      ChannelType.shape => Icons.interests,
    };

/// Canonical session title in the game's own naming convention, e.g.
/// `"Single 10-Back"`, `"Dual 8-Back"`, `"Tri 5-Back"`, `"Quad 2-Back"`.
/// Kept in English in both locales because the term is a name-of-art
/// (matches the "Dual N-Back" app branding).
String sessionVariantTitle(int channelCount, int n) {
  final prefix = switch (channelCount) {
    1 => 'Single',
    2 => 'Dual',
    3 => 'Tri',
    _ => 'Quad',
  };
  return '$prefix $n-Back';
}

/// Result returned by the pause dialog.
enum _PauseChoice { resume, home }

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  /// Whether [status] is one of the active session phases where pausing
  /// makes sense (and where back-button should open the pause dialog).
  static bool _isActiveSession(GameStatus status) {
    return status == GameStatus.preparing ||
        status == GameStatus.countdown ||
        status == GameStatus.running ||
        status == GameStatus.paused;
  }

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // Auto-pause an in-progress session if the app gets minimised /
    // backgrounded. Listening to `onHide` (transitioning out of
    // visible) catches Android home-button, recents, and incoming
    // calls without firing on transient inactive states like a
    // notification shade pull-down on top of the foreground app.
    // The notifier's `pause()` is a no-op outside running/countdown,
    // so we don't need to gate the call ourselves.
    _lifecycleListener = AppLifecycleListener(
      onHide: _autoPause,
      onPause: _autoPause,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _autoPause() {
    if (!mounted) return;
    final status = ref.read(gameNotifierProvider).status;
    // Only intercept active mid-flight states. If the user is already
    // sitting on the pause overlay (or anywhere outside running/
    // countdown), don't stack another dialog on top of whatever they
    // already had open.
    if (status != GameStatus.running && status != GameStatus.countdown) {
      return;
    }
    unawaited(_handleInterrupt(context));
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameNotifierProvider);
    final inSession = GameScreen._isActiveSession(session.status);
    final l = AppLocalizations.of(context);

    final onResults = session.status == GameStatus.finished;
    return PopScope(
      // Block both active sessions (so back opens the pause dialog) and
      // the results screen (so back goes through reset → pop, matching
      // the Close button instead of leaving stale finished state behind).
      canPop: !inSession && !onResults,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (onResults) {
          ref.read(gameNotifierProvider.notifier).reset();
          if (context.mounted) context.pop();
          return;
        }
        // Before the user hits Play, there's nothing to pause — skip
        // the dialog and just go home, mirroring the natural mental
        // model of "I never started, let me back out cleanly".
        if (session.status == GameStatus.preparing) {
          ref.read(gameNotifierProvider.notifier).reset();
          if (context.mounted) context.pop();
          return;
        }
        await _handleInterrupt(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: onResults
              ? Text(
                  sessionVariantTitle(
                    session.activeChannels.length,
                    session.n,
                  ),
                )
              : null,
          actions: [
            if (inSession)
              IconButton(
                icon: const Icon(Icons.pause),
                tooltip: l.pauseTooltip,
                onPressed: () => _handleInterrupt(context),
              ),
          ],
        ),
        body: SafeArea(
          child: switch (session.status) {
            GameStatus.idle ||
            GameStatus.aborted =>
              const _StartView(),
            GameStatus.preparing ||
            GameStatus.countdown ||
            GameStatus.running ||
            GameStatus.paused =>
              _RunningView(session: session),
            GameStatus.finished => SessionResultView(session: session),
          },
        ),
      ),
    );
  }

  /// Pauses the session (if applicable) and shows the pause dialog.
  /// Resumes or navigates home based on the user's choice.
  Future<void> _handleInterrupt(BuildContext context) async {
    final notifier = ref.read(gameNotifierProvider.notifier);
    final l = AppLocalizations.of(context);
    notifier.pause();

    final choice = await showDialog<_PauseChoice>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.pauseDialogTitle),
        content: Text(l.pauseDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_PauseChoice.home),
            child: Text(l.pauseDialogHome),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_PauseChoice.resume),
            child: Text(l.pauseDialogResume),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (choice == _PauseChoice.home) {
      notifier.reset();
      context.go('/');
    } else {
      // Resume on explicit choice or dialog dismissal.
      notifier.resume();
    }
  }
}

class _StartView extends ConsumerStatefulWidget {
  const _StartView();

  @override
  ConsumerState<_StartView> createState() => _StartViewState();
}

class _StartViewState extends ConsumerState<_StartView> {
  Set<ChannelType>? _active;
  int? _n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    // Seed local override from settings the first time we render.
    final active = _active ?? settings.defaultChannels;
    final n = (_n ?? settings.initialN).clamp(settings.minN, settings.maxN);
    final canStart = active.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'N-back',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.gameInstructions,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Text(l.gameChannelsLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ChannelSelectionGrid(
            selected: active,
            onChanged: (next) => setState(() => _active = next),
          ),
          const SizedBox(height: 24),
          Text(l.gameLevelLabel(n), style: theme.textTheme.titleMedium),
          Slider(
            value: n.toDouble(),
            min: settings.minN.toDouble(),
            max: settings.maxN.toDouble(),
            divisions: settings.maxN - settings.minN,
            label: 'N = $n',
            onChanged: (v) => setState(() => _n = v.round()),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: canStart
                ? () {
                    ref
                        .read(gameNotifierProvider.notifier)
                        .start(n: n, activeChannels: active);
                  }
                : null,
            icon: const Icon(Icons.play_arrow),
            label: Text(
              canStart ? l.gameStartButton : l.gameStartHintNoChannels,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunningView extends ConsumerWidget {
  const _RunningView({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trial = session.currentTrial;
    final frame = trial?.frame;
    final isRunning = session.status == GameStatus.running;
    final hasPosition =
        session.activeChannels.contains(ChannelType.position);
    final position = frame != null && hasPosition && isRunning
        ? frame[ChannelType.position]
        : null;
    final color = frame != null &&
            session.activeChannels.contains(ChannelType.color) &&
            isRunning
        ? frame[ChannelType.color]
        : null;
    final shape = frame != null &&
            session.activeChannels.contains(ChannelType.shape) &&
            isRunning
        ? frame[ChannelType.shape]
        : null;

    // Position values map to cell indices: 0..7 → 8 non-center cells by
    // default (Jaeggi), 0..8 → all 9 cells when the user opted in via the
    // `allowCenterPosition` setting.
    final allowCenter = ref.watch(
      settingsProvider.select((s) => s.allowCenterPosition),
    );
    final activeCell = position != null
        ? positionToGridCell(position, centerAllowed: allowCenter)
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hud(session: session),
          const SizedBox(height: 16),
          _GridStage(
            session: session,
            child: hasPosition
                ? NBackGrid(
                    activeCellIndex: activeCell,
                    highlight: session.stimulusVisible,
                    colorIndex: color,
                    shapeIndex: shape,
                    fadeDuration: Duration(
                      milliseconds:
                          ref.watch(settingsProvider).stimulusFadeMs,
                    ),
                    style: ref.watch(settingsProvider).gridStyle,
                    showFixation:
                        ref.watch(settingsProvider).showFixationCross &&
                            session.status != GameStatus.preparing &&
                            session.status != GameStatus.countdown,
                    centerIsPositionTarget: allowCenter,
                  )
                : NBackSingleCell(
                    highlight: session.stimulusVisible && isRunning,
                    colorIndex: color,
                    shapeIndex: shape,
                    fadeDuration: Duration(
                      milliseconds:
                          ref.watch(settingsProvider).stimulusFadeMs,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: _MatchButtons(session: session),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stacks the grid with a Play button, countdown number, or pause overlay
/// depending on the current game status.
class _GridStage extends ConsumerWidget {
  const _GridStage({required this.session, required this.child});

  final GameSession session;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: child),
          if (session.status == GameStatus.preparing)
            _PlayOverlay(
              onTap: () => ref.read(gameNotifierProvider.notifier).play(),
            ),
          if (session.status == GameStatus.countdown &&
              session.countdownValue != null)
            _CountdownOverlay(value: session.countdownValue!),
          if (session.status == GameStatus.paused) const _PauseOverlay(),
        ],
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.6),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.pause_circle_filled,
        size: 96,
        color: scheme.primary.withValues(alpha: 0.9),
      ),
    );
  }
}

class _PlayOverlay extends StatelessWidget {
  const _PlayOverlay({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 80,
              color: scheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownOverlay extends StatelessWidget {
  const _CountdownOverlay({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Text(
          '$value',
          key: ValueKey(value),
          style: TextStyle(
            fontSize: 160,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
            shadows: [
              Shadow(
                color: scheme.primary.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = session.totalTrials == 0
        ? 0.0
        : session.displayedTrialNumber / session.totalTrials;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('N = ${session.n}', style: theme.textTheme.titleLarge),
            Text(
              '${session.displayedTrialNumber} / ${session.totalTrials}',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}

class _MatchButtons extends ConsumerWidget {
  const _MatchButtons({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider.notifier);
    final isRunning = session.status == GameStatus.running;
    final isWarmup = session.currentTrialIndex < session.n;
    final disabled = !isRunning || isWarmup;
    final layout = ref.watch(settingsProvider).channelLayout;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final channel in layout)
          if (session.activeChannels.contains(channel))
            _ChannelMatchButton(
              channel: channel,
              locked: session.lockedChannels.contains(channel),
              disabled: disabled,
              feedback: session.channelFeedback[channel],
              onPressed: () => notifier.registerMatch(channel),
            )
          else
            const SizedBox.shrink(),
      ],
    );
  }
}

class _ChannelMatchButton extends StatelessWidget {
  const _ChannelMatchButton({
    required this.channel,
    required this.locked,
    required this.disabled,
    required this.feedback,
    required this.onPressed,
  });

  final ChannelType channel;
  final bool locked;
  final bool disabled;

  /// When non-null, paints the button with the corresponding feedback
  /// colour for the duration of the flash. Cleared by the notifier after
  /// 500 ms.
  final FeedbackKind? feedback;

  final VoidCallback onPressed;

  Color? _feedbackColor() => switch (feedback) {
        FeedbackKind.correct => FeedbackColors.correct,
        FeedbackKind.incorrect => FeedbackColors.incorrect,
        FeedbackKind.missed => FeedbackColors.missed,
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final canPress = !locked && !disabled;
    final flash = _feedbackColor();
    // Feedback flash overrides the tonal background AND forces the
    // foreground (icon + label) to a high-contrast colour so the label
    // stays legible on the orange/green/red wash regardless of theme.
    final style = flash == null
        ? FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
          )
        : FilledButton.styleFrom(
            backgroundColor: flash,
            foregroundColor: Colors.black87,
            disabledBackgroundColor: flash,
            disabledForegroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
          );
    return FilledButton.tonal(
      onPressed: canPress ? onPressed : null,
      style: style,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(channelIcon(channel), size: 40),
          const SizedBox(height: 8),
          Text(channelLabel(context, channel)),
        ],
      ),
    );
  }
}
