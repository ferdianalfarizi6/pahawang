import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/booking_model.dart';
import '../widgets/premium_card.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve generated booking transaction from route arguments
    final Booking booking = ModalRoute.of(context)!.settings.arguments as Booking;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Beautiful Check Icon Animation Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 72,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pemesanan Berhasil!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Data transaksi Anda telah berhasil disinkronisasi ke server Pulau Pahawang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Digital Receipt Detail Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildReceiptRow('Kode Booking', booking.bookingCode, isCode: true),
                        const Divider(height: 32, color: Color(0xFFF1F3F5)),
                        _buildReceiptRow('Tipe Wisata', booking.bookingType == 'villa' ? '🏡 Villa & Resort' : '🎒 Paket Wisata'),
                        const Divider(height: 32, color: Color(0xFFF1F3F5)),
                        _buildReceiptRow('Metode Bayar', '💸 ${booking.paymentMethod}'),
                        const Divider(height: 32, color: Color(0xFFF1F3F5)),
                        _buildReceiptRow('Total Tagihan', _formatPrice(booking.totalPrice), isPrice: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Actions Buttons using PremiumButton
                  PremiumButton(
                    text: 'Lihat Riwayat Pemesanan',
                    icon: Icons.receipt_long_rounded,
                    isSecondary: true,
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/booking_history', (route) => false);
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      icon: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                      label: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isCode = false, bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: isPrice ? AppColors.accent : AppColors.textDark,
                  fontSize: isPrice ? 16 : 13,
                  fontWeight: (isCode || isPrice) ? FontWeight.bold : FontWeight.w700,
                  fontFamily: isCode ? 'monospace' : null,
                  letterSpacing: isCode ? 1.0 : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
