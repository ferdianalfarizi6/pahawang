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
      if (cachedToken == 'admin_token') {
        _token = cachedToken;
        final response = await _dio.get('/auth/profile');
        if (response.statusCode == 200) {
          _user = UserModel.fromJson(response.data);
          debugPrint('✅ Restored admin bypass session: ${_user?.email}');
        } else {
          await logout();
        }
      } else {
        // Firebase user session recovery
        final fbUser = _auth.currentUser;
        if (fbUser != null) {
          if (fbUser.emailVerified) {
            // Get fresh ID token (false to get cached if valid, or auto‑refresh if expired)
            final idToken = await fbUser.getIdToken(false);
            if (idToken != null) {
              _token = idToken;
              await _storage.write(key: 'auth_token', value: idToken);
              
              final response = await _dio.get('/auth/profile');
              if (response.statusCode == 200) {
                _user = UserModel.fromJson(response.data);
                debugPrint('✅ Restored Firebase session: ${_user?.email}');
              } else {
                await logout();
              }
            } else {
              await logout();
            }
          } else {
            // User logged in but email not verified
            await logout();
          }
        } else {
          // No active user session
          await logout();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Session restoration failed: $e');
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

      // 2. Fetch Firebase ID Token (forced refresh)
      final idToken = await fbUser.getIdToken(true) ?? '';

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

  // Login after email verification reload
  Future<bool> loginAfterVerification() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fbUser = _auth.currentUser;
      if (fbUser == null) {
        throw Exception('Tidak ada pengguna Firebase yang aktif. Silakan masuk kembali.');
      }

      // Reload user data to check email verification status
      await fbUser.reload();

      if (!fbUser.emailVerified) {
        throw Exception('Email belum diverifikasi. Silakan cek inbox/spam Anda.');
      }

      // Fetch Firebase ID Token
      final idToken = await fbUser.getIdToken(true) ?? '';

      // Register or Retrieve user profile in PostgreSQL database via NestJS
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
        debugPrint('✅ Logged in successfully after email verification: ${_user?.email} as ${_user?.role}');
        
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

  // Register (Firebase Auth Creation Only)
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

  // Finalize Registration (Sync with NestJS and Save Session) after OTP is verified
  Future<bool> finalizeRegistration(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fbUser = _auth.currentUser;
      if (fbUser == null) {
        throw Exception('Pengguna Firebase tidak ditemukan. Silakan daftarkan kembali.');
      }

      // Fetch fresh Firebase ID Token
      final idToken = await fbUser.getIdToken(true) ?? '';

      // Register or Retrieve user profile in PostgreSQL database via NestJS
      final response = await _dio.post(
        '/auth/firebase-login',
        data: {'phone': phone},
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _user = UserModel.fromJson(response.data);
        _token = idToken;
        
        // Save token to secure storage
        await _storage.write(key: 'auth_token', value: idToken);
        await _storage.write(key: 'user_role', value: _user!.role);
        debugPrint('✅ Registration finalized successfully: ${_user?.email} as ${_user?.role}');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Gagal melakukan sinkronisasi dengan server database.');
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
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
        return 'Autentikasi gagal ($code). Silakan coba lagi.';
    }
  }
}
