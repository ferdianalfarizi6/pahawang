import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/error_handler.dart';
import '../core/dio_client.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';

class AdminProvider with ChangeNotifier {
  final _dio = DioClient().dio;

  Map<String, dynamic> _stats = {};
  List<Booking> _recentBookings = [];
  List<dynamic> _recentPayments = [];

  List<Booking> _allBookings = [];
  List<UserModel> _allUsers = [];

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get stats => _stats;
  List<Booking> get recentBookings => _recentBookings;
  List<dynamic> get recentPayments => _recentPayments;
  List<Booking> get allBookings => _allBookings;
  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get('/admin/dashboard');
      if (response.statusCode == 200) {
        _stats = response.data['stats'] ?? {};
        final List<dynamic> bookingsData = response.data['recentBookings'] ?? [];
        _recentBookings = bookingsData.map((x) => Booking.fromJson(x)).toList();
        _recentPayments = response.data['recentPayments'] ?? [];
      } else {
        throw Exception('Gagal memuat statistik dashboard.');
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllBookings({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = {
        'page': 1,
        'limit': 50,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dio.get('/admin/bookings', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _allBookings = data.map((x) => Booking.fromJson(x)).toList();
      } else {
        throw Exception('Gagal memuat pesanan sistem.');
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = {
        'page': 1,
        'limit': 50,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dio.get('/admin/users', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _allUsers = data.map((x) => UserModel.fromJson(x)).toList();
      } else {
        throw Exception('Gagal memuat daftar pengguna.');
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus({
    required String bookingId,
    required String paymentStatus,
    required String bookingStatus,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        'payment_status': paymentStatus,
        'booking_status': bookingStatus,
      };

      final response = await _dio.patch('/bookings/$bookingId/status', data: payload);
      if (response.statusCode == 200) {
        await fetchDashboardStats(); // Refresh dashboard KPIs
        await fetchAllBookings(); // Refresh bookings list
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
