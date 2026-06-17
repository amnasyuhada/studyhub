import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepository {
  final _firestore = FirebaseFirestore.instance;
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
    final bytes = await image.readAsBytes();
    // Resize to keep Firestore document under 1MB limit
    final base64String = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64String';
  }
}