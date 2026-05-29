import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _otpKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZGVudGlmaWVyIjoyNDUxNn0.Vec-8W8bETGZfg8JSa_8b90SNZ85GrnBw1YMik_ihj8";
  // Gateway key for Fazpass OTP (different from merchant token)
  final String _gatewayKey = "6ede320b-afb0-4164-9a4f-224a1fe2ceb2";
  String? _otpId;
  String? _lastPhone;

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

  Future<bool> sendOTP(String phone) async {
    _lastPhone = phone;

    try {
      final response = await http.post(
        Uri.parse('https://api.fazpass.com/v1/otp/request'),
        headers: {
          'Authorization': 'Bearer $_otpKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'gateway_key': _gatewayKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          _otpId = data['data']['id'];
          return true;
        }
        return false;
      } else {
        debugPrint('Fazpass OTP Error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('OTP Error: $e');
      return false;
    }
  }

  Future<bool> verifyOTP(String otp) async {
    if (_otpId == null) return false;

    try {
      final response = await http.post(
        Uri.parse('https://api.fazpass.com/v1/otp/verify'),
        headers: {
          'Authorization': 'Bearer $_otpKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'otp_id': _otpId,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Verify Error: $e');
      return false;
    }
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
