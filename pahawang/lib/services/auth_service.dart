import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to listen auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Admin check
  bool get isAdmin => currentUser?.email == 'admin@gmail.com';

  // Sign in
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    await cred.user?.sendEmailVerification();

    // Save user data to Firestore
    await _db.collection('users').doc(cred.user?.uid).set({
      'uid': cred.user?.uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }



  // Resend email verification
  Future<void> resendVerificationEmail() async {
    await currentUser?.sendEmailVerification();
  }

  // Forgot password
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Reload user to get updated emailVerified status
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }
}
