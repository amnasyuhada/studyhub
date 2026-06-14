import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/quiz_model.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizAttempt attempt;
  const QuizResultScreen({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final percentage = attempt.percentage;
    final isPassed = percentage >= 50;

    Color resultColor;
    String resultMessage;
    IconData resultIcon;

    if (percentage >= 80) {
      resultColor = Colors.green;
      resultMessage = 'Excellent Work!';
      resultIcon = Icons.emoji_events;
    } else if (percentage >= 60) {
      resultColor = const Color(0xFF4F46E5);
      resultMessage = 'Good Job!';
      resultIcon = Icons.thumb_up;
    } else if (percentage >= 50) {
      resultColor = Colors.orange;
      resultMessage = 'You Passed!';
      resultIcon = Icons.check_circle;
    } else {
      resultColor = Colors.red;
      resultMessage = 'Keep Practicing!';
      resultIcon = Icons.refresh;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Quiz Result',
          style: TextStyle(
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: resultColor.withOpacity( 0.1),
                border: Border.all(color: resultColor, width: 4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(resultIcon, color: resultColor, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: resultColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              resultMessage,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: resultColor),
            ),
            const SizedBox(height: 8),
            Text(
              attempt.quizTitle,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Colors.green, size: 22),
                        const SizedBox(width: 12),
                        Text('Correct Answers',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14)),
                        const Spacer(),
                        Text('${attempt.score} / ${attempt.totalQuestions}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A1A2E))),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.cancel_outlined,
                            color: Colors.red, size: 22),
                        const SizedBox(width: 12),
                        Text('Wrong Answers',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14)),
                        const Spacer(),
                        Text(
                            '${attempt.totalQuestions - attempt.score} / ${attempt.totalQuestions}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A1A2E))),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.subject,
                            color: Color(0xFF4F46E5), size: 22),
                        const SizedBox(width: 12),
                        Text('Subject',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14)),
                        const Spacer(),
                        Text(attempt.subject,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A1A2E))),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(isPassed ? Icons.verified : Icons.cancel,
                            color: isPassed ? Colors.green : Colors.red,
                            size: 22),
                        const SizedBox(width: 12),
                        Text('Status',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14)),
                        const Spacer(),
                        Text(isPassed ? 'Passed' : 'Failed',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color:
                                    isPassed ? Colors.green : Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/quiz'),
                icon: const Icon(Icons.quiz, color: Colors.white),
                label: const Text('Back to Quizzes',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/quiz-history'),
                icon: const Icon(Icons.history, color: Color(0xFF4F46E5)),
                label: const Text('View History',
                    style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}