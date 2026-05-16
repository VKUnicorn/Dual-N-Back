import 'package:dual_n_back/features/statistics/domain/stats_period.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Sticky-style header row for the statistics screen: period selector +
/// the cursor navigation strip ("< Январь 2026 >") above the scrollable
/// chart list.
class PeriodHeader extends StatelessWidget {
  const PeriodHeader({
    required this.period,
    required this.anchor,
    required this.onPeriodChanged,
    required this.onPrev,
    required this.onNext,
    super.key,
  });

  final StatsPeriod period;
  final DateTime anchor;
  final ValueChanged<StatsPeriod> onPeriodChanged;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            // Full-width segmented button so the control doesn't shift
            // horizontally when the selected pill (with its leading
            // checkmark) changes width between week/month/year. The
            // `expandedInsets: EdgeInsets.zero` flag tells SegmentedButton
            // to fill its parent's width and split it evenly across
            // segments — keeps the layout stable across selection changes.
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<StatsPeriod>(
                expandedInsets: EdgeInsets.zero,
                segments: [
                  ButtonSegment(
                    value: StatsPeriod.week,
                    label: Text(l.statisticsPeriodWeek),
                  ),
                  ButtonSegment(
                    value: StatsPeriod.month,
                    label: Text(l.statisticsPeriodMonth),
                  ),
                  ButtonSegment(
                    value: StatsPeriod.year,
                    label: Text(l.statisticsPeriodYear),
                  ),
                ],
                selected: {period},
                onSelectionChanged: (s) => onPeriodChanged(s.first),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: onPrev,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _cursorLabel(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _cursorLabel(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    switch (period) {
      case StatsPeriod.week:
        final delta = StatsPeriodMath.periodsBetween(
          StatsPeriod.week,
          DateTime.now(),
          anchor,
        );
        if (delta == 0) return l.statisticsCursorCurrentWeek;
        final start = StatsPeriodMath.startOfWeek(anchor);
        if (delta < 0) {
          return l.statisticsCursorWeeksAgo(-delta, start.year);
        }
        return l.statisticsCursorWeeksAhead(delta, start.year);
      case StatsPeriod.month:
        // Localised "Month YYYY"; first letter capitalised for RU/EN.
        final raw = DateFormat.yMMMM(locale).format(anchor);
        if (raw.isEmpty) return raw;
        return raw[0].toUpperCase() + raw.substring(1);
      case StatsPeriod.year:
        return l.statisticsCursorYear(anchor.year);
    }
  }
}
