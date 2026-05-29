import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/error_handler.dart';
import '../core/dio_client.dart';
import '../models/booking_model.dart';

class BookingsProvider with ChangeNotifier {
  final _dio = DioClient().dio;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyBookings({bool isSilent = false}) async {
    if (!isSilent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await _dio.get('/bookings/my');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _bookings = data.map((x) => Booking.fromJson(x)).toList();
      } else {
        throw Exception('Gagal memuat riwayat pemesanan.');
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
    } finally {
      if (!isSilent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<Booking?> createBooking({
    required String bookingType,
    String? villaId,
    String? packageId,
    String? checkIn,
    String? checkOut,
    required int totalGuest,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        'booking_type': bookingType,
        if (villaId != null) 'villa_id': villaId,
        if (packageId != null) 'package_id': packageId,
        if (checkIn != null) 'check_in': checkIn,
        if (checkOut != null) 'check_out': checkOut,
        'total_guest': totalGuest,
        'payment_method': paymentMethod,
      };

      final response = await _dio.post('/bookings', data: payload);
      
      if (response.statusCode == 201) {
        final Booking booking = Booking.fromJson(response.data);
        await fetchMyBookings(isSilent: true); // Silently reload user history list in the background
        _isLoading = false;
        notifyListeners();
        return booking;
      } else {
        throw Exception('Gagal melakukan checkout.');
      }
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> editBooking({
    required String id,
    String? checkIn,
    String? checkOut,
    int? totalGuest,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        if (checkIn != null) 'check_in': checkIn,
        if (checkOut != null) 'check_out': checkOut,
        if (totalGuest != null) 'total_guest': totalGuest,
      };

      final response = await _dio.patch('/bookings/$id', data: payload);
      if (response.statusCode == 200) {
        await fetchMyBookings(isSilent: true);
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

  Future<bool> cancelBooking(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // User cancelling maps to a secure cancel transaction endpoint
      final response = await _dio.patch('/bookings/$id/cancel');
      if (response.statusCode == 200) {
        await fetchMyBookings(isSilent: true);
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
