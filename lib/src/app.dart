import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/difficulty_selection_screen.dart';
import 'screens/game_screen.dart';
import 'screens/options_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/about_screen.dart';
import 'themes/app_theme.dart';
import 'package:flutter/services.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/main-menu',
        //builder: (context, state) => const MainMenuScreen(),
        pageBuilder: (context, state) =>
          const NoTransitionPage(child: MainMenuScreen()),
      ),
      GoRoute(
        path: '/difficulty',
        builder: (context, state) => const DifficultySelectionScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: '/options',
        builder: (context, state) => const OptionsScreen(),
      ),
      GoRoute(
        path: '/achievements',
        //builder: (context, state) => const AchievementsScreen(),
        pageBuilder: (context, state) =>
          const NoTransitionPage(child: AchievementsScreen()),
      ),
      GoRoute(
        path: '/about',
        // builder: (context, state) => const AboutScreen(),
        pageBuilder: (context, state) =>
          const NoTransitionPage(child: AboutScreen()),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentTheme = ref.watch(currentThemeProvider);
    // Hides the bottom navigation bar and the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: [SystemUiOverlay.bottom]);
    
    return MaterialApp.router(
      title: 'Zurdoku',
      theme: currentTheme.lightTheme,
      darkTheme: currentTheme.darkTheme,
      themeMode: currentTheme.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      
    );
  }
}
