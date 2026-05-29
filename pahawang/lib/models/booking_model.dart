import 'villa_model.dart';
import 'user_model.dart';
import 'package:pahawang/models/package_model.dart';
import 'package:pahawang/models/payment_model.dart';

class Booking {
  final String id;
  final String bookingCode;
  final String userId;
  final String bookingType; // "villa" or "package"
  final String? villaId;
  final String? packageId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int totalGuest;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus; // unpaid, pending, paid, cancelled
  final String bookingStatus; // waiting, confirmed, completed, cancelled
  final DateTime createdAt;

  // Relations
  final UserModel? user;
  final Villa? villa;
  final TourPackage? package;
  final List<PaymentModel>? payments;

  const Booking({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.bookingType,
    this.villaId,
    this.packageId,
    this.checkIn,
    this.checkOut,
    required this.totalGuest,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.createdAt,
    this.user,
    this.villa,
    this.package,
    this.payments,
  });

  String? get userEmail => user?.email;
  String? get userFullName => user?.fullName;
  String? get villaName => villa?.name;
  String? get packageName => package?.title;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      bookingCode: json['booking_code'] ?? '',
      userId: json['user_id'] ?? '',
      bookingType: json['booking_type'] ?? '',
      villaId: json['villa_id'],
      packageId: json['package_id'],
      checkIn: json['check_in'] != null ? DateTime.parse(json['check_in']) : null,
      checkOut: json['check_out'] != null ? DateTime.parse(json['check_out']) : null,
      totalGuest: json['total_guest'] ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      bookingStatus: json['booking_status'] ?? 'waiting',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      villa: json['villa'] != null ? Villa.fromJson(json['villa']) : null,
      package: json['package'] != null ? TourPackage.fromJson(json['package']) : null,
      payments: json['payments'] != null
          ? List<PaymentModel>.from(json['payments'].map((x) => PaymentModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'user_id': userId,
      'booking_type': bookingType,
      'villa_id': villaId,
      'package_id': packageId,
      'check_in': checkIn?.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'total_guest': totalGuest,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'booking_status': bookingStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

