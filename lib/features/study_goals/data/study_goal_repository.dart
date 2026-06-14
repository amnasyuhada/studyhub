import 'package:cloud_firestore/cloud_firestore.dart';
import 'study_goal_model.dart';

class StudyGoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Stream<List<StudyGoal>> getGoals(String userId) {
  return _firestore
      .collection('study_goals')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => StudyGoal.fromFirestore(doc)).toList());
}

  // Add a new goal
  Future<void> addGoal(StudyGoal goal) async {
    await _firestore.collection('study_goals').add(goal.toFirestore());
  }

  // Update a goal
  Future<void> updateGoal(StudyGoal goal) async {
    await _firestore
        .collection('study_goals')
        .doc(goal.id)
        .update(goal.toFirestore());
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection('study_goals').doc(goalId).delete();
  }

  Future<void> updateProgress(String goalId, double completedHours, double targetHours) async {
  String status;
  if (completedHours <= 0) {
    status = 'Not Started';
  } else if (completedHours >= targetHours) {
    status = 'Completed';
  } else {
    status = 'In Progress';
  }
  
  await _firestore.collection('study_goals').doc(goalId).update({
    'completedHours': completedHours,
    'status': status,
  });
}

  // // Update progress
  // Future<void> updateProgress(String goalId, double completedHours) async {
  //   final status = completedHours > 0 ? 'In Progress' : 'Not Started';
  //   await _firestore.collection('study_goals').doc(goalId).update({
  //     'completedHours': completedHours,
  //     'status': status,
  //   });
  // }
}