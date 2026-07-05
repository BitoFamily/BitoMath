import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/companions/screens/companion_select_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/game/models/game_state.dart';
import '../../features/game/screens/game_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/rewards/screens/parent_zone_screen.dart';
import '../../features/rewards/screens/rewards_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String game = '/game/:ageBand';
  static const String practice = '/practice/:ageBand';
  static const String results = '/results';
  static const String parent = '/parent';
  static const String companions = '/companions';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String rewards = '/rewards';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.game,
        builder: (_, state) {
          final ageBand =
              int.tryParse(state.pathParameters['ageBand'] ?? '0') ?? 0;
          return GameScreen(ageBand: ageBand.clamp(0, 2), isPractice: false);
        },
      ),
      GoRoute(
        path: Routes.practice,
        builder: (_, state) {
          final ageBand =
              int.tryParse(state.pathParameters['ageBand'] ?? '0') ?? 0;
          return GameScreen(ageBand: ageBand.clamp(0, 2), isPractice: true);
        },
      ),
      GoRoute(
        path: Routes.results,
        builder: (_, state) => ResultsScreen(result: state.extra as GameState),
      ),
      GoRoute(
        path: Routes.parent,
        builder: (_, __) => const ParentGateScreen(),
      ),
      GoRoute(
        path: Routes.companions,
        builder: (_, __) => const CompanionSelectScreen(),
      ),
      GoRoute(
        path: Routes.progress,
        builder: (_, __) => const ProgressScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.rewards,
        builder: (_, __) => const RewardsScreen(),
      ),
    ],
  );
});
