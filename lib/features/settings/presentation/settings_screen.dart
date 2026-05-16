import 'dart:async';

import 'package:dual_n_back/core/audio/audio_provider.dart';
import 'package:dual_n_back/core/constants/app_theme_mode.dart';
import 'package:dual_n_back/core/constants/audio_voice.dart';
import 'package:dual_n_back/core/constants/grid_style.dart';
import 'package:dual_n_back/core/constants/nback_defaults.dart';
import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/settings/domain/settings_model.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:dual_n_back/shared/widgets/channel_layout_editor.dart';
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SegmentedButton<GridStyle>(
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
                SwitchListTile(
                  title: Text(l.settingsAdaptive),
                  subtitle: Text(l.settingsAdaptiveSubtitle),
                  value: settings.adaptiveMode,
                  onChanged: (v) =>
                      notifier.updateAdaptiveMode(enabled: v),
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
                  max: 1500,
                  divisions: 14,
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
  });

  final String label;
  final double start;
  final double end;
  final double min;
  final double max;
  final String display;
  final void Function(double start, double end) onChanged;

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
          RangeSlider(
            values: RangeValues(
              start.clamp(min, max),
              end.clamp(min, max),
            ),
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: (range) {
              if (range.end - range.start < 1) return;
              onChanged(range.start, range.end);
            },
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
