import 'package:flutter/material.dart';

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}

class StudyStats {
  final int totalQuizzes;
  final double averageScore;
  final int totalGoals;
  final int completedGoals;
  final double totalStudyHours;

  StudyStats({
    required this.totalQuizzes,
    required this.averageScore,
    required this.totalGoals,
    required this.completedGoals,
    required this.totalStudyHours,
  });
}
