import 'dart:math';

import 'package:dual_n_back/features/game/domain/response_evaluator.dart'
    as domain;
import 'package:dual_n_back/features/game/domain/stimulus.dart';
import 'package:dual_n_back/features/statistics/application/statistics_provider.dart';
import 'package:dual_n_back/features/statistics/data/statistics_repository.dart';
import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug-only button that seeds two years of plausible-looking sessions.
/// Always visible per UX request — handy on a release build to populate
/// the screen for screenshots or to test cursor edge cases.
class DebugFillButton extends ConsumerStatefulWidget {
  const DebugFillButton({super.key});

  @override
  ConsumerState<DebugFillButton> createState() => _DebugFillButtonState();
}

class _DebugFillButtonState extends ConsumerState<DebugFillButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: _busy ? null : _run,
      icon: _busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.science_outlined),
      label: Text(
        _busy ? l.statisticsDebugFillProgress : l.statisticsDebugFillButton,
      ),
    );
  }

  Future<void> _run() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    try {
      final seeds = _generateFakes();
      await ref.read(statisticsRepositoryProvider).bulkInsert(seeds);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.statisticsDebugFillDone(seeds.length))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<FakeSessionSeed> _generateFakes() {
    final rng = Random(42); // deterministic so reseeds look the same.
    final now = DateTime.now();
    final start = DateTime(now.year - 2, now.month, now.day);
    final seeds = <FakeSessionSeed>[];

    // Long-term progression curve: starting N around 2, drifting up to
    // ~6-7 over two years, with daily noise.
    final totalDays = now.difference(start).inDays;
    for (var dayIdx = 0; dayIdx < totalDays; dayIdx++) {
      // 70% of days have sessions; remaining 30% are empty.
      if (rng.nextDouble() < 0.30) continue;
      final day = start.add(Duration(days: dayIdx));
      final sessionsToday = 1 + rng.nextInt(20); // 1..20 sessions

      final progress = dayIdx / totalDays; // 0..1
      final baseN = 2 + (progress * 5).floor() + rng.nextInt(2); // 2..8
      for (var i = 0; i < sessionsToday; i++) {
        // Random starting time within the day, separated by ~5 minutes.
        final startedAt = DateTime(
          day.year,
          day.month,
          day.day,
          8 + rng.nextInt(13), // 8..20
          rng.nextInt(60),
        ).add(Duration(minutes: i * 5));
        final n = (baseN + rng.nextInt(3) - 1).clamp(2, 9);
        final acc = 0.5 + rng.nextDouble() * 0.5; // 0.50..1.00
        final accAudio = (acc + (rng.nextDouble() - 0.5) * 0.1).clamp(0.0, 1.0);
        final accPos = (acc + (rng.nextDouble() - 0.5) * 0.1).clamp(0.0, 1.0);
        seeds.add(
          FakeSessionSeed(
            startedAt: startedAt,
            n: n,
            newN: n,
            activeChannels: const {ChannelType.position, ChannelType.audio},
            totalTrials: 20 + n,
            stimulusDurationMs: 500,
            isiMs: 2500,
            score: domain.SessionScore({
              ChannelType.position: _scoreFromAccuracy(accPos, 20 + n, n),
              ChannelType.audio: _scoreFromAccuracy(accAudio, 20 + n, n),
            }),
          ),
        );
      }
    }
    return seeds;
  }

  domain.ChannelScore _scoreFromAccuracy(double acc, int totalTrials, int n) {
    // Roughly 30% of trials are matches (Jaeggi default).
    final matches = (totalTrials * 0.3).round();
    final nonMatches = totalTrials - matches - n; // first N have no decision
    final hits = (matches * acc).round();
    final misses = matches - hits;
    final correctRejections = (nonMatches * acc).round();
    final falseAlarms = nonMatches - correctRejections;
    return domain.ChannelScore(
      hits: hits,
      misses: misses,
      falseAlarms: falseAlarms,
      correctRejections: correctRejections.clamp(0, nonMatches),
    );
  }
}
