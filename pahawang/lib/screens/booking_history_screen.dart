import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'booking_detail_screen.dart';
import '../models/booking_model.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  // Dummy bookings
  final List<Booking> bookings = const [
    Booking(id: 'B001', villaName: 'Villa Sunset', date: '2024-08-15', status: 'Pending'),
    Booking(id: 'B002', villaName: 'Villa Ocean', date: '2024-09-01', status: 'Paid'),
    Booking(id: 'B003', villaName: 'Villa Breeze', date: '2024-07-20', status: 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(booking.villaName),
              subtitle: Text('Tanggal: ${booking.date}\nStatus: ${booking.status}'),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking)),
              ),
            ),
          );
        },
      ),
    );
  }
}
