import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final String description;
  final List<QuizQuestion> questions;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.questions,
    required this.createdAt,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      questions: (data['questions'] as List<dynamic>? ?? [])
          .map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subject': subject,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class QuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final String quizTitle;
  final String subject;
  final int score;
  final int totalQuestions;
  final DateTime dateAttempted;

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.subject,
    required this.score,
    required this.totalQuestions,
    required this.dateAttempted,
  });

  double get percentage => totalQuestions > 0
      ? (score / totalQuestions) * 100
      : 0;

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizAttempt(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      quizTitle: data['quizTitle'] ?? '',
      subject: data['subject'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      dateAttempted: (data['dateAttempted'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'subject': subject,
      'score': score,
      'totalQuestions': totalQuestions,
      'dateAttempted': Timestamp.fromDate(dateAttempted),
    };
  }
}