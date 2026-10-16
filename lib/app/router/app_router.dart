import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/providers/firebase_providers.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/dashboard/presentation/screens/search_screen.dart';
import '../../features/dashboard/presentation/screens/category_screen.dart';
import '../../features/course_player/presentation/screens/course_player_screen.dart';
import '../../features/course_player/presentation/screens/curriculum_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_start_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_question_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_result_screen.dart';
import '../../features/progress/presentation/screens/progress_dashboard.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import 'routes.dart';

/// Listenable that triggers GoRouter refresh when Firebase auth state changes.
/// This makes the redirect guard re-evaluate reactively (e.g., after logout
/// or token expiry) without requiring a navigation event.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  GoRouterRefreshStream(Stream<User?> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// GoRouter configuration with custom transitions + auth guard
class AppRouter {
  static GoRouter? _router;

  static GoRouter get router => _router ??= _buildRouter();

  static GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: Routes.splash,
      debugLogDiagnostics: true,

      /// Refresh router when auth state changes (login/logout/session expiry)
      refreshListenable: GoRouterRefreshStream(
        FirebaseAuth.instance.authStateChanges(),
      ),

      /// Auth guard: redirect based on Firebase auth state
      redirect: (context, state) {
        final container = ProviderScope.containerOf(context);
        final asyncUser = container.read(authStateProvider);
        final isLoggedIn = asyncUser.maybeWhen(
          data: (user) => user != null,
          orElse: () => null, // unknown → don't redirect yet
        );

        final currentPath = state.matchedLocation;
        final isAuthRoute = currentPath == Routes.login ||
            currentPath == Routes.signup ||
            currentPath == Routes.onboarding;
        final isPublicRoute =
            currentPath == Routes.splash || isAuthRoute;

        // Unknown auth state → stay put (let splash handle it)
        if (isLoggedIn == null) return null;

        // Logged in + on auth route → go to home
        if (isLoggedIn && isAuthRoute) return Routes.home;

        // Not logged in + protected route → go to login
        if (!isLoggedIn && !isPublicRoute) return Routes.login;

        // Otherwise → no redirect needed
        return null;
      },

      routes: [
        // Splash
        GoRoute(
          path: Routes.splash,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const SplashScreen(),
          ),
        ),

        // Onboarding
        GoRoute(
          path: Routes.onboarding,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const OnboardingScreen(),
          ),
        ),

        // Auth
        GoRoute(
          path: Routes.login,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const LoginScreen(),
          ),
        ),
        GoRoute(
          path: Routes.signup,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const SignUpScreen(),
          ),
        ),

        // Main (protected)
        GoRoute(
          path: Routes.home,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const HomeScreen(),
          ),
        ),
        GoRoute(
          path: Routes.search,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const SearchScreen(),
          ),
        ),
        GoRoute(
          path: Routes.category,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            CategoryScreen(
              category: state.extra as String? ?? 'All',
            ),
          ),
        ),

        // Course Player (protected)
        GoRoute(
          path: Routes.coursePlayer,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            CoursePlayerScreen(
              courseId: state.extra as String? ?? 'course_1',
            ),
          ),
        ),
        GoRoute(
          path: Routes.curriculum,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            CurriculumScreen(
              courseId: state.extra as String? ?? 'course_1',
            ),
          ),
        ),

        // Quizzes (protected)
        GoRoute(
          path: Routes.quizStart,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            QuizStartScreen(
              quizId: state.extra as String? ?? 'quiz_course_1',
            ),
          ),
        ),
        GoRoute(
          path: Routes.quizQuestion,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            QuizQuestionScreen(
              quizId: state.extra as String? ?? 'quiz_course_1',
            ),
          ),
        ),
        GoRoute(
          path: Routes.quizResult,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            QuizResultScreen(
              quizId: state.extra as String? ?? 'quiz_course_1',
              score: int.tryParse(
                      state.uri.queryParameters['score'] ?? '0') ??
                  0,
              total: int.tryParse(
                      state.uri.queryParameters['total'] ?? '5') ??
                  5,
            ),
          ),
        ),

        // Progress (protected)
        GoRoute(
          path: Routes.progressDashboard,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const ProgressDashboard(),
          ),
        ),

        // Profile (protected)
        GoRoute(
          path: Routes.profile,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: Routes.settings,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context,
            state,
            const SettingsScreen(),
          ),
        ),
      ],
    );
  }

  /// Build page with custom slide + fade transition
  static CustomTransitionPage<void> _buildPageWithTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
