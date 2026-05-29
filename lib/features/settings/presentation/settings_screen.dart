import 'dart:async';

import 'package:dual_n_back/core/audio/audio_provider.dart';
import 'package:dual_n_back/core/constants/app_theme_mode.dart';
import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/game/domain/stimulus_generator.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:dual_n_back/shared/widgets/channel_layout_editor.dart';
import 'package:dual_n_back/shared/widgets/estimated_duration_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: l.settingsResetTooltip,
            onPressed: () => _confirmReset(context, notifier),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _Section(
            title: l.settingsSectionLanguage,
            child: _LocalePicker(
              current: settings.localeCode,
              onChanged: (code) => unawaited(notifier.updateLocale(code)),
            ),
          ),
          _Section(
            title: l.settingsSectionTheme,
            child: _ThemeModePicker(
              current: settings.themeMode,
              onChanged: (mode) =>
                  unawaited(notifier.updateThemeMode(mode)),
            ),
          ),
          _Section(
            title: l.settingsSectionGridStyle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SegmentedButton<GridStyle>(
                    expandedInsets: EdgeInsets.zero,
                    segments: [
                      ButtonSegment(
                        value: GridStyle.classic,
                        label: Text(l.settingsGridStyleClassic),
                      ),
                      ButtonSegment(
                        value: GridStyle.tile,
                        label: Text(l.settingsGridStyleTile),
                      ),
                    ],
                    selected: {settings.gridStyle},
                    onSelectionChanged: (next) =>
                        unawaited(notifier.updateGridStyle(next.first)),
                  ),
                ),
                SwitchListTile(
                  title: Text(l.settingsShowFixationCross),
                  value: settings.showFixationCross,
                  onChanged: (v) => unawaited(
                    notifier.updateShowFixationCross(enabled: v),
                  ),
                ),
                SwitchListTile(
                  title: Text(l.settingsAllowCenterPosition),
                  value: settings.allowCenterPosition,
                  onChanged: (v) => unawaited(
                    notifier.updateAllowCenterPosition(enabled: v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    l.settingsAllowCenterPositionHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: l.settingsSectionSound,
            child: Column(
              children: [
                _SliderTile(
                  label: l.settingsVolume,
                  value: settings.volume,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  display: '${(settings.volume * 100).round()}%',
                  onChanged: notifier.updateVolume,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.settingsVoice,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<AudioVoice>(
                        expandedInsets: EdgeInsets.zero,
                        segments: [
                          ButtonSegment(
                            value: AudioVoice.female,
                            label: Text(l.settingsVoiceFemale),
                          ),
                          ButtonSegment(
                            value: AudioVoice.male,
                            label: Text(l.settingsVoiceMale),
                          ),
                        ],
                        selected: {settings.audioVoice},
                        onSelectionChanged: (next) =>
                            unawaited(notifier.updateAudioVoice(next.first)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.settingsLetters,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          _GroupResetButton(
                            groupTitle: l.settingsLetters,
                            onConfirm: () =>
                                unawaited(notifier.resetAudioLetters()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _AudioLetterGrid(
                        selected: settings.audioLetters,
                        onChanged: (next) =>
                            unawaited(notifier.updateAudioLetters(next)),
                        onPreview: (letter) => unawaited(
                          ref
                              .read(audioServiceProvider)
                              .playLetterByName(letter),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.settingsLettersHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: l.settingsSectionColors,
            trailing: _GroupResetButton(
              groupTitle: l.settingsSectionColors,
              onConfirm: () => unawaited(notifier.resetColors()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ColorPaletteGrid(
                    colors: settings.colors,
                    onTapColor: (index) async {
                      final initial = Color(settings.colors[index]);
                      final picked = await _openColorPicker(
                        context,
                        initial: initial,
                      );
                      if (picked == null) return;
                      unawaited(
                        notifier.updateColor(index, _toArgb(picked)),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.settingsColorsHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: l.settingsSectionDefaultChannels,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l.settingsLayoutHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  ChannelLayoutEditor(
                    layout: settings.channelLayout,
                    selected: settings.defaultChannels,
                    onLayoutChanged: (next) =>
                        unawaited(notifier.updateChannelLayout(next)),
                    onSelectionChanged: (next) =>
                        unawaited(notifier.updateChannels(next)),
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: l.settingsSectionLevel,
            trailing: _GroupResetButton(
              groupTitle: l.settingsSectionLevel,
              onConfirm: () => unawaited(notifier.resetLevelN()),
            ),
            child: Column(
              children: [
                _SliderTile(
                  label: l.settingsInitialN,
                  value: settings.initialN.toDouble(),
                  min: settings.minN.toDouble(),
                  max: settings.maxN.toDouble(),
                  divisions: settings.maxN - settings.minN,
                  display: '${settings.initialN}',
                  onChanged: (v) => notifier.updateInitialN(v.round()),
                ),
                _RangeSliderTile(
                  label: l.settingsRangeN,
                  start: settings.minN.toDouble(),
                  end: settings.maxN.toDouble(),
                  min: NBackDefaults.minN.toDouble(),
                  max: NBackDefaults.maxN.toDouble(),
                  display: l.settingsRangeNValue(settings.minN, settings.maxN),
                  onChanged: (start, end) => notifier.updateNRange(
                    start.round(),
                    end.round(),
                  ),
                ),
                _SliderTile(
                  label: l.settingsMatchProbability,
                  value: settings.matchProbability,
                  min: 0.1,
                  max: 0.5,
                  divisions: 8,
                  display: l.settingsPercent(
                    (settings.matchProbability * 100).round(),
                  ),
                  onChanged: notifier.updateMatchProbability,
                ),
                _SliderTile(
                  label: l.settingsMatchProbabilityJitter,
                  value: settings.matchProbabilityJitter,
                  min: 0,
                  max: 1,
                  divisions: 20,
                  display: l.settingsPercent(
                    (settings.matchProbabilityJitter * 100).round(),
                  ),
                  onChanged: notifier.updateMatchProbabilityJitter,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    _matchProbabilityHint(l, settings),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SwitchListTile(
                  title: Text(l.settingsAdaptive),
                  subtitle: Text(
                    l.settingsAdaptiveSubtitle(
                      (settings.advanceThreshold * 100).round(),
                      (settings.regressThreshold * 100).round(),
                    ),
                  ),
                  value: settings.adaptiveMode,
                  onChanged: (v) =>
                      notifier.updateAdaptiveMode(enabled: v),
                ),
                _RangeSliderTile(
                  label: l.settingsAdaptiveThresholds,
                  start: settings.regressThreshold,
                  end: settings.advanceThreshold,
                  min: SettingsModel.minAccuracyThreshold,
                  max: SettingsModel.maxAccuracyThreshold,
                  divisions: ((SettingsModel.maxAccuracyThreshold -
                              SettingsModel.minAccuracyThreshold) /
                          SettingsModel.accuracyThresholdStep)
                      .round(),
                  minGap: SettingsModel.minAccuracyThresholdGap,
                  enabled: settings.adaptiveMode,
                  display: l.settingsAdaptiveThresholdsValue(
                    (settings.regressThreshold * 100).round(),
                    (settings.advanceThreshold * 100).round(),
                  ),
                  onChanged: (start, end) =>
                      notifier.updateAdaptiveThresholds(
                    regress: start,
                    advance: end,
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: l.settingsSectionTimings,
            trailing: _GroupResetButton(
              groupTitle: l.settingsSectionTimings,
              onConfirm: () => unawaited(notifier.resetTimings()),
            ),
            child: Column(
              children: [
                _SliderTile(
                  label: l.settingsTrialsPerSession,
                  value: settings.trialsPerSession.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 45,
                  display: '${settings.trialsPerSession}',
                  onChanged: (v) =>
                      notifier.updateTrialsPerSession(v.round()),
                ),
                _SliderTile(
                  label: l.settingsStimulusDuration,
                  value: settings.stimulusDurationMs.toDouble(),
                  min: 100,
                  max: 3500,
                  divisions: 34,
                  display: l.settingsMs(settings.stimulusDurationMs),
                  onChanged: (v) =>
                      notifier.updateStimulusDuration(v.round()),
                ),
                _SliderTile(
                  label: l.settingsStimulusFade,
                  value: settings.stimulusFadeMs.toDouble(),
                  min: SettingsModel.minStimulusFadeMs.toDouble(),
                  max: SettingsModel.maxStimulusFadeMs.toDouble(),
                  divisions: (SettingsModel.maxStimulusFadeMs -
                          SettingsModel.minStimulusFadeMs) ~/
                      SettingsModel.stimulusFadeStepMs,
                  display: l.settingsMs(settings.stimulusFadeMs),
                  onChanged: (v) =>
                      notifier.updateStimulusFadeMs(v.round()),
                ),
                _SliderTile(
                  label: l.settingsIsi,
                  value: settings.isiMs.toDouble(),
                  min: 1000,
                  max: 10000,
                  divisions: 18,
                  display: l.settingsMs(settings.isiMs),
                  onChanged: (v) => notifier.updateIsi(v.round()),
                ),
                EstimatedDurationTile(
                  // Total trials per session = warm-up (N) + scored trials.
                  // Each trial occupies `stimulusDurationMs + isiMs` of
                  // wall-clock time — same pooling the statistics summary
                  // uses (`totalTrials * (stimulusDurationMs + isiMs)`).
                  ms: (settings.initialN + settings.trialsPerSession) *
                      (settings.stimulusDurationMs + settings.isiMs),
                ),
              ],
            ),
          ),
          _Section(
            title: l.settingsSectionFeedback,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l.settingsFeedbackVisualPress),
                  value: settings.feedbackVisualOnPress,
                  onChanged: (v) => unawaited(
                    notifier.updateFeedbackVisualOnPress(enabled: v),
                  ),
                ),
                SwitchListTile(
                  title: Text(l.settingsFeedbackAudioPress),
                  value: settings.feedbackAudioOnPress,
                  onChanged: (v) => unawaited(
                    notifier.updateFeedbackAudioOnPress(enabled: v),
                  ),
                ),
                SwitchListTile(
                  title: Text(l.settingsFeedbackVisualMiss),
                  value: settings.feedbackVisualOnMiss,
                  onChanged: (v) => unawaited(
                    notifier.updateFeedbackVisualOnMiss(enabled: v),
                  ),
                ),
                SwitchListTile(
                  title: Text(l.settingsFeedbackAudioMiss),
                  value: settings.feedbackAudioOnMiss,
                  onChanged: (v) => unawaited(
                    notifier.updateFeedbackAudioOnMiss(enabled: v),
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: l.settingsSectionDailyGoal,
            child: Column(
              children: [
                _SliderTile(
                  label: l.settingsDailyGoal,
                  value: settings.dailyGoalSessions.toDouble(),
                  min: SettingsModel.minDailyGoalSessions.toDouble(),
                  max: SettingsModel.maxDailyGoalSessions.toDouble(),
                  divisions: SettingsModel.maxDailyGoalSessions -
                      SettingsModel.minDailyGoalSessions,
                  display: '${settings.dailyGoalSessions}',
                  onChanged: (v) => notifier.updateDailyGoalSessions(v.round()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        l.settingsRestDays,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      _RestDayGrid(
                        selected: settings.restDays,
                        onChanged: (next) =>
                            unawaited(notifier.updateRestDays(next)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.settingsRestDaysHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: l.settingsSectionNotifications,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l.settingsNotificationsEnabled),
                  value: settings.notificationsEnabled,
                  onChanged: (v) => unawaited(
                    notifier.updateNotificationsEnabled(enabled: v),
                  ),
                ),
                ListTile(
                  title: Text(l.settingsNotificationTime),
                  enabled: settings.notificationsEnabled,
                  trailing: Text(
                    _formatNotificationTime(
                      settings.notificationTimeMinutes,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: settings.notificationsEnabled
                      ? () => _pickNotificationTime(context, ref, settings)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Text(
                    l.settingsNotificationsRestDaysHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// "HH:mm" rendering of the persisted minutes-from-midnight value.
  /// Zero-pads both components so the result tile reads consistently
  /// regardless of locale.
  String _formatNotificationTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickNotificationTime(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
  ) async {
    final initial = TimeOfDay(
      hour: settings.notificationTimeMinutes ~/ 60,
      minute: settings.notificationTimeMinutes % 60,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    await ref.read(settingsProvider.notifier).updateNotificationTime(
          hour: picked.hour,
          minute: picked.minute,
        );
  }

  /// Builds the localized hint shown under the "match probability" /
  /// "jitter" sliders. Uses the same per-channel `ceil` + `floor` math
  /// that the stimulus generator applies, so the numbers the user sees
  /// here are exactly what they get in a generated session.
  String _matchProbabilityHint(AppLocalizations l, SettingsModel s) {
    final trials = s.trialsPerSession;
    // Same epsilon-protected ceil as in the stimulus generator — keeps
    // the displayed match count in sync with what a session actually
    // produces (20 * 0.3 must show 6 matches, not 7).
    final base =
        (trials * s.matchProbability - StimulusGenerator.matchCeilEpsilon)
            .ceil()
            .clamp(1, trials);
    final jitter = (base * s.matchProbabilityJitter).floor();
    if (jitter == 0) {
      return l.settingsMatchProbabilityHint(base, trials);
    }
    final main = l.settingsMatchProbabilityHintJitter(base, jitter, trials);
    // When jitter ≥ base, the lower end of the range (base - jitter) is
    // ≤ 0 and gets clamped to 1 by the generator. Make that explicit so
    // the user doesn't think they might get a zero-match session.
    if (jitter >= base) {
      return '$main ${l.settingsMatchProbabilityHintMinMatch}';
    }
    return main;
  }

  void _confirmReset(BuildContext context, SettingsNotifier notifier) {
    final l = AppLocalizations.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.settingsResetTitle),
          content: Text(l.settingsResetContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                unawaited(notifier.resetToDefaults());
                Navigator.of(ctx).pop();
              },
              child: Text(l.commonReset),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;

  /// Optional widget rendered to the right of the section title — used
  /// for per-group reset buttons (Level N, Timings).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, trailing == null ? 8 : 0, 16, 4),
            child: trailing == null
                ? titleText
                : Row(
                    children: [
                      Expanded(child: titleText),
                      trailing!,
                    ],
                  ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Compact reset icon-button used to the right of group titles
/// ("Letters", "Level N", "Timings"). Opens a confirmation dialog
/// before invoking [onConfirm].
class _GroupResetButton extends StatelessWidget {
  const _GroupResetButton({
    required this.groupTitle,
    required this.onConfirm,
  });

  final String groupTitle;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        visualDensity: VisualDensity.compact,
        tooltip: l.settingsResetGroupTooltip,
        icon: const Icon(Icons.restore),
        onPressed: () => _confirm(context, l),
      ),
    );
  }

  void _confirm(BuildContext context, AppLocalizations l) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(groupTitle),
          content: Text(l.settingsResetContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                onConfirm();
                Navigator.of(ctx).pop();
              },
              child: Text(l.commonReset),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodyLarge),
              Text(
                display,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RangeSliderTile extends StatelessWidget {
  const _RangeSliderTile({
    required this.label,
    required this.start,
    required this.end,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
    this.divisions,
    this.minGap = 1,
    this.enabled = true,
  });

  final String label;
  final double start;
  final double end;
  final double min;
  final double max;
  final String display;
  final void Function(double start, double end) onChanged;

  /// Optional number of discrete steps on the slider. Defaults to one
  /// step per integer unit (`(max - min).round()`), matching the
  /// integer N-range tile. Pass an explicit value when the underlying
  /// units are fractional (e.g. percentages stored as 0..1).
  final int? divisions;

  /// Minimum allowed distance between the two handles, in the slider's
  /// own units. Defaults to 1 (the previous integer-N behaviour).
  final double minGap;

  /// When false, the slider is non-interactive and label/value are
  /// rendered in a muted colour. Used to "grey out" the tile when a
  /// related toggle (e.g. adaptive mode) is off.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedLabel = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
    );
    final mutedValue = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.primary.withValues(alpha: 0.5),
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: enabled ? theme.textTheme.bodyLarge : mutedLabel,
              ),
              Text(
                display,
                style: enabled
                    ? theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      )
                    : mutedValue,
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(
              start.clamp(min, max),
              end.clamp(min, max),
            ),
            min: min,
            max: max,
            divisions: divisions ?? (max - min).round(),
            onChanged: enabled
                ? (range) {
                    if (range.end - range.start < minGap) return;
                    onChanged(range.start, range.end);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

/// 9 / 9 / 8 grid of all English letters used as audio stimuli. Tap toggles
/// inclusion in the active set; tapping a letter on also plays a preview
/// so the user knows what they just enabled. Removing a letter is blocked
/// when the active set would drop below [SettingsModel.minAudioLetters].
class _AudioLetterGrid extends StatelessWidget {
  const _AudioLetterGrid({
    required this.selected,
    required this.onChanged,
    required this.onPreview,
  });

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final ValueChanged<String> onPreview;

  static const List<int> _rowSizes = [9, 9, 8];

  void _toggle(String letter) {
    final selectedSet = selected.toSet();
    final isOn = selectedSet.contains(letter);
    if (isOn) {
      if (selected.length <= SettingsModel.minAudioLetters) return;
      onChanged([
        for (final l in selected)
          if (l != letter) l,
      ]);
    } else {
      // Preview BEFORE persisting the new selection: the audio service
      // listener triggers setLetters() on the settings update, which
      // disposes/rebuilds players. If we toggled first the preview would
      // race the reload and silently no-op. Playing first means the letter
      // is still outside _letters and goes through the preview-cache path,
      // independent of the active-set lifecycle.
      onPreview(letter);
      onChanged([...selected, letter]);
    }
  }

  @override
  Widget build(BuildContext context) {
    const letters = SettingsModel.availableAudioLetters;
    final selectedSet = selected.toSet();
    final atMinimum = selected.length <= SettingsModel.minAudioLetters;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 6.0;
        // Row 1 has the most cells (9) — base cell size on it so all rows
        // share the same cell height/width even though row 3 has fewer cells.
        final cellWidth =
            (constraints.maxWidth - spacing * (_rowSizes.first - 1)) /
                _rowSizes.first;
        // Pre-slice letters into rows so the build order is unambiguous.
        final rows = <List<String>>[];
        var offset = 0;
        for (final size in _rowSizes) {
          rows.add(letters.sublist(offset, offset + size));
          offset += size;
        }
        return Column(
          children: [
            for (var r = 0; r < rows.length; r++)
              Padding(
                padding: EdgeInsets.only(top: r == 0 ? 0 : spacing),
                child: Row(
                  children: [
                    for (var c = 0; c < rows[r].length; c++) ...[
                      if (c > 0) const SizedBox(width: spacing),
                      _AudioLetterCell(
                        letter: rows[r][c],
                        selected: selectedSet.contains(rows[r][c]),
                        size: cellWidth,
                        // Disable the tap target when removing this letter
                        // would drop the set below the minimum.
                        disabled:
                            atMinimum && selectedSet.contains(rows[r][c]),
                        onTap: () => _toggle(rows[r][c]),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AudioLetterCell extends StatelessWidget {
  const _AudioLetterCell({
    required this.letter,
    required this.selected,
    required this.size,
    required this.disabled,
    required this.onTap,
  });

  final String letter;
  final bool selected;
  final double size;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.primaryContainer : scheme.surfaceContainerLow;
    final fg = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurface.withValues(alpha: 0.45);
    final borderColor = selected
        ? scheme.primary
        : scheme.outlineVariant.withValues(alpha: 0.5);
    final borderWidth = selected ? 2.0 : 1.0;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            alignment: Alignment.center,
            child: Text(
              letter.toUpperCase(),
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single-row toggle grid for rest-day weekdays. Mirrors the look of
/// [_AudioLetterCell] but shows locale-aware abbreviated weekday labels
/// (`пн вт ср …` in Russian, `Mon Tue Wed …` in English) sourced from
/// `intl`. Caps selection at [SettingsModel.maxRestDays] — once the cap
/// is reached the remaining cell is disabled, matching the
/// "at-minimum disables removal" pattern from the audio-letter grid.
class _RestDayGrid extends StatelessWidget {
  const _RestDayGrid({required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  void _toggle(int weekday) {
    final next = {...selected};
    if (next.contains(weekday)) {
      next.remove(weekday);
    } else {
      if (next.length >= SettingsModel.maxRestDays) return;
      next.add(weekday);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    // 2024-01-01 was a Monday — use it as the reference for generating
    // localized weekday abbreviations through `intl`.
    final monday = DateTime(2024);
    final formatter = DateFormat.E(locale);
    final labels = [
      for (var i = 0; i < 7; i++)
        formatter.format(monday.add(Duration(days: i))),
    ];
    final atMax = selected.length >= SettingsModel.maxRestDays;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 6.0;
        final cellWidth = (constraints.maxWidth - spacing * 6) / 7;
        return Row(
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: spacing),
              _RestDayCell(
                label: labels[i],
                selected: selected.contains(i + 1),
                size: cellWidth,
                disabled: atMax && !selected.contains(i + 1),
                onTap: () => _toggle(i + 1),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RestDayCell extends StatelessWidget {
  const _RestDayCell({
    required this.label,
    required this.selected,
    required this.size,
    required this.disabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double size;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.primaryContainer : scheme.surfaceContainerLow;
    final fg = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurface.withValues(alpha: 0.45);
    final borderColor = selected
        ? scheme.primary
        : scheme.outlineVariant.withValues(alpha: 0.5);
    final borderWidth = selected ? 2.0 : 1.0;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Returns the 32-bit ARGB representation of [color]. Wraps the
/// modern `Color.toARGB32()` API in a tiny helper so call sites don't
/// have to deal with floating-point rounding manually.
int _toArgb(Color color) => color.toARGB32();

/// 4×2 grid of color swatches — visually mirrors [_AudioLetterGrid].
/// Tap fires [onTapColor] with the slot index (0..7) so the parent can
/// open the color picker and dispatch the resulting value back into
/// settings.
class _ColorPaletteGrid extends StatelessWidget {
  const _ColorPaletteGrid({
    required this.colors,
    required this.onTapColor,
  });

  final List<int> colors;
  final ValueChanged<int> onTapColor;

  static const int _cols = 8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 6.0;
        final cellWidth =
            (constraints.maxWidth - spacing * (_cols - 1)) / _cols;
        final rows = (colors.length / _cols).ceil();
        return Column(
          children: [
            for (var r = 0; r < rows; r++)
              Padding(
                padding: EdgeInsets.only(top: r == 0 ? 0 : spacing),
                child: Row(
                  children: [
                    for (var c = 0; c < _cols; c++) ...[
                      if (c > 0) const SizedBox(width: spacing),
                      Builder(
                        builder: (context) {
                          final index = r * _cols + c;
                          if (index >= colors.length) {
                            return SizedBox(width: cellWidth, height: cellWidth);
                          }
                          return _ColorSwatchCell(
                            color: Color(colors[index]),
                            size: cellWidth,
                            onTap: () => onTapColor(index),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ColorSwatchCell extends StatelessWidget {
  const _ColorSwatchCell({
    required this.color,
    required this.size,
    required this.onTap,
  });

  final Color color;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a modal color picker dialog seeded with [initial] and resolves
/// with the chosen colour (or `null` if dismissed).
Future<Color?> _openColorPicker(
  BuildContext context, {
  required Color initial,
}) {
  return showDialog<Color>(
    context: context,
    builder: (ctx) => _ColorPickerDialog(initial: initial),
  );
}

/// HSV-based color picker dialog. Three sliders (hue / saturation /
/// value) plus a live preview swatch. Returns the selected [Color] via
/// `Navigator.pop`. Kept dependency-free on purpose — the app only
/// needs basic picking; adding `flutter_colorpicker` for this would be
/// disproportionate.
class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initial});

  final Color initial;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
  }

  Color get _current => _hsv.toColor();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l.settingsColorPickerTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview swatch — fills the dialog width so the user sees
            // a realistic sample of the chosen colour.
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: _current,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PickerSlider(
              label: l.settingsColorPickerHue,
              value: _hsv.hue,
              min: 0,
              max: 360,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFFFFF00),
                  Color(0xFF00FF00),
                  Color(0xFF00FFFF),
                  Color(0xFF0000FF),
                  Color(0xFFFF00FF),
                  Color(0xFFFF0000),
                ],
              ),
              onChanged: (v) => setState(() => _hsv = _hsv.withHue(v)),
            ),
            _PickerSlider(
              label: l.settingsColorPickerSaturation,
              value: _hsv.saturation,
              min: 0,
              max: 1,
              gradient: LinearGradient(
                colors: [
                  HSVColor.fromAHSV(1, _hsv.hue, 0, _hsv.value).toColor(),
                  HSVColor.fromAHSV(1, _hsv.hue, 1, _hsv.value).toColor(),
                ],
              ),
              onChanged: (v) =>
                  setState(() => _hsv = _hsv.withSaturation(v)),
            ),
            _PickerSlider(
              label: l.settingsColorPickerValue,
              value: _hsv.value,
              min: 0,
              max: 1,
              gradient: LinearGradient(
                colors: [
                  HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 0)
                      .toColor(),
                  HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 1)
                      .toColor(),
                ],
              ),
              onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_current),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

/// Single slider tile used by [_ColorPickerDialog]. The gradient track
/// below the label gives a visual hint of the channel being scrubbed —
/// hue shows the full rainbow, saturation goes grey-to-saturated, value
/// goes black-to-color.
class _PickerSlider extends StatelessWidget {
  const _PickerSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.gradient,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final LinearGradient gradient;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          // Gradient strip stacked behind the slider gives the visual
          // hint for what the slider controls.
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  // Slim track so the gradient stays visible underneath.
                  trackHeight: 2,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocalePicker extends StatelessWidget {
  const _LocalePicker({required this.current, required this.onChanged});

  final String? current;
  final ValueChanged<String?> onChanged;

  static const _systemValue = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = <DropdownMenuEntry<String>>[
      DropdownMenuEntry(value: _systemValue, label: l.settingsLanguageSystem),
      DropdownMenuEntry(value: 'en', label: l.settingsLanguageEn),
      DropdownMenuEntry(value: 'ru', label: l.settingsLanguageRu),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownMenu<String>(
        initialSelection: current ?? _systemValue,
        expandedInsets: EdgeInsets.zero,
        dropdownMenuEntries: entries,
        onSelected: (v) => onChanged(v == null || v.isEmpty ? null : v),
      ),
    );
  }
}

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({required this.current, required this.onChanged});

  final AppThemeMode current;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final entries = <DropdownMenuEntry<AppThemeMode>>[
      DropdownMenuEntry(
        value: AppThemeMode.system,
        label: l.settingsThemeSystem,
      ),
      DropdownMenuEntry(
        value: AppThemeMode.light,
        label: l.settingsThemeLight,
      ),
      DropdownMenuEntry(
        value: AppThemeMode.dark,
        label: l.settingsThemeDark,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownMenu<AppThemeMode>(
        initialSelection: current,
        expandedInsets: EdgeInsets.zero,
        dropdownMenuEntries: entries,
        onSelected: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
