import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../utils/colors.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAllBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _refreshBookings() async {
    await Provider.of<AdminProvider>(context, listen: false)
        .fetchAllBookings(search: _searchController.text);
  }

  String _formatRupiah(num val) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  Widget _buildStatusChip(String status, bool isBooking) {
    Color color;
    String label = status.toUpperCase();

    if (isBooking) {
      switch (status.toLowerCase()) {
        case 'waiting':
          color = AppColors.warning;
          label = 'Menunggu';
          break;
        case 'confirmed':
          color = AppColors.primary;
          label = 'Dikonfirmasi';
          break;
        case 'completed':
          color = AppColors.success;
          label = 'Selesai';
          break;
        case 'cancelled':
          color = Colors.red;
          label = 'Dibatalkan';
          break;
        default:
          color = AppColors.textLight;
      }
    } else {
      switch (status.toLowerCase()) {
        case 'unpaid':
          color = Colors.redAccent;
          label = 'Belum Bayar';
          break;
        case 'paid':
          color = AppColors.success;
          label = 'Lunas';
          break;
        case 'refunded':
          color = Colors.blueGrey;
          label = 'Refund';
          break;
        default:
          color = AppColors.textLight;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Elegant Search Bar Container
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan kode booking atau nama...',
                hintStyle: const TextStyle(color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMedium),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMedium),
                        onPressed: () {
                          _searchController.clear();
                          _refreshBookings();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accentLight, width: 2),
                ),
              ),
              onChanged: (val) {
                // Implement search debounce or instant search
                _refreshBookings();
              },
            ),
          ),

          // Bookings List View
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshBookings,
              color: AppColors.primary,
              child: adminProvider.isLoading && adminProvider.allBookings.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : adminProvider.error != null && adminProvider.allBookings.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                                const SizedBox(height: 16),
                                Text(
                                  'Gagal memuat daftar pesanan:\n${adminProvider.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16, color: AppColors.textMedium),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _refreshBookings,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Coba Lagi'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : adminProvider.allBookings.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.receipt_long_rounded, size: 80, color: AppColors.textLight),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Tidak ada pesanan ditemukan',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _searchController.text.isNotEmpty
                                            ? 'Coba ganti kata kunci pencarian Anda.'
                                            : 'Sistem belum mendeteksi adanya transaksi booking.',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: adminProvider.allBookings.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final booking = adminProvider.allBookings[index];
                                final isVilla = booking.bookingType == 'villa';
                                final assetName = isVilla
                                    ? (booking.villaName ?? 'Villa')
                                    : (booking.packageName ?? 'Paket Wisata');

                                final checkInDate = booking.checkIn != null
                                    ? DateFormat('dd MMM yyyy').format(booking.checkIn!)
                                    : '-';

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/booking_detail',
                                          arguments: booking,
                                        ).then((_) => _refreshBookings());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: (isVilla ? AppColors.primary : AppColors.accent).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        isVilla ? '🏡 ' : '🎒 ',
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                      Text(
                                                        isVilla ? 'Villa' : 'Paket',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                          color: isVilla ? AppColors.primary : AppColors.accent,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  booking.bookingCode,
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textDark,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              assetName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.person_rounded, size: 14, color: AppColors.textLight),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    booking.userFullName ?? booking.userEmail ?? 'User ID: ${booking.userId}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textLight),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Wisata: $checkInDate',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 24),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Total Harga',
                                                      style: TextStyle(fontSize: 10, color: AppColors.textLight),
                                                    ),
                                                    Text(
                                                      _formatRupiah(booking.totalPrice),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    _buildStatusChip(booking.bookingStatus, true),
                                                    const SizedBox(width: 6),
                                                    _buildStatusChip(booking.paymentStatus, false),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
