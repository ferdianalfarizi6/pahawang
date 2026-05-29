import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../models/booking_model.dart';
import '../providers/bookings_provider.dart';

class EditBookingScreen extends StatefulWidget {
  final Booking booking;
  const EditBookingScreen({super.key, required this.booking});

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _totalGuest = 1;

  @override
  void initState() {
    super.initState();
    _checkIn = widget.booking.checkIn;
    _checkOut = widget.booking.checkOut;
    _totalGuest = widget.booking.totalGuest;
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isVilla = booking.bookingType == 'villa';
    final title = isVilla ? (booking.villa?.name ?? 'Villa') : (booking.package?.title ?? 'Paket Wisata');
    final maxCapacity = isVilla ? (booking.villa?.maxGuest ?? 6) : (booking.package?.quota ?? 30);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ubah Jadwal Pemesanan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<BookingsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking Code & Info Panel
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.cardDecoration,
                        child: Row(
                          children: [
                            const Text('📍 ', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kode: ${booking.bookingCode}',
                                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Date Fields Picker
                      Text('Ubah Tanggal', style: AppTheme.heading3),
                      const SizedBox(height: 12),
                      if (isVilla) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateTile(
                                label: 'Check-In',
                                date: _checkIn,
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _checkIn ?? DateTime.now().add(const Duration(days: 1)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 90)),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _checkIn = picked;
                                      if (_checkOut != null && _checkOut!.isBefore(_checkIn!)) {
                                        _checkOut = null;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDateTile(
                                label: 'Check-Out',
                                date: _checkOut,
                                onTap: () async {
                                  if (_checkIn == null) return;
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _checkOut ?? _checkIn!.add(const Duration(days: 1)),
                                    firstDate: _checkIn!.add(const Duration(days: 1)),
                                    lastDate: _checkIn!.add(const Duration(days: 90)),
                                  );
                                  if (picked != null) {
                                    setState(() => _checkOut = picked);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        _buildDateTile(
                          label: 'Tanggal Kunjungan',
                          date: _checkIn,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _checkIn ?? DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              setState(() => _checkIn = picked);
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Guest Stepper
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Jumlah Tamu', style: AppTheme.heading3),
                              const SizedBox(height: 4),
                              Text('Maksimum kapasitas: $maxCapacity orang', style: AppTheme.caption),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: _totalGuest > 1
                                      ? () => setState(() => _totalGuest--)
                                      : null,
                                ),
                                Text(
                                  '$_totalGuest',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: _totalGuest < maxCapacity
                                      ? () => setState(() => _totalGuest++)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom sticky save panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : () async {
                      if (_checkIn == null) return;
                      if (isVilla && _checkOut == null) return;

                      final success = await provider.editBooking(
                        id: booking.id,
                        checkIn: _checkIn!.toIso8601String(),
                        checkOut: isVilla ? _checkOut!.toIso8601String() : null,
                        totalGuest: _totalGuest,
                      );

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jadwal pemesanan berhasil diperbarui.'), backgroundColor: AppColors.success),
                        );
                        // Pop and redirect to refresh history list
                        Navigator.of(context).pushNamedAndRemoveUntil('/booking_history', (route) => false);
                      } else {
                        if (mounted && provider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error!), backgroundColor: Colors.redAccent),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateTile({required String label, DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : '--/--/----',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
            const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
