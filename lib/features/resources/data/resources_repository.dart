import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/resource_model.dart';

class ResourcesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference get _resourcesRef =>
      _firestore.collection('users').doc(_userId).collection('resources');

  Stream<List<ResourceModel>> streamResources() {
    return _resourcesRef
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ResourceModel.fromFirestore).toList());
  }

  Future<ResourceModel> addResource({
    required String title,
    required String subject,
    required String fileType,
    required String localPath,
  }) async {
    final now = DateTime.now();
    final docRef = await _resourcesRef.add({
      'userId': _userId,
      'title': title,
      'subject': subject,
      'fileType': fileType,
      // 'type': 'pdf',
      'localPath': localPath,
      'uploadedAt': Timestamp.fromDate(now),
    });
    final doc = await docRef.get();
    return ResourceModel.fromFirestore(doc);
  }

  Future<void> deleteResource(String resourceId) async {
    await _resourcesRef.doc(resourceId).delete();
  }
}