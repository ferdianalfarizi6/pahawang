import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../utils/error_handler.dart';
import '../core/dio_client.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();
  final _dio = DioClient().dio;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _token;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    loadSavedSession();
  }

  // Restore session from Secure Storage on startup
  Future<void> loadSavedSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cachedToken = await _storage.read(key: 'auth_token');
      if (cachedToken != null) {
        _token = cachedToken;
        // Verify cached session token via NestJS backend call
        final response = await _dio.get('/auth/profile');
        if (response.statusCode == 200) {
          _user = UserModel.fromJson(response.data);
          debugPrint('✅ Restored session for user: ${_user?.email}');
        } else {
          await logout();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Session restoration failed: $e');
      _error = ErrorHandler.getErrorMessage(e);
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Admin local bypass check
      if (email.toLowerCase() == 'admin@gmail.com' && password == 'admin123') {
        // Bypass Firebase Authentication signature for local admin testing
        _token = 'admin_token';
        final response = await _dio.post(
          '/auth/firebase-login',
          options: Options(headers: {'Authorization': 'Bearer admin_token'}),
        );
        _user = UserModel.fromJson(response.data);
        await _storage.write(key: 'auth_token', value: 'admin_token');
        await _storage.write(key: 'user_role', value: 'admin');
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // 1. Authenticate with Firebase
      final creds = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final fbUser = creds.user;

      if (fbUser == null) throw Exception('Firebase authentication returned empty user.');

      // Check email verification
      if (!fbUser.emailVerified) {
        throw Exception('Email belum diverifikasi. Silakan cek inbox/spam Anda.');
      }

      // 2. Fetch Firebase ID Token
      final idToken = await fbUser.getIdToken() ?? '';

      // 3. Register or Retrieve user profile in PostgreSQL database via NestJS
      final response = await _dio.post(
        '/auth/firebase-login',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _user = UserModel.fromJson(response.data);
        _token = idToken;
        
        // Save token to secure storage
        await _storage.write(key: 'auth_token', value: idToken);
        await _storage.write(key: 'user_role', value: _user!.role);
        debugPrint('✅ Logged in successfully: ${_user?.email} as ${_user?.role}');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Gagal melakukan sinkronisasi dengan server.');
      }
    } catch (e) {
      if (e is fb.FirebaseAuthException) {
        _error = _getFirebaseErrorMessage(e.code);
      } else {
        _error = ErrorHandler.getErrorMessage(e);
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Create User in Firebase Auth
      final creds = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final fbUser = creds.user;

      if (fbUser == null) throw Exception('Firebase registration returned empty user.');

      // 2. Update Display Name and Send verification email
      await fbUser.updateDisplayName(name);
      await fbUser.sendEmailVerification();

      // 3. Register user directly into PostgreSQL database via NestJS auth login
      final idToken = await fbUser.getIdToken() ?? '';
      await _dio.post(
        '/auth/firebase-login',
        data: {'phone': phone},
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is fb.FirebaseAuthException) {
        _error = _getFirebaseErrorMessage(e.code);
      } else {
        _error = ErrorHandler.getErrorMessage(e);
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset Password
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
    } catch (_) {}

    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_role');
    _user = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Akun tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      default:
        return 'Autentikasi gagal. Silakan coba lagi.';
    }
  }
}
