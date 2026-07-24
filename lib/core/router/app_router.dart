import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/world_map/world_map_screen.dart';
import '../../features/gameplay/gameplay_screen.dart';
import '../../features/level_complete/level_complete_screen.dart';
import '../../features/reward/reward_screen.dart';
import '../../features/system/no_internet_screen.dart';
import '../../features/system/maintenance_screen.dart';
import '../../features/system/force_update_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String worldMap = '/map';
  static const String gameplay = '/play';
  static const String levelComplete = '/complete';
  static const String reward = '/reward';
  static const String noInternet = '/no-internet';
  static const String maintenance = '/maintenance';
  static const String forceUpdate = '/force-update';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.worldMap,
      builder: (context, state) {
        final worldNumber =
            int.tryParse(state.uri.queryParameters['world'] ?? '1') ?? 1;
        return WorldMapScreen(worldNumber: worldNumber);
      },
    ),
    GoRoute(
      path: AppRoutes.gameplay,
      builder: (context, state) {
        final levelId =
            int.tryParse(state.uri.queryParameters['level'] ?? '1') ?? 1;
        return GameplayScreen(levelId: levelId);
      },
    ),
    GoRoute(
      path: AppRoutes.levelComplete,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return LevelCompleteScreen(
          levelId: extra?['levelId'] as int? ?? 1,
          starsEarned: extra?['starsEarned'] as int? ?? 1,
          coinsEarned: extra?['coinsEarned'] as int? ?? 20,
          gemsEarned: extra?['gemsEarned'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.reward,
      builder: (context, state) => const RewardScreen(),
    ),
    GoRoute(
      path: AppRoutes.noInternet,
      builder: (context, state) {
        final onRetry = state.extra as VoidCallback? ?? () {};
        return NoInternetScreen(onRetry: onRetry);
      },
    ),
    GoRoute(
      path: AppRoutes.maintenance,
      builder: (context, state) => const MaintenanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.forceUpdate,
      builder: (context, state) => const ForceUpdateScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
