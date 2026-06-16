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
      if (isLoggedIn && isOnAuth) return '/profile';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (ctx, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (ctx, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/profile', builder: (ctx, state) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (ctx, state) => const EditProfileScreen()),
      GoRoute(path: '/study-goals', builder: (ctx, state) => const StudyGoalsScreen()),
      GoRoute(path: '/quiz', builder: (ctx, state) => const QuizListScreen()),
      GoRoute(path: '/analytics', builder: (ctx, state) => const AnalyticsDashboardScreen()),
      GoRoute(path: '/achievements', builder: (ctx, state) => const AchievementScreen()),
      GoRoute(path: '/notes', builder: (ctx, state) => const NotesListScreen(),),
      GoRoute(path: '/resources', builder: (ctx, state) => const ResourcesScreen(),),

      GoRoute(
        path: '/quiz/:id',
        builder: (ctx, state) {
          final quiz = state.extra as Quiz;
          return quiz_attempt.QuizAttemptScreen(quiz: quiz);
          },
          ),
          
      GoRoute(
        path: '/quiz-result',
        builder: (ctx, state) {
          final attempt = state.extra as QuizAttempt;
          return quiz_result.QuizResultScreen(attempt: attempt);
          },
          ),

      GoRoute(
        path: '/quiz-add-questions',
        builder: (ctx, state) {
          final quiz = state.extra as Quiz;
          return QuizAddQuestionsScreen(quiz: quiz);
          },
          ),

      GoRoute(
        path: '/quiz-detail',
        builder: (ctx, state) {
          final quiz = state.extra as Quiz;
          return QuizDetailScreen(quiz: quiz);
          },
          ),

      GoRoute(path: '/quiz-history', builder: (ctx, state) => const QuizHistoryScreen()),

      GoRoute(
        path: '/dashboard',
        builder: (ctx, state) => const DashboardScreen(),
      ),
      ],
    );
});