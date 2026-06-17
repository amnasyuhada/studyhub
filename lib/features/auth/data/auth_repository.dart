import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

 Future<void> reauthenticateAndChangePassword(
    String currentPassword, String newPassword) async {
  final user = _auth.currentUser!;
  final credential = EmailAuthProvider.credential(
    email: user.email!,
    password: currentPassword,
  );
  await user.reauthenticateWithCredential(credential);
  await user.updatePassword(newPassword);
}

Future<UserCredential> signInWithGoogle() async {
  if (defaultTargetPlatform == TargetPlatform.windows) {
    throw Exception('Google Sign-In is not supported on Windows. Please use Android or iOS.');
  }
  final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  if (googleUser == null) throw Exception('Google sign-in cancelled');
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  return await _auth.signInWithCredential(credential);
}

  Future<void> signOut() async {
  try {
    await _googleSignIn.signOut();
  } catch (_) {
    // Google Sign-In not supported on this platform, skip it
  }
  await _auth.signOut();
}

  Future<void> changePassword(String newPassword) async {
    await _auth.currentUser!.updatePassword(newPassword);
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser!.delete();
  }
}