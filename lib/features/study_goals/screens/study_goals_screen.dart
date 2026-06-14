import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/study_goal_provider.dart';
import '../data/study_goal_model.dart';
import '../../auth/providers/auth_provider.dart';

class StudyGoalsScreen extends ConsumerStatefulWidget {
  const StudyGoalsScreen({super.key});

  @override
  ConsumerState<StudyGoalsScreen> createState() => _StudyGoalsScreenState();
}

class _StudyGoalsScreenState extends ConsumerState<StudyGoalsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(studyGoalsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text(
          'Study Goals',
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
        onPressed: () => _showAddGoalDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter tabs
         // Filter tabs
SizedBox(
  height: 44,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    children: ['All', 'In Progress', 'Completed', 'Not Started']
        .map((filter) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedFilter = filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedFilter == filter
                        ? const Color(0xFF4F46E5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFilter == filter
                          ? const Color(0xFF4F46E5)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: _selectedFilter == filter
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ))
        .toList(),
  ),
),

          // Goals list
          Expanded(
            child: goalsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(
                    color: Color(0xFF4F46E5),
                  )),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (goals) {
                final filtered = _selectedFilter == 'All'
                    ? goals
                    : goals
                        .where((g) => g.status == _selectedFilter)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No goals found!',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add a new goal',
                          style:
                              TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _GoalCard(goal: filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final hoursController = TextEditingController();
    String selectedPriority = 'Normal';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Add Study Goal',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Priority selector
                Row(
                  children: ['High', 'Normal', 'Low'].map((p) {
                    final color = p == 'High'
                        ? Colors.red
                        : p == 'Normal'
                            ? const Color(0xFF4F46E5)
                            : Colors.green;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedPriority = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selectedPriority == p
                                ? color
                                : color.withOpacity( 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p,
                            style: TextStyle(
                              color: selectedPriority == p
                                  ? Colors.white
                                  : color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Goal Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xFF4F46E5), width: 2),
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
                      borderSide: const BorderSide(
                          color: Color(0xFF4F46E5), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Hours',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xFF4F46E5), width: 2),
                    ),
                  ),
                ),
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
              onPressed: () async {
                final user =
                    ref.read(authStateProvider).valueOrNull;
                if (user == null) return;
                if (titleController.text.isEmpty) return;

                final goal = StudyGoal(
                  id: '',
                  userId: user.uid,
                  title: titleController.text.trim(),
                  subject: subjectController.text.trim(),
                  targetHours:
                      double.tryParse(hoursController.text) ?? 0,
                  completedHours: 0,
                  status: 'Not Started',
                  createdAt: DateTime.now(),
                );

                await ref
                    .read(studyGoalNotifierProvider.notifier)
                    .addGoal(goal);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add Goal',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final StudyGoal goal;
  const _GoalCard({required this.goal});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = goal.progressPercentage;

    final statusColor = goal.status == 'Completed'
        ? Colors.green
        : goal.status == 'In Progress'
            ? const Color(0xFF4F46E5)
            : Colors.grey;

    final subjectColor = _getSubjectColor(goal.subject);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    goal.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Three dot menu
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit, size: 18, color: Color(0xFF4F46E5)),
                        SizedBox(width: 8),
                        Text('Edit Goal'),
                        ])),
                        const PopupMenuItem(
                          value: 'progress',
                          child: Row(children: [
                            Icon(Icons.update, size: 18),
                            SizedBox(width: 8),
                            Text('Update Progress'),
                            ])),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                style: TextStyle(color: Colors.red)),
                                ])),
                                ],
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    ref
                                    .read(studyGoalNotifierProvider.notifier)
                                    .deleteGoal(goal.id);
                                    } else if (value == 'progress') {
                                       _showUpdateProgressDialog(context, ref);
                                       } else if (value == 'edit') {
                                        _showEditGoalDialog(context, ref);
                                        }
                                        }
                                        ),
                                        ],
                                        ),
            const SizedBox(height: 8),
            // Title
            Text(
              goal.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            // Subject pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity( 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                goal.subject.toUpperCase(),
                style: TextStyle(
                  color: subjectColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            // Hours and percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.completedHours}h / ${goal.targetHours}h',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
    if (s.contains('english') || s.contains('language')) {
      return Colors.blue;
    }
    return Colors.purple;
  }

  void _showUpdateProgressDialog(BuildContext context, WidgetRef ref) {
    final hoursController =
        TextEditingController(text: goal.completedHours.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Progress',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: hoursController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Completed Hours',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
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
            onPressed: () async {
              final hours =
                  double.tryParse(hoursController.text) ?? 0;
              await ref
                  .read(studyGoalNotifierProvider.notifier)
                  .updateProgress(goal.id, hours, goal.targetHours);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, WidgetRef ref) {
  final titleController = TextEditingController(text: goal.title);
  final subjectController = TextEditingController(text: goal.subject);
  final hoursController =
      TextEditingController(text: goal.targetHours.toString());

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Edit Study Goal',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Goal Title',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFF4F46E5), width: 2),
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
                  borderSide: const BorderSide(
                      color: Color(0xFF4F46E5), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hoursController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Hours',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: Color(0xFF4F46E5), width: 2),
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

            final updatedGoal = StudyGoal(
              id: goal.id,
              userId: goal.userId,
              title: titleController.text.trim(),
              subject: subjectController.text.trim(),
              targetHours:
                  double.tryParse(hoursController.text) ?? goal.targetHours,
              completedHours: goal.completedHours,
              status: goal.status,
              createdAt: goal.createdAt,
            );

            await ref
                .read(studyGoalNotifierProvider.notifier)
                .updateGoal(updatedGoal);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save Changes',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
}