import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/quiz_model.dart';
import '../data/quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});

// All quizzes
final quizzesProvider = StreamProvider<List<Quiz>>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getQuizzes();
});

// Quiz attempts/history for current user
final quizAttemptsProvider = StreamProvider<List<QuizAttempt>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  final repository = ref.watch(quizRepositoryProvider);
  return repository.getAttempts(user.uid);
});

// Notifier for saving attempts
class QuizNotifier extends StateNotifier<AsyncValue<void>> {
  final QuizRepository _repository;

  QuizNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addQuiz(Quiz quiz) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addQuiz(quiz);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveAttempt(QuizAttempt attempt) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveAttempt(attempt);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final quizNotifierProvider =
    StateNotifierProvider<QuizNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return QuizNotifier(repository);
});