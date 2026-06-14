import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';
import '../data/quiz_model.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4F46E5)),
          onPressed: () => context.go('/profile'),
          ),
          title: const Text('Quizzes',
          style: TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF4F46E5)),
                onPressed: () {},
                ),
                ],
                ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F46E5),
        onPressed: () => _showAddQuizDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: quizzesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No quizzes yet!',
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Tap + to create your first quiz',
                      style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _QuizCard(quiz: quiz);
            },
          );
        },
      ),
    );
  }

  void _showAddQuizDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Quiz',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Quiz Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              final quiz = Quiz(
                id: '',
                title: titleController.text.trim(),
                subject: subjectController.text.trim(),
                description: descController.text.trim(),
                questions: [],
                createdAt: DateTime.now(),
              );
              await ref.read(quizNotifierProvider.notifier).addQuiz(quiz);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Create',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends ConsumerWidget {
  final Quiz quiz;
  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectColor = _getSubjectColor(quiz.subject);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (quiz.questions.isEmpty) {
            context.push('/quiz-add-questions', extra: quiz);
          } else {
            context.push('/quiz-detail', extra: quiz);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity( 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz, color: subjectColor, size: 28),
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
                          fontSize: 16,
                          color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity( 0.1),
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
                    const SizedBox(height: 4),
                    Text(
                      quiz.questions.isEmpty
                          ? 'Tap to add questions'
                          : '${quiz.questions.length} questions',
                      style: TextStyle(
                          color: quiz.questions.isEmpty
                              ? Colors.orange
                              : Colors.grey.shade500,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'add',
                      child: Row(children: [
                        Icon(Icons.add_circle_outline,
                            size: 18, color: Color(0xFF4F46E5)),
                        SizedBox(width: 8),
                        Text('Add Questions'),
                      ])),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Quiz',
                            style: TextStyle(color: Colors.red)),
                      ])),
                ],
                onSelected: (value) async {
                  if (value == 'add') {
                    context.push('/quiz-add-questions', extra: quiz);
                  } else if (value == 'delete') {
                    await ref
                        .read(quizRepositoryProvider)
                        .deleteQuiz(quiz.id);
                  }
                },
              ),
            ],
          ),
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