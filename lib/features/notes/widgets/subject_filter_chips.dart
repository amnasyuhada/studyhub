import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';

class SubjectFilterChips extends ConsumerWidget {
  const SubjectFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final selectedSubject = ref.watch(selectedSubjectProvider);

    return subjectsAsync.when(
      data: (subjects) {
        if (subjects.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _Chip(
                label: 'All Notes',
                isSelected: selectedSubject == null,
                onTap: () => ref
                    .read(selectedSubjectProvider.notifier)
                    .state = null,
              ),
              ...subjects.map((s) => _Chip(
                    label: s,
                    isSelected: selectedSubject == s,
                    onTap: () => ref
                        .read(selectedSubjectProvider.notifier)
                        .state = s,
                  )),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 44),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
