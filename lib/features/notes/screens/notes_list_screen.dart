import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import '../widgets/subject_filter_chips.dart';
import '../widgets/empty_notes_state.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';
import '../../resources/screens/resources_screen.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = ref.watch(filteredNotesProvider);
    final showBookmarks = ref.watch(showBookmarksOnlyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, showBookmarks),
            const SizedBox(height: 4),
            _buildSearchBar(),
            const SizedBox(height: 8),
            const SubjectFilterChips(),
            const SizedBox(height: 4),
            Expanded(
              child: filteredNotes.when(
                data: (notes) => notes.isEmpty
                    ? const EmptyNotesState()
                    : _buildNotesList(notes),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Error: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
        ),
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool showBookmarks){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'SH',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StudyHub',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                Text(
                  'Your Study Library',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              showBookmarks ? Icons.bookmark : Icons.bookmark_outline,
              color: showBookmarks
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF9CA3AF),
            ),
            tooltip: showBookmarks ? 'Show all notes' : 'Bookmarked only',
            onPressed: () => ref
                .read(showBookmarksOnlyProvider.notifier)
                .state = !showBookmarks,
          ),
          IconButton(
            icon: const Icon(Icons.folder_outlined, color: Color(0xFF9CA3AF)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResourcesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF9CA3AF)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (val) =>
            ref.read(notesSearchQueryProvider.notifier).state = val,
        decoration: InputDecoration(
          hintText: 'Search notes, subjects, tags...',
          hintStyle:
              const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon:
              const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: Color(0xFF9CA3AF), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(notesSearchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildNotesList(List<NoteModel> notes) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => NoteDetailScreen(note: note)),
          ),
          onBookmark: () => ref
              .read(notesNotifierProvider.notifier)
              .toggleBookmark(note.id, note.isBookmarked),
          onDelete: () => _confirmDelete(context, note.id),
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddEditNoteScreen(note: note)),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Note',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('This note will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF6B7280)))),
          TextButton(
            onPressed: () {
              ref
                  .read(notesNotifierProvider.notifier)
                  .deleteNote(noteId);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
