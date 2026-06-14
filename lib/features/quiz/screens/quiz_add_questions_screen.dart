import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/quiz_model.dart';
import '../providers/quiz_provider.dart';

class QuizAddQuestionsScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  const QuizAddQuestionsScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizAddQuestionsScreen> createState() =>
      _QuizAddQuestionsScreenState();
}

class _QuizAddQuestionsScreenState
    extends ConsumerState<QuizAddQuestionsScreen> {
  late List<QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.quiz.questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text(
          'Add Questions',
          style: TextStyle(
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4F46E5)),
          onPressed: () => context.go('/profile'),
        ),
        actions: [
          if (_questions.isNotEmpty)
            TextButton(
              onPressed: _saveQuestions,
              child: const Text('Save',
                  style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        onPressed: _showAddQuestionDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Add Question', style: TextStyle(color: Colors.white)),
      ),
      body: _questions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No questions yet',
                      style: TextStyle(
                          fontSize: 18, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Tap + to add your first question',
                      style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5)
                                    .withOpacity( 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Q${index + 1}',
                                  style: const TextStyle(
                                      color: Color(0xFF4F46E5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              onPressed: () =>
                                  setState(() => _questions.removeAt(index)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(q.question,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        ...q.options.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    e.key == q.correctIndex
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: e.key == q.correctIndex
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(e.value,
                                      style: TextStyle(
                                          color: e.key == q.correctIndex
                                              ? Colors.green
                                              : Colors.grey.shade600,
                                          fontSize: 13)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddQuestionDialog() {
    final questionController = TextEditingController();
    final option1 = TextEditingController();
    final option2 = TextEditingController();
    final option3 = TextEditingController();
    final option4 = TextEditingController();
    int correctIndex = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Question',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xFF4F46E5), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Options (select correct answer)',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                ...([option1, option2, option3, option4]
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: e.key,
                                groupValue: correctIndex,
                                activeColor: const Color(0xFF4F46E5),
                                onChanged: (val) =>
                                    setState(() => correctIndex = val!),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: e.value,
                                  decoration: InputDecoration(
                                    labelText: 'Option ${e.key + 1}',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF4F46E5),
                                          width: 2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (questionController.text.isEmpty ||
                    option1.text.isEmpty ||
                    option2.text.isEmpty) return;

                final question = QuizQuestion(
                  question: questionController.text.trim(),
                  options: [
                    option1.text.trim(),
                    option2.text.trim(),
                    if (option3.text.isNotEmpty) option3.text.trim(),
                    if (option4.text.isNotEmpty) option4.text.trim(),
                  ],
                  correctIndex: correctIndex,
                );

                this.setState(() => _questions.add(question));
                Navigator.pop(context);
              },
              child: const Text('Add',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuestions() async {
  final repo = ref.read(quizRepositoryProvider);
  
  final updatedQuiz = Quiz(
    id: widget.quiz.id,
    title: widget.quiz.title,
    subject: widget.quiz.subject,
    description: widget.quiz.description,
    questions: _questions,
    createdAt: widget.quiz.createdAt,
  );

  await repo.updateQuiz(updatedQuiz);

  if (mounted) context.pop();
}
}