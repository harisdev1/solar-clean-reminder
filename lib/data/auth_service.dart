import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/app_keys.dart';
import '../core/app_strings.dart';
import '../firebase_bootstrap.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  bool _googleReady = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String pass) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: pass);

  Future<void> signUp(String email, String pass) =>
      _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: pass);

  Future<void> google() async {
    if (FirebaseBootstrap.usingEmulator) {
      final id =
          'emu-google-${DateTime.now().millisecondsSinceEpoch}@gmail.com';
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: id,
          accessToken: 'emulator-access-token',
        ),
      );
      return;
    }

    final gs = GoogleSignIn.instance;
    if (!_googleReady) {
      await gs.initialize(serverClientId: AppKeys.googleWebClientId);
      _googleReady = true;
    }
    final acc = await gs.authenticate();
    final idToken = acc.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: AppStrings.googleIdTokenMissing,
      );
    }
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  String messageFor(FirebaseAuthException e) => switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          AppStrings.wrongEmailPassword,
        'email-already-in-use' => AppStrings.emailAlreadyUsed,
        'weak-password' => AppStrings.weakPassword,
        'invalid-email' => AppStrings.invalidEmail,
        'network-request-failed' => AppStrings.networkError,
        'operation-not-allowed' => AppStrings.authDisabled,
        'configuration-not-found' ||
        'CONFIGURATION_NOT_FOUND' =>
          AppStrings.authConfigMissing,
        _ => e.message ?? AppStrings.authErrorFallback,
      };
}
