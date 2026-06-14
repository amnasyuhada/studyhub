import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/quiz_model.dart';
import '../providers/quiz_provider.dart';
import '../../auth/providers/auth_provider.dart';

class QuizAttemptScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  const QuizAttemptScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends ConsumerState<QuizAttemptScreen> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final questions = widget.quiz.questions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: Text('No questions available for this quiz.'),
        ),
      );
    }

    final question = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Row(
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${questions.length}',
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '${(_selectedAnswers.length)} answered',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),

            // Question card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  question.question,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, i) {
                  final isSelected = _selectedAnswers[_currentIndex] == i;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedAnswers[_currentIndex] = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4F46E5)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade100,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF4F46E5)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[i],
                              style: TextStyle(
                                fontSize: 15,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _currentIndex--),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4F46E5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Previous',
                          style: TextStyle(color: Color(0xFF4F46E5))),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_currentIndex < questions.length - 1) {
                              setState(() => _currentIndex++);
                            } else {
                              _submitQuiz();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _currentIndex < questions.length - 1
                                ? 'Next'
                                : 'Submit Quiz',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5F6FA),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF4F46E5)),
        onPressed: () => context.go('/profile'),
      ),
      title: Text(
        widget.quiz.title,
        style: const TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.bold,
            fontSize: 18),
      ),
    );
  }

  Future<void> _submitQuiz() async {
    setState(() => _isSubmitting = true);

    final questions = widget.quiz.questions;
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers[i] == questions[i].correctIndex) {
        score++;
      }
    }

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final attempt = QuizAttempt(
      id: '',
      userId: user.uid,
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      subject: widget.quiz.subject,
      score: score,
      totalQuestions: questions.length,
      dateAttempted: DateTime.now(),
    );

    await ref.read(quizNotifierProvider.notifier).saveAttempt(attempt);

    if (mounted) {
      context.pushReplacement('/quiz-result', extra: attempt);
    }
  }
}