import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/quiz_model.dart';

class QuizDetailScreen extends StatelessWidget {
  final Quiz quiz;
  const QuizDetailScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    final subjectColor = _getSubjectColor(quiz.subject);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4F46E5)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Quiz Details',
          style: TextStyle(
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz header card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: subjectColor.withOpacity( 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.quiz,
                              color: subjectColor, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF1A1A2E)),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      subjectColor.withOpacity( 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  quiz.subject.toUpperCase(),
                                  style: TextStyle(
                                      color: subjectColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (quiz.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        quiz.description,
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            height: 1.5),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quiz stats
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.help_outline,
                    iconColor: const Color(0xFF4F46E5),
                    label: 'Questions',
                    value: '${quiz.questions.length}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.timer_outlined,
                    iconColor: Colors.orange,
                    label: 'Est. Time',
                    value: '${quiz.questions.length * 2} mins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Questions preview
            const Text(
              'Questions Preview',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),

            if (quiz.questions.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No questions added yet',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              )
            else
              ...quiz.questions.asMap().entries.map((e) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5)
                                  .withOpacity( 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                    color: Color(0xFF4F46E5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value.question,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A2E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 32),

            // Start quiz button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: quiz.questions.isEmpty
                    ? null
                    : () => context.pushReplacement(
                        '/quiz/${quiz.id}',
                        extra: quiz),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  quiz.questions.isEmpty
                      ? 'No Questions Available'
                      : 'Start Quiz',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: quiz.questions.isEmpty
                      ? Colors.grey
                      : const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Colors.orange;
    if (s.contains('computer') || s.contains('programming')) {
      return const Color(0xFF4F46E5);
    }
    if (s.contains('science')) return Colors.green;
    if (s.contains('english') || s.contains('language')) return Colors.blue;
    return Colors.purple;
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}