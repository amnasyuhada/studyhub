import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<Map<String, dynamic>?> getProfile() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<String> uploadProfileImage(File image) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
}