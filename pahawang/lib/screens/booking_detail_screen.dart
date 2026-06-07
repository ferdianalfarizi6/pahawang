import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/modern_card.dart';
import '../models/booking_model.dart';
import '../providers/bookings_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/premium_card.dart';

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

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'confirmed':
        return theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399);
      case 'pending':
      case 'waiting':
        return theme.brightness == Brightness.light ? const Color(0xFFD97706) : const Color(0xFFFBBF24);
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleCancel() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Pemesanan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pemesanan ini?\n\nKamar villa/kuota paket Anda akan dilepaskan kembali.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Kembali', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Batalkan', style: TextStyle(fontWeight: FontWeight.bold)),
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
          const SnackBar(content: Text('Pemesanan berhasil dibatalkan.'), backgroundColor: Color(0xFF059669)),
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
    final theme = Theme.of(context);
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
        const SnackBar(content: Text('Status pemesanan berhasil diperbarui.'), backgroundColor: Color(0xFF059669)),
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
    final theme = Theme.of(context);
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
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Detail Pemesanan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Timeline Tracker (Only if not cancelled)
            if (!isCancelled) ...[
              _buildTimelineTracker(booking, theme),
              const SizedBox(height: 20),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text(
                      'Pemesanan ini telah dibatalkan',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Invoice / Receipt Digital Look
            ModernCard(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Invoice Top Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: theme.colorScheme.primary.withOpacity(0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kode Booking',
                                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    booking.bookingCode,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.paymentStatus, theme).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _getStatusColor(booking.paymentStatus, theme).withOpacity(0.2)),
                            ),
                            child: Text(
                              booking.paymentStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(booking.paymentStatus, theme),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F3F5)),

                    // Invoice Core Details
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isVilla ? theme.colorScheme.primary : theme.colorScheme.secondary).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(isVilla ? '🏡' : '🎒', style: const TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isVilla ? 'Villa & Resort' : 'Paket Wisata',
                                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      title,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.onSurface),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: Color(0xFFF1F3F5)),

                          if (booking.user != null) ...[
                            _buildInvoiceRow(Icons.person_outline_rounded, 'Pelanggan', booking.userFullName ?? '-', theme),
                            const SizedBox(height: 12),
                            _buildInvoiceRow(Icons.email_outlined, 'Email', booking.userEmail ?? '-', theme),
                            const SizedBox(height: 12),
                            if (booking.user?.phone != null) ...[
                              _buildInvoiceRow(Icons.phone_android_rounded, 'Nomor HP', booking.user!.phone!, theme),
                              const SizedBox(height: 12),
                            ],
                          ],
                          _buildInvoiceRow(Icons.calendar_month_outlined, 'Jadwal Wisata', dateStr, theme),
                          const SizedBox(height: 12),
                          _buildInvoiceRow(Icons.people_outline_rounded, 'Jumlah Tamu', '${booking.totalGuest} Orang', theme),
                          const SizedBox(height: 12),
                          _buildInvoiceRow(Icons.payment_rounded, 'Metode Bayar', booking.paymentMethod, theme),
                          const SizedBox(height: 12),
                          _buildInvoiceRow(Icons.info_outline_rounded, 'Status Tiket', booking.bookingStatus.toUpperCase(), theme,
                              valColor: _getStatusColor(booking.bookingStatus, theme)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Billing Summary Panel
            ModernCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
                  Text(
                    _formatPrice(booking.totalPrice),
                    style: TextStyle(
                      color: isVilla ? theme.colorScheme.primary : theme.colorScheme.secondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Controls (Admin panel or regular cancel/modify options)
            if (isAdmin) ...[
              ModernCard(
                padding: const EdgeInsets.all(20),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15), width: 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings_rounded, color: theme.colorScheme.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'PANEL KONTROL ADMIN',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ubah status pembayaran dan pemesanan secara langsung.',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const Divider(height: 24),
                    
                    Text('Status Pembayaran', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedPaymentStatus,
                      items: _getAvailablePaymentStatuses(_currentBooking.paymentStatus),
                      onChanged: _isProcessing
                          ? null
                          : (val) {
                              if (val != null) {
                                setState(() => _selectedPaymentStatus = val);
                              }
                            },
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    Text('Status Pemesanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedBookingStatus,
                      items: _getAvailableBookingStatuses(_currentBooking.bookingStatus),
                      onChanged: _isProcessing
                          ? null
                          : (val) {
                              if (val != null) {
                                setState(() => _selectedBookingStatus = val);
                              }
                            },
                      theme: theme,
                    ),
                    const SizedBox(height: 24),

                    PremiumButton(
                      text: 'Simpan Perubahan',
                      isLoading: _isProcessing,
                      onPressed: _handleAdminStatusUpdate,
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (isPaid) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pemesanan ini tidak dapat diubah atau dibatalkan karena sudah lunas.',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isCancelled) ...[
                const SizedBox()
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  Navigator.pushNamed(context, '/edit_booking', arguments: booking);
                                },
                          icon: const Icon(Icons.edit_note_rounded, size: 22),
                          label: const Text('Ubah Jadwal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                    if (booking.bookingStatus.toLowerCase() == 'waiting') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: PremiumButton(
                          text: 'Batalkan',
                          icon: Icons.cancel_outlined,
                          isSecondary: true,
                          onPressed: _isProcessing ? null : _handleHandleCancel,
                        ),
                      ),
                    ],
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

  List<DropdownMenuItem<String>> _getAvailablePaymentStatuses(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'unpaid':
        return const [
          DropdownMenuItem(value: 'unpaid', child: Text('UNPAID (Belum Bayar)')),
          DropdownMenuItem(value: 'pending', child: Text('PENDING (Tertunda)')),
        ];
      case 'pending':
        return const [
          DropdownMenuItem(value: 'pending', child: Text('PENDING (Tertunda)')),
          DropdownMenuItem(value: 'paid', child: Text('PAID (Lunas)')),
        ];
      case 'paid':
        return const [
          DropdownMenuItem(value: 'paid', child: Text('PAID (Lunas)')),
        ];
      case 'cancelled':
        return const [
          DropdownMenuItem(value: 'cancelled', child: Text('CANCELLED (Batal)')),
        ];
      default:
        return [
          DropdownMenuItem(value: currentStatus, child: Text(currentStatus.toUpperCase())),
        ];
    }
  }

  List<DropdownMenuItem<String>> _getAvailableBookingStatuses(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'waiting':
        return const [
          DropdownMenuItem(value: 'waiting', child: Text('WAITING (Menunggu)')),
          DropdownMenuItem(value: 'confirmed', child: Text('CONFIRMED (Dikonfirmasi)')),
          DropdownMenuItem(value: 'cancelled', child: Text('CANCELLED (Dibatalkan)')),
        ];
      case 'confirmed':
        return const [
          DropdownMenuItem(value: 'confirmed', child: Text('CONFIRMED (Dikonfirmasi)')),
          DropdownMenuItem(value: 'completed', child: Text('COMPLETED (Selesai)')),
        ];
      case 'completed':
        return const [
          DropdownMenuItem(value: 'completed', child: Text('COMPLETED (Selesai)')),
        ];
      case 'cancelled':
        return const [
          DropdownMenuItem(value: 'cancelled', child: Text('CANCELLED (Dibatalkan)')),
        ];
      default:
        return [
          DropdownMenuItem(value: currentStatus, child: Text(currentStatus.toUpperCase())),
        ];
    }
  }

  Widget _buildDropdown({required String? value, required List<DropdownMenuItem<String>> items, required ValueChanged<String?>? onChanged, required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurfaceVariant),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(IconData icon, String label, String value, ThemeData theme, {Color? valColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valColor ?? theme.colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTracker(Booking booking, ThemeData theme) {
    // Determine active steps
    final String bStatus = booking.bookingStatus.toLowerCase();
    final String pStatus = booking.paymentStatus.toLowerCase();

    bool step1 = true; // Created is always true
    bool step2 = pStatus == 'paid' || bStatus == 'confirmed' || bStatus == 'completed';
    bool step3 = bStatus == 'confirmed' || bStatus == 'completed';
    bool step4 = bStatus == 'completed';

    return ModernCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Pemesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTimelineNode('Dibuat', step1, true, theme),
              _buildTimelineLine(step2, theme),
              _buildTimelineNode('Bayar', step2, false, theme),
              _buildTimelineLine(step3, theme),
              _buildTimelineNode('Konfirmasi', step3, false, theme),
              _buildTimelineLine(step4, theme),
              _buildTimelineNode('Selesai', step4, false, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(String label, bool isActive, bool isStart, ThemeData theme) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
            child: Icon(
              isActive ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
              size: 14,
              color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineLine(bool isActive, ThemeData theme) {
    return Container(
      width: 25,
      height: 3,
      margin: const EdgeInsets.only(bottom: 15),
      color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
    );
  }
}
