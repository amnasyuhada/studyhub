import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';
import '../data/quiz_model.dart';
import 'package:go_router/go_router.dart';

class QuizHistoryScreen extends ConsumerWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptsAsync = ref.watch(quizAttemptsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4F46E5)),
          onPressed: () => context.go('/dashboard'),
          ),
          title: const Text('Quiz History',
          style: TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.bold,
            fontSize: 22),
            ),
            ),
      body: attemptsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (attempts) {
          if (attempts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No quiz attempts yet!',
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Complete a quiz to see your history',
                      style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            );
          }

          // Sort by date descending
          final sorted = [...attempts]
            ..sort((a, b) => b.dateAttempted.compareTo(a.dateAttempted));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              return _AttemptCard(attempt: sorted[index]);
            },
          );
        },
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  final QuizAttempt attempt;
  const _AttemptCard({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final percentage = attempt.percentage;
    final isPassed = percentage >= 50;

    Color scoreColor;
    if (percentage >= 80) {
      scoreColor = Colors.green;
    } else if (percentage >= 60) {
      scoreColor = const Color(0xFF4F46E5);
    } else if (percentage >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity( 0.1),
                border: Border.all(color: scoreColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Quiz info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attempt.quizTitle,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    attempt.subject,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${attempt.score}/${attempt.totalQuestions} correct · ${_formatDate(attempt.dateAttempted)}',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Pass/Fail badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPassed
                    ? Colors.green.withOpacity( 0.1)
                    : Colors.red.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isPassed ? 'Passed' : 'Failed',
                style: TextStyle(
                    color: isPassed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}