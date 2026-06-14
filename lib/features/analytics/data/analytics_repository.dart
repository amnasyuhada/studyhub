import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../quiz/data/quiz_model.dart';
import 'analytics_model.dart';

class AnalyticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get quiz attempts for analytics
  Stream<List<QuizAttempt>> getAttempts(String userId) {
    return _firestore
        .collection('quiz_attempts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => QuizAttempt.fromFirestore(doc)).toList());
  }

  // Get study goals for analytics
  Stream<Map<String, dynamic>> getGoalStats(String userId) {
    return _firestore
        .collection('study_goals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs;
      final total = docs.length;
      final completed =
          docs.where((d) => d['status'] == 'Completed').length;
      final totalHours = docs.fold<double>(
          0, (sum, d) => sum + (d['completedHours'] ?? 0).toDouble());

      return {
        'totalGoals': total,
        'completedGoals': completed,
        'totalStudyHours': totalHours,
      };
    });
  }

  // Calculate achievements based on attempts
  List<AchievementBadge> calculateAchievements(
  List<QuizAttempt> attempts, {
  int totalGoals = 0,
  double totalStudyHours = 0,
}) {
  final totalQuizzes = attempts.length;
  final avgScore = totalQuizzes > 0
      ? attempts.fold<double>(0, (sum, a) => sum + a.percentage) / totalQuizzes
      : 0.0;
  final perfectScores = attempts.where((a) => a.percentage == 100).length;

  return [
    AchievementBadge(
      id: 'first_quiz',
      title: 'First Step',
      description: 'Complete your first quiz',
      icon: '🎯',
      isUnlocked: totalQuizzes >= 1,
    ),
    AchievementBadge(
      id: 'quiz_3',
      title: 'Getting Started',
      description: 'Complete 3 quizzes',
      icon: '🔥',
      isUnlocked: totalQuizzes >= 3,
    ),
    AchievementBadge(
      id: 'quiz_5',
      title: 'Quiz Enthusiast',
      description: 'Complete 5 quizzes',
      icon: '📚',
      isUnlocked: totalQuizzes >= 5,
    ),
    AchievementBadge(
      id: 'quiz_10',
      title: 'Quiz Master',
      description: 'Complete 10 quizzes',
      icon: '🏆',
      isUnlocked: totalQuizzes >= 10,
    ),
    AchievementBadge(
      id: 'high_scorer',
      title: 'High Scorer',
      description: 'Achieve average score above 80%',
      icon: '⭐',
      isUnlocked: avgScore >= 80,
    ),
    AchievementBadge(
      id: 'perfect',
      title: 'Perfectionist',
      description: 'Get a perfect score on any quiz',
      icon: '💯',
      isUnlocked: perfectScores >= 1,
    ),
    AchievementBadge(
      id: 'perfect_3',
      title: 'Excellence',
      description: 'Get 3 perfect scores',
      icon: '👑',
      isUnlocked: perfectScores >= 3,
    ),
    AchievementBadge(
      id: 'goal_setter',
      title: 'Goal Setter',
      description: 'Create your first study goal',
      icon: '🏁',
      isUnlocked: totalGoals >= 1,
    ),
    AchievementBadge(
      id: 'study_hours',
      title: 'Study Grinder',
      description: 'Log 10 hours of study time',
      icon: '⏰',
      isUnlocked: totalStudyHours >= 10,
    ),
    AchievementBadge(
      id: 'pass_streak',
      title: 'On A Roll',
      description: 'Pass 3 quizzes in a row',
      icon: '🚀',
      isUnlocked: _checkPassStreak(attempts, 3),
    ),
  ];
}

bool _checkPassStreak(List<QuizAttempt> attempts, int streak) {
  if (attempts.length < streak) return false;
  final sorted = [...attempts]
    ..sort((a, b) => a.dateAttempted.compareTo(b.dateAttempted));
  int count = 0;
  for (final attempt in sorted) {
    if (attempt.percentage >= 50) {
      count++;
      if (count >= streak) return true;
    } else {
      count = 0;
    }
  }
  return false;
}
}