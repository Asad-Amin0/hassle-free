import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _firebaseAuth.currentUser;


  // Only used on mobile (non-web)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Firebase Auth stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Called at app startup — only needed for mobile flow
  Future<void> init() async {
    if (kIsWeb) return; // Web uses Firebase popup, no pre-init needed
    debugPrint('AuthService initialized for mobile');
  }

  // ─── Email / Password ──────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Firebase Sign-In Error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save user to Firestore for better error handling during login (email existence check)
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return credential;
    } catch (e) {
      debugPrint('Firebase Sign-Up Error: $e');
      rethrow;
    }
  }

  /// Check if an email is registered in our Firestore 'users' collection
  Future<bool> doesEmailExist(String email) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking email existence: $e');
      return false; // Fallback
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // ─── Google Sign-In ────────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      return _signInWithGoogleWeb();
    } else {
      return _signInWithGoogleMobile();
    }
  }

  /// Web: uses Firebase's built-in Google popup — no google_sign_in package needed
  Future<UserCredential?> _signInWithGoogleWeb() async {
    try {
      debugPrint('Web Google Sign-In: opening popup...');
      final GoogleAuthProvider googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      final userCredential =
          await _firebaseAuth.signInWithPopup(googleProvider);
      debugPrint(
        'Web Google Sign-In success: ${userCredential.user?.email}',
      );
      return userCredential;
    } catch (e) {
      debugPrint('Web Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Mobile: uses google_sign_in package to get tokens, then Firebase
  Future<UserCredential?> _signInWithGoogleMobile() async {
    try {
      debugPrint('Mobile Google Sign-In: showing account picker...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        debugPrint('Mobile Google Sign-In: user cancelled');
        return null;
      }

      debugPrint('Google account: ${account.email}');
      final GoogleSignInAuthentication auth = await account.authentication;

      debugPrint(
        'Tokens - accessToken: ${auth.accessToken != null}, idToken: ${auth.idToken != null}',
      );

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      debugPrint(
        'Mobile Google Sign-In success: ${userCredential.user?.email}',
      );
      return userCredential;
    } catch (e) {
      debugPrint('Mobile Google Sign-In error: $e');
      rethrow;
    }
  }

  // ─── Password Reset ────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      rethrow;
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Sign-Out error: $e');
    }
  }
}
