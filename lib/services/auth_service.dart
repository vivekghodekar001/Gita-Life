import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'dart:io';

class AuthService {
  void _ensureFirebase() {
    if (Firebase.apps.isEmpty) {
      throw Exception('[AuthService] Firebase not initialized. Ensure Firebase.initializeApp() is called and verified before accessing this service.');
    }
  }

  FirebaseAuth get _auth {
    _ensureFirebase();
    return FirebaseAuth.instanceFor(app: Firebase.app());
  }

  FirebaseFirestore get _firestore {
    _ensureFirebase();
    return FirebaseFirestore.instanceFor(app: Firebase.app());
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final Map<String, dynamic> firestoreData = {
          ...userData,
          'uid': credential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(firestoreData);
      }
      return credential;
    } catch (e, stack) {
      print('AuthService.registerWithEmail error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e, stack) {
      print('AuthService.loginWithEmail error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> verifyPhoneOtp(
    String verificationId,
    String smsCode,
  ) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e, stack) {
      print('AuthService.verifyPhoneOtp error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e, stack) {
      print('AuthService.resetPassword error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore if document not found
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e, stack) {
      print('AuthService.getUserProfile error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Additional local data clearing should be handled by providers
    } catch (e, stack) {
      print('AuthService.logout error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<String> uploadProfilePhoto(String uid, File file) async {
    _ensureFirebase();
    final refStorage = FirebaseStorage.instanceFor(app: Firebase.app()).ref().child('profile_photos/$uid.jpg');
    await refStorage.putFile(file);
    return await refStorage.getDownloadURL();
  }
}
