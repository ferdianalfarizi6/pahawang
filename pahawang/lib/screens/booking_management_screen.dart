import 'package:flutter/material.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
      ),
      body: const Center(
        child: Text('Booking management UI (dummy).'),
      ),
    );
  }
}
