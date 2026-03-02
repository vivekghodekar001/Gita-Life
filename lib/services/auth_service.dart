import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    // TODO: Create user with email/password, save userData to /users/{uid}
    throw UnimplementedError();
  }

  Future<void> loginWithEmail(String email, String password) async {
    // TODO: Sign in with email/password
    throw UnimplementedError();
  }

  Future<void> sendPhoneOtp(String phoneNumber) async {
    // TODO: Firebase Phone Auth - send OTP
    throw UnimplementedError();
  }

  Future<UserCredential> verifyPhoneOtp(
    String verificationId,
    String smsCode,
  ) async {
    // TODO: Verify phone OTP
    throw UnimplementedError();
  }

  Future<void> resetPassword(String email) async {
    // TODO: Send password reset email
    throw UnimplementedError();
  }

  Future<void> updateFcmToken(String uid, String token) async {
    // TODO: Update FCM token in /users/{uid}
    throw UnimplementedError();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    // TODO: Fetch user document from /users/{uid}
    throw UnimplementedError();
  }

  Future<void> logout() async {
    // TODO: Sign out
    throw UnimplementedError();
  }
}
