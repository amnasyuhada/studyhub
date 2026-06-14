import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/study_goal_model.dart';
import '../data/study_goal_repository.dart';

final studyGoalRepositoryProvider = Provider<StudyGoalRepository>((ref) {
  return StudyGoalRepository();
});

final studyGoalsProvider = StreamProvider<List<StudyGoal>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();

  final repository = ref.watch(studyGoalRepositoryProvider);
  return repository.getGoals(user.uid);
});

class StudyGoalNotifier extends StateNotifier<AsyncValue<void>> {
  final StudyGoalRepository _repository;

  StudyGoalNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addGoal(StudyGoal goal) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addGoal(goal);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateGoal(StudyGoal goal) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateGoal(goal);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGoal(String goalId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteGoal(goalId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProgress(String goalId, double completedHours, double targetHours) async {
  state = const AsyncValue.loading();
  try {
    await _repository.updateProgress(goalId, completedHours, targetHours);
    state = const AsyncValue.data(null);
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}

  // Future<void> updateProgress(String goalId, double completedHours) async {
  //   state = const AsyncValue.loading();
  //   try {
  //     await _repository.updateProgress(goalId, completedHours);
  //     state = const AsyncValue.data(null);
  //   } catch (e, st) {
  //     state = AsyncValue.error(e, st);
  //   }
  // }
}

final studyGoalNotifierProvider =
    StateNotifierProvider<StudyGoalNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(studyGoalRepositoryProvider);
  return StudyGoalNotifier(repository);
});