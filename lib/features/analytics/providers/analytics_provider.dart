import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quiz/data/quiz_model.dart';
import '../data/analytics_model.dart';
import '../data/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});

// Stream of quiz attempts for analytics
final analyticsAttemptsProvider = StreamProvider<List<QuizAttempt>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getAttempts(user.uid);
});

// Stream of goal stats
final goalStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getGoalStats(user.uid);
});

// Achievements based on attempts
final achievementsProvider = Provider<List<AchievementBadge>>((ref) {
  final attemptsAsync = ref.watch(analyticsAttemptsProvider);
  final goalStats = ref.watch(goalStatsProvider).valueOrNull;
  final repository = ref.watch(analyticsRepositoryProvider);
  final attempts = attemptsAsync.valueOrNull ?? [];
  
  return repository.calculateAchievements(
    attempts,
    totalGoals: goalStats?['totalGoals'] ?? 0,
    totalStudyHours: goalStats?['totalStudyHours'] ?? 0.0,
  );
});

// Study stats summary
final studyStatsProvider = Provider<StudyStats>((ref) {
  final attempts = ref.watch(analyticsAttemptsProvider).valueOrNull ?? [];
  final goalStats = ref.watch(goalStatsProvider).valueOrNull;

  final totalQuizzes = attempts.length;
  final averageScore = totalQuizzes > 0
      ? attempts.fold<double>(0, (sum, a) => sum + a.percentage) / totalQuizzes
      : 0.0;

  return StudyStats(
    totalQuizzes: totalQuizzes,
    averageScore: averageScore,
    totalGoals: goalStats?['totalGoals'] ?? 0,
    completedGoals: goalStats?['completedGoals'] ?? 0,
    totalStudyHours: goalStats?['totalStudyHours'] ?? 0.0,
  );
});