import 'package:flutter/material.dart';

class EmptyNotesState extends StatelessWidget {
  const EmptyNotesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.note_add_outlined,
                  size: 40, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No notes yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to create your first note and start organizing your study materials.',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
