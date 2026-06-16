import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import 'add_edit_note_screen.dart';

class NoteDetailScreen extends ConsumerWidget {
  final NoteModel note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectColor =
        Color(int.parse(note.subjectColor.replaceFirst('#', '0xFF')));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF4F46E5), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Note Detail',
            style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(
              note.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: note.isBookmarked
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF9CA3AF),
            ),
            onPressed: () => ref
                .read(notesNotifierProvider.notifier)
                .toggleBookmark(note.id, note.isBookmarked),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4F46E5)),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => AddEditNoteScreen(note: note)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: subjectColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: subjectColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(note.subject,
                        style: TextStyle(
                            color: subjectColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
                  ),
                  const SizedBox(height: 10),
                  Text(note.title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined,
                          size: 13, color: subjectColor.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'Updated ${_formatDate(note.updatedAt)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: subjectColor.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                note.content,
                style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF374151),
                    height: 1.8),
              ),
            ),
            const SizedBox(height: 20),

            // Tags
            if (note.tags.isNotEmpty) ...[
              const Text('Tags',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: note.tags
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(t,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4F46E5),
                                  fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Metadata card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _metaRow(Icons.calendar_today_outlined, 'Created',
                      _formatDate(note.createdAt)),
                  const Divider(height: 20, color: Color(0xFFE5E7EB)),
                  _metaRow(Icons.update_outlined, 'Last updated',
                      _formatDate(note.updatedAt)),
                  if (note.tags.isNotEmpty) ...[
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    _metaRow(Icons.label_outline, 'Tags',
                        '${note.tags.length} tag${note.tags.length > 1 ? 's' : ''}'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF6B7280))),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
