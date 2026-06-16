import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notes_repository.dart';
import '../models/note_model.dart';

// Repository
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

final notesStreamProvider = StreamProvider<List<NoteModel>>((ref) {
  return ref.watch(notesRepositoryProvider).streamNotes();
});

// Search 
final notesSearchQueryProvider = StateProvider<String>((ref) => '');

// Subject filter 
final selectedSubjectProvider = StateProvider<String?>((ref) => null);

// Bookmarks toggle 
final showBookmarksOnlyProvider = StateProvider<bool>((ref) => false);

// Filtered notes 
final filteredNotesProvider = Provider<AsyncValue<List<NoteModel>>>((ref) {
  final notesAsync = ref.watch(notesStreamProvider);
  final query = ref.watch(notesSearchQueryProvider).toLowerCase();
  final subject = ref.watch(selectedSubjectProvider);
  final bookmarksOnly = ref.watch(showBookmarksOnlyProvider);

  return notesAsync.whenData((notes) {
    return notes.where((note) {
      final matchesSearch = query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query) ||
          note.subject.toLowerCase().contains(query) ||
          note.tags.any((t) => t.toLowerCase().contains(query));
      final matchesSubject = subject == null || note.subject == subject;
      final matchesBookmark = !bookmarksOnly || note.isBookmarked;
      return matchesSearch && matchesSubject && matchesBookmark;
    }).toList();
  });
});

// Derived subjects from notes 
final subjectsProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(notesStreamProvider).whenData((notes) {
    final subjects = notes.map((n) => n.subject).toSet().toList();
    subjects.sort();
    return subjects;
  });
});

final notesNotifierProvider =
    AsyncNotifierProvider<NotesNotifier, void>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  NotesRepository get _repo => ref.read(notesRepositoryProvider);

  Future<NoteModel> createNote({
    required String title,
    required String content,
    required String subject,
    String subjectColor = '#4F46E5',
    List<String> tags = const [],
  }) async {
    return _repo.createNote(
      title: title,
      content: content,
      subject: subject,
      subjectColor: subjectColor,
      tags: tags,
    );
  }

  Future<void> updateNote(NoteModel note) async {
    await _repo.updateNote(note);
  }

  Future<void> deleteNote(String noteId) async {
    await _repo.deleteNote(noteId);
  }

  Future<void> toggleBookmark(String noteId, bool current) async {
    await _repo.toggleBookmark(noteId, current);
  }
}
