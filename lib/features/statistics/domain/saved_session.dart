import 'package:dual_n_back/features/statistics/data/database.dart';
import 'package:meta/meta.dart';

/// Composite read model returned by `StatisticsRepository.loadAll`.
@immutable
class SavedSession {
  const SavedSession({required this.session, required this.scores});

  final Session session;
  final List<ChannelScore> scores;
}
