import 'dart:async';

import 'package:dual_n_back/features/settings/application/settings_notifier.dart';
import 'package:dual_n_back/features/settings/domain/preset.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dropdown to pick the active settings preset, optionally followed by
/// add / rename / delete action buttons.
///
/// Shared between the settings screen ([showActions] = true) and the
/// session-start screen ([showActions] = false, dropdown only). Selecting
/// a preset switches the global active preset (persisted) via
/// [SettingsNotifier.selectPreset].
class PresetSelector extends ConsumerWidget {
  const PresetSelector({this.showActions = true, super.key});

  /// When true, render the add / rename / delete icon buttons next to the
  /// dropdown. The rename / delete buttons are disabled while the default
  /// preset is active (it can't be renamed or removed).
  final bool showActions;

  String _label(AppLocalizations l, PresetRef ref) =>
      ref.isDefault ? l.presetDefaultName : ref.name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isDefaultActive =
        settings.activePresetId == Preset.defaultPresetId;
    final activeRef = settings.presets.firstWhere(
      (r) => r.id == settings.activePresetId,
      orElse: () => settings.presets.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownMenu<String>(
              // Keyed by active id + the visible labels so the menu
              // re-seeds its selection when presets are added / renamed
              // / switched from elsewhere (e.g. the start screen).
              key: ValueKey(
                '${settings.activePresetId}'
                '|${settings.presets.map((r) => '${r.id}:${r.name}').join(',')}',
              ),
              initialSelection: settings.activePresetId,
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: [
                for (final r in settings.presets)
                  DropdownMenuEntry(value: r.id, label: _label(l, r)),
              ],
              onSelected: (id) {
                if (id != null) unawaited(notifier.selectPreset(id));
              },
            ),
          ),
          if (showActions) ...[
            const SizedBox(width: 4),
            _PresetActionButton(
              icon: Icons.add,
              tooltip: l.presetAddTooltip,
              onPressed: () => _createPreset(context, notifier, activeRef, l),
            ),
            _PresetActionButton(
              icon: Icons.edit,
              tooltip: l.presetRenameTooltip,
              onPressed: isDefaultActive
                  ? null
                  : () => _renamePreset(context, notifier, activeRef, l),
            ),
            _PresetActionButton(
              icon: Icons.delete_outline,
              tooltip: l.presetDeleteTooltip,
              color: theme.colorScheme.error,
              onPressed: isDefaultActive
                  ? null
                  : () => _deletePreset(context, notifier, activeRef, l),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _createPreset(
    BuildContext context,
    SettingsNotifier notifier,
    PresetRef source,
    AppLocalizations l,
  ) async {
    final name = await _promptName(
      context,
      title: l.presetCreateTitle,
      label: l.presetNameLabel,
      confirmLabel: l.presetCreateConfirm,
      cancelLabel: l.commonCancel,
      // Prefill with the name of the preset the new one is based on.
      initial: _label(l, source),
    );
    if (name != null) await notifier.createPreset(name);
  }

  Future<void> _renamePreset(
    BuildContext context,
    SettingsNotifier notifier,
    PresetRef target,
    AppLocalizations l,
  ) async {
    final name = await _promptName(
      context,
      title: l.presetRenameTitle,
      label: l.presetNameLabel,
      confirmLabel: l.presetRenameConfirm,
      cancelLabel: l.commonCancel,
      initial: target.name,
    );
    if (name != null) await notifier.renamePreset(target.id, name);
  }

  Future<void> _deletePreset(
    BuildContext context,
    SettingsNotifier notifier,
    PresetRef target,
    AppLocalizations l,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.presetDeleteTitle),
        content: Text(l.presetDeleteContent(target.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok ?? false) await notifier.deletePreset(target.id);
  }

  Future<String?> _promptName(
    BuildContext context, {
    required String title,
    required String label,
    required String confirmLabel,
    required String cancelLabel,
    required String initial,
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _PresetNameDialog(
        title: title,
        label: label,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        initial: initial,
      ),
    );
  }
}

class _PresetActionButton extends StatelessWidget {
  const _PresetActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        visualDensity: VisualDensity.compact,
        tooltip: tooltip,
        icon: Icon(icon, color: onPressed == null ? null : color),
        onPressed: onPressed,
      ),
    );
  }
}

/// AlertDialog with a single text field, returning the trimmed text on
/// confirm or `null` on cancel. The confirm button is disabled while the
/// field is empty.
class _PresetNameDialog extends StatefulWidget {
  const _PresetNameDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.initial,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String cancelLabel;
  final String initial;

  @override
  State<_PresetNameDialog> createState() => _PresetNameDialogState();
}

class _PresetNameDialogState extends State<_PresetNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isEmpty ? null : _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
