import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../models/booking_model.dart';
import '../providers/bookings_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isProcessing = false;
  late Booking _currentBooking;
  String? _selectedPaymentStatus;
  String? _selectedBookingStatus;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    _selectedPaymentStatus = _currentBooking.paymentStatus.toLowerCase();
    _selectedBookingStatus = _currentBooking.bookingStatus.toLowerCase();
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'confirmed':
        return AppColors.success;
      case 'pending':
      case 'waiting':
        return AppColors.warning;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pemesanan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pemesanan ini?\n\nKamar villa/kuota paket Anda akan dilepaskan kembali.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Kembali', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessing = true);
      final success = await Provider.of<BookingsProvider>(context, listen: false).cancelBooking(_currentBooking.id);
      setState(() => _isProcessing = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemesanan berhasil dibatalkan.'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      } else {
        if (mounted) {
          final error = Provider.of<BookingsProvider>(context, listen: false).error ?? 'Gagal membatalkan pemesanan.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  Future<void> _handleAdminStatusUpdate() async {
    if (_selectedPaymentStatus == null || _selectedBookingStatus == null) return;

    setState(() => _isProcessing = true);
    final success = await Provider.of<AdminProvider>(context, listen: false).updateBookingStatus(
      bookingId: _currentBooking.id,
      paymentStatus: _selectedPaymentStatus!,
      bookingStatus: _selectedBookingStatus!,
    );
    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status pemesanan berhasil diperbarui.'), backgroundColor: AppColors.success),
      );
      setState(() {
        _currentBooking = Booking(
          id: _currentBooking.id,
          bookingCode: _currentBooking.bookingCode,
          userId: _currentBooking.userId,
          bookingType: _currentBooking.bookingType,
          villaId: _currentBooking.villaId,
          packageId: _currentBooking.packageId,
          checkIn: _currentBooking.checkIn,
          checkOut: _currentBooking.checkOut,
          totalGuest: _currentBooking.totalGuest,
          totalPrice: _currentBooking.totalPrice,
          paymentMethod: _currentBooking.paymentMethod,
          paymentStatus: _selectedPaymentStatus!,
          bookingStatus: _selectedBookingStatus!,
          createdAt: _currentBooking.createdAt,
          user: _currentBooking.user,
          villa: _currentBooking.villa,
          package: _currentBooking.package,
          payments: _currentBooking.payments,
        );
      });
    } else {
      if (mounted) {
        final error = Provider.of<AdminProvider>(context, listen: false).error ?? 'Gagal memperbarui status.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _currentBooking;
    final isVilla = booking.bookingType == 'villa';
    final title = isVilla ? (booking.villa?.name ?? 'Villa') : (booking.package?.title ?? 'Paket Wisata');
    final isPaid = booking.paymentStatus.toLowerCase() == 'paid';
    final isCancelled = booking.bookingStatus.toLowerCase() == 'cancelled';
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;

    final dateStr = isVilla
        ? '${DateFormat('dd MMMM yyyy').format(booking.checkIn!)} - ${DateFormat('dd MMMM yyyy').format(booking.checkOut!)}'
        : DateFormat('dd MMMM yyyy').format(booking.checkIn!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Pemesanan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Booking Code Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kode Booking', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                        booking.bookingCode,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Status Bayar', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.paymentStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.paymentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.paymentStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Booking Asset Detail Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rincian Destinasi', style: AppTheme.heading3),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isVilla ? AppColors.primary : AppColors.accent).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(isVilla ? '🏡' : '🎒', style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  if (booking.user != null) ...[
                    _buildDetailRow(Icons.person_rounded, 'Pelanggan', booking.userFullName ?? '-'),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.email_rounded, 'Email', booking.userEmail ?? '-'),
                    const SizedBox(height: 12),
                    if (booking.user?.phone != null) ...[
                      _buildDetailRow(Icons.phone_rounded, 'Nomor HP', booking.user!.phone!),
                      const SizedBox(height: 12),
                    ],
                  ],
                  _buildDetailRow(Icons.calendar_month_rounded, 'Jadwal Wisata', dateStr),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.people_rounded, 'Jumlah Tamu', '${booking.totalGuest} Orang'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.payments_rounded, 'Metode Bayar', booking.paymentMethod),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.info_outline_rounded, 'Status Tiket', booking.bookingStatus.toUpperCase(),
                      valueColor: _getStatusColor(booking.bookingStatus)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Billing Summary Panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMedium)),
                  Text(
                    _formatPrice(booking.totalPrice),
                    style: TextStyle(
                      color: isVilla ? AppColors.primary : AppColors.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 4. ADMIN PANEL CONTROL OR USER INTERACTIVE CONTROLS
            if (isAdmin) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'PANEL KONTROL ADMIN',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ubah status pembayaran dan pemesanan secara langsung.',
                      style: TextStyle(fontSize: 12, color: AppColors.textLight),
                    ),
                    const Divider(height: 24),
                    
                    // Payment Status Dropdown
                    const Text('Status Pembayaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMedium)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPaymentStatus,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'unpaid', child: Text('UNPAID (Belum Bayar)')),
                            DropdownMenuItem(value: 'paid', child: Text('PAID (Lunas)')),
                            DropdownMenuItem(value: 'refunded', child: Text('REFUNDED (Dikembalikan)')),
                          ],
                          onChanged: _isProcessing
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() => _selectedPaymentStatus = val);
                                  }
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Booking Status Dropdown
                    const Text('Status Pemesanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMedium)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBookingStatus,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'waiting', child: Text('WAITING (Menunggu)')),
                            DropdownMenuItem(value: 'confirmed', child: Text('CONFIRMED (Dikonfirmasi)')),
                            DropdownMenuItem(value: 'completed', child: Text('COMPLETED (Selesai)')),
                            DropdownMenuItem(value: 'cancelled', child: Text('CANCELLED (Dibatalkan)')),
                          ],
                          onChanged: _isProcessing
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() => _selectedBookingStatus = val);
                                  }
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _handleAdminStatusUpdate,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded, size: 20),
                        label: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Standard User flow
              if (isPaid) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pemesanan ini tidak dapat diubah atau dibatalkan karena sudah lunas.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isCancelled) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cancel_presentation_rounded, color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pemesanan ini telah dibatalkan.',
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    // Edit Booking button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  Navigator.pushNamed(context, '/edit_booking', arguments: booking);
                                },
                          icon: const Icon(Icons.edit_note_rounded, size: 20),
                          label: const Text('Ubah Jadwal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Cancel Booking button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _handleHandleCancel,
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Batalkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _handleHandleCancel() {
    _handleCancel();
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
