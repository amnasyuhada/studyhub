import 'package:cloud_firestore/cloud_firestore.dart';
import 'quiz_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all quizzes
  Stream<List<Quiz>> getQuizzes() {
    return _firestore
        .collection('quizzes')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList());
  }

  // Add a quiz
  Future<void> addQuiz(Quiz quiz) async {
    await _firestore.collection('quizzes').add(quiz.toFirestore());
  }

  // Save quiz attempt
  Future<void> saveAttempt(QuizAttempt attempt) async {
    await _firestore.collection('quiz_attempts').add(attempt.toFirestore());
  }

  // Get quiz history for a user
  Stream<List<QuizAttempt>> getAttempts(String userId) {
    return _firestore
        .collection('quiz_attempts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => QuizAttempt.fromFirestore(doc)).toList());
  }

  Future<void> updateQuiz(Quiz quiz) async {
  await _firestore
      .collection('quizzes')
      .doc(quiz.id)
      .update(quiz.toFirestore());
      }

  Future<void> deleteQuiz(String quizId) async {
  await _firestore.collection('quizzes').doc(quizId).delete();
  }
}