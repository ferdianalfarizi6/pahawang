import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/booking_model.dart';

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
            colors: [Color(0xFF023E8A), Color(0xFF0077B6), Color(0xFF00B4D8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Beautiful Check Icon Animation
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Pemesanan Berhasil!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Data transaksi Anda telah berhasil disinkronisasi ke server Pulau Pahawang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 36),

                  // Receipt Detail Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildReceiptRow('Kode Booking', booking.bookingCode, isCode: true),
                        const Divider(height: 24),
                        _buildReceiptRow('Tipe Wisata', booking.bookingType == 'villa' ? '🏡 Villa & Resort' : 'Excursion Package 🎒'),
                        const Divider(height: 24),
                        _buildReceiptRow('Metode Bayar', '💸 ${booking.paymentMethod}'),
                        const Divider(height: 24),
                        _buildReceiptRow('Total Tagihan', _formatPrice(booking.totalPrice), isPrice: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Actions Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Go to Booking History and clear routes stack
                        Navigator.of(context).pushNamedAndRemoveUntil('/booking_history', (route) => false);
                      },
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('Lihat Riwayat Pemesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Go back to main landing page
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      icon: const Icon(Icons.home_rounded, color: Colors.white),
                      label: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            color: isPrice ? AppColors.accent : AppColors.textDark,
            fontSize: isPrice ? 16 : 13,
            fontWeight: (isCode || isPrice) ? FontWeight.bold : FontWeight.w600,
            fontFamily: isCode ? 'monospace' : null,
            letterSpacing: isCode ? 1.0 : null,
          ),
        ),
      ],
    );
  }
}
