import 'package:dual_n_back/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Static reference page describing the N-back task, the Jaeggi protocol
/// and what each scoring metric means. Reachable from the home screen's
/// Information button.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.infoTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(
              child: Image.asset(
                'assets/images/example.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(l.infoSectionWhatIs),
            _Body(l.infoSectionWhatIsBody),
            const SizedBox(height: 20),
            _SectionTitle(l.infoSectionJaeggi),
            _Body(l.infoSectionJaeggiBody),
            const SizedBox(height: 20),
            _SectionTitle(l.infoSectionMetrics),
            _MetricLine(l.infoMetricHits),
            _MetricLine(l.infoMetricMisses),
            _MetricLine(l.infoMetricFalseAlarms),
            _MetricLine(l.infoMetricCorrectRejections),
            _MetricLine(l.infoMetricAccuracy),
            _MetricLine(l.infoMetricDPrime),
            const SizedBox(height: 20),
            _SectionTitle(l.infoSectionTips),
            Text(
              l.infoSectionTipsBody,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
    );
  }
}
