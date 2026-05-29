import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/booking_model.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${booking.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Villa: ${booking.villaName}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Tanggal: ${booking.date}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Status: ${booking.status}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Edit before payment if pending
                    if (booking.status == 'Pending') {
                      Navigator.pushNamed(context, '/edit_booking', arguments: booking);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Edit Booking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
