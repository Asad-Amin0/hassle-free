import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
    String password,
  ) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Firebase Sign-Up Error: $e');
      rethrow;
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
