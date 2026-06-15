import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/study_session.dart';

/// Handles all Firestore reads/writes for study sessions.
///
/// Firestore structure:
///   study_sessions/{uid}/sessions/{sessionId}
class StudySessionRepository {
  StudySessionRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user — cannot access sessions.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('study_sessions').doc(_uid).collection('sessions');

  /// Stream of ALL sessions for the current user, ordered by date.
  Stream<List<StudySession>> watchAll() {
    return _collection.orderBy('date').snapshots().map(
          (snap) => snap.docs
              .map((d) => StudySession.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// Stream of sessions for one specific calendar day.
  Stream<List<StudySession>> watchByDate(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StudySession.fromMap(d.id, d.data()))
            .toList());
  }

  /// Stream of sessions between [start] (inclusive) and [end] (exclusive),
  /// used for the weekly planner view.
  Stream<List<StudySession>> watchRange(DateTime start, DateTime end) {
    return _collection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StudySession.fromMap(d.id, d.data()))
            .toList());
  }

  Future<String> addSession(StudySession session) async {
    final doc = await _collection.add(session.toMap());
    return doc.id;
  }

  Future<void> updateSession(StudySession session) {
    return _collection.doc(session.id).update(session.toMap());
  }

  Future<void> deleteSession(String sessionId) {
    return _collection.doc(sessionId).delete();
  }

  Future<void> toggleCompleted(String sessionId, bool isCompleted) {
    return _collection.doc(sessionId).update({'isCompleted': isCompleted});
  }
}