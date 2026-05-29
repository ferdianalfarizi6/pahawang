class PaymentModel {
  final String id;
  final String bookingId;
  final String paymentCode;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? paidAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.paymentCode,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      paymentCode: json['payment_code'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'payment_code': paymentCode,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'paid_at': paidAt?.toIso8601String(),
    };
  }
}
