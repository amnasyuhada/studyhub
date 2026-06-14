import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGoal {
  final String id;
  final String userId;
  final String title;
  final String subject;
  final double targetHours;
  final double completedHours;
  final String status; // 'In Progress', 'Completed', 'Not Started'
  final DateTime createdAt;

  StudyGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.targetHours,
    required this.completedHours,
    required this.status,
    required this.createdAt,
  });

  double get progressPercentage =>
      targetHours > 0 ? (completedHours / targetHours).clamp(0.0, 1.0) : 0.0;

  factory StudyGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyGoal(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      targetHours: (data['targetHours'] ?? 0).toDouble(),
      completedHours: (data['completedHours'] ?? 0).toDouble(),
      status: data['status'] ?? 'Not Started',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'subject': subject,
      'targetHours': targetHours,
      'completedHours': completedHours,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}