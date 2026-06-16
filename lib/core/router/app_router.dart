import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/study_goals/screens/study_goals_screen.dart';
import '../../features/quiz/data/quiz_model.dart';
import '../../features/quiz/screens/quiz_list_screen.dart';
import '../../features/quiz/screens/quiz_history_screen.dart';
import '../../features/quiz/screens/quiz_attempt_screen.dart' as quiz_attempt;
import '../../features/quiz/screens/quiz_result_screen.dart' as quiz_result;
import '../../features/quiz/screens/quiz_add_questions_screen.dart';
import '../../features/analytics/screens/analytics_dashboard_screen.dart';
import '../../features/analytics/screens/achievement_screen.dart';
import '../../features/quiz/screens/quiz_detail_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/resources/screens/resources_screen.dart';
import '../../features/notes/screens/notes_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isOnAuth) return '/login';
      if (isLoggedIn && isOnAuth) return '/dashboard';
      return null;
    },
    routes: [
      // ============ AUTH ROUTES (NO Bottom Navigation) ============
      GoRoute(
        path: '/login', 
        builder: (ctx, state) => const LoginScreen()
      ),
      GoRoute(
        path: '/register', 
        builder: (ctx, state) => const RegisterScreen()
      ),
      GoRoute(
        path: '/forgot-password', 
        builder: (ctx, state) => const ForgotPasswordScreen()
      ),
      
      // ============ SHELL ROUTE WITH BOTTOM NAVIGATION ============
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          // ===== MAIN TABS =====
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/study-goals',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StudyGoalsScreen(),
            ),
          ),
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotesListScreen(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          
          // ===== SUB-PAGES (also with bottom nav) =====
          GoRoute(
            path: '/profile/edit',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EditProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/resources',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ResourcesScreen(),
            ),
          ),
          GoRoute(
            path: '/quiz',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuizListScreen(),
            ),
          ),
          GoRoute(
            path: '/quiz-history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuizHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/achievements',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AchievementScreen(),
            ),
          ),
          GoRoute(
            path: '/quiz/:id',
            pageBuilder: (context, state) {
              final quiz = state.extra as Quiz;
              return NoTransitionPage(
                child: quiz_attempt.QuizAttemptScreen(quiz: quiz),
              );
            },
          ),
          GoRoute(
            path: '/quiz-result',
            pageBuilder: (context, state) {
              final attempt = state.extra as QuizAttempt;
              return NoTransitionPage(
                child: quiz_result.QuizResultScreen(attempt: attempt),
              );
            },
          ),
          GoRoute(
            path: '/quiz-add-questions',
            pageBuilder: (context, state) {
              final quiz = state.extra as Quiz;
              return NoTransitionPage(
                child: QuizAddQuestionsScreen(quiz: quiz),
              );
            },
          ),
          GoRoute(
            path: '/quiz-detail',
            pageBuilder: (context, state) {
              final quiz = state.extra as Quiz;
              return NoTransitionPage(
                child: QuizDetailScreen(quiz: quiz),
              );
            },
          ),
        ],
      ),
    ],
  );
});

// ============ BOTTOM NAVIGATION SHELL WIDGET ============
class MainNavigationShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _getSelectedIndex(String location) {
    // Check which tab should be highlighted
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/study-goals')) return 1;
    if (location.startsWith('/notes')) return 2;
    if (location.startsWith('/analytics')) return 3;
    if (location.startsWith('/profile')) return 4;
    
    // For sub-pages, highlight the parent tab
    if (location.startsWith('/quiz')) return 1; // Study Goals tab
    if (location.startsWith('/resources')) return 2; // Notes tab
    if (location.startsWith('/achievements')) return 3; // Analytics tab
    
    return 0; // Default to Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/study-goals');
        break;
      case 2:
        context.go('/notes');
        break;
      case 3:
        context.go('/analytics');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Use matchedLocation instead of location
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _getSelectedIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 8.0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Study Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            activeIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}