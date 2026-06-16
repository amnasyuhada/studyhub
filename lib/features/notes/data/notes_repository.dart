import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';

class NotesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _notesRef =>
      _firestore.collection('users').doc(_userId).collection('notes');

  Stream<List<NoteModel>> streamNotes() {
    return _notesRef
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(NoteModel.fromFirestore).toList());
  }

  // Create note
  Future<NoteModel> createNote({
    required String title,
    required String content,
    required String subject,
    String subjectColor = '#4F46E5',
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final docRef = await _notesRef.add({
      'userId': _userId,
      'title': title,
      'content': content,
      'subject': subject,
      'subjectColor': subjectColor,
      'tags': tags,
      'isBookmarked': false,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    final doc = await docRef.get();
    return NoteModel.fromFirestore(doc);
  }

  // Update note
  Future<void> updateNote(NoteModel note) async {
    await _notesRef.doc(note.id).update({
      ...note.toMap(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  //  Delete note
  Future<void> deleteNote(String noteId) async {
    await _notesRef.doc(noteId).delete();
  }

  // Bookmark note
  Future<void> toggleBookmark(String noteId, bool current) async {
    await _notesRef.doc(noteId).update({'isBookmarked': !current});
  }
}
