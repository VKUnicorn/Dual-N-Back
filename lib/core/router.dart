import 'package:dual_n_back/features/achievements/presentation/achievements_screen.dart';
import 'package:dual_n_back/features/game/presentation/game_screen.dart';
import 'package:dual_n_back/features/info/presentation/info_screen.dart';
import 'package:dual_n_back/features/settings/presentation/settings_screen.dart';
import 'package:dual_n_back/features/statistics/presentation/statistics_screen.dart';
import 'package:dual_n_back/shared/widgets/home_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: '/info',
        builder: (context, state) => const InfoScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
    ],
  );
}
