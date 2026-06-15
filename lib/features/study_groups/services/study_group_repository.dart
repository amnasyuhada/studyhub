import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/study_group.dart';

/// Firestore structure:
///   study_groups/{groupId}
///   study_groups/{groupId}/announcements/{id}
///   study_groups/{groupId}/discussions/{id}
class StudyGroupRepository {
  StudyGroupRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user — cannot access groups.');
    }
    return user.uid;
  }

  String get _displayName =>
      _auth.currentUser?.displayName ?? _auth.currentUser?.email ?? 'Member';

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('study_groups');

  /// Stream of groups the current user belongs to.
  Stream<List<StudyGroup>> watchMyGroups() {
    return _groups
        .where('memberIds', arrayContains: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => StudyGroup.fromMap(d.id, d.data())).toList());
  }

  Stream<StudyGroup?> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map(
        (doc) => doc.exists ? StudyGroup.fromMap(doc.id, doc.data()!) : null);
  }

  /// Creates a new group owned by the current user and returns its id.
  Future<String> createGroup({
    required String name,
    required String description,
  }) async {
    final joinCode = _generateJoinCode();
    final doc = await _groups.add({
      'name': name,
      'description': description,
      'ownerId': _uid,
      'memberIds': [_uid],
      'joinCode': joinCode,
      'createdAt': Timestamp.now(),
    });
    return doc.id;
  }

  /// Joins a group using its 6-character join code.
  /// Returns the group id on success, or null if no group matches.
  Future<String?> joinGroupByCode(String code) async {
    final query = await _groups
        .where('joinCode', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;

    final groupDoc = query.docs.first;
    await groupDoc.reference.update({
      'memberIds': FieldValue.arrayUnion([_uid]),
    });
    return groupDoc.id;
  }

  Future<void> leaveGroup(String groupId) {
    return _groups.doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([_uid]),
    });
  }

  // ---- Announcements ----

  Stream<List<GroupAnnouncement>> watchAnnouncements(String groupId) {
    return _groups
        .doc(groupId)
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GroupAnnouncement.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> postAnnouncement(String groupId, String message) {
    return _groups.doc(groupId).collection('announcements').add({
      'authorId': _uid,
      'authorName': _displayName,
      'message': message,
      'createdAt': Timestamp.now(),
    });
  }

  // ---- Discussion board ----

  Stream<List<DiscussionPost>> watchDiscussion(String groupId) {
    return _groups
        .doc(groupId)
        .collection('discussions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DiscussionPost.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> postDiscussionMessage(String groupId, String message) {
    return _groups.doc(groupId).collection('discussions').add({
      'authorId': _uid,
      'authorName': _displayName,
      'message': message,
      'createdAt': Timestamp.now(),
    });
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}