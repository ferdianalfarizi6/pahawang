import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/colors.dart';
import '../models/booking_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchDashboardStats();
    });
  }

  Future<void> _refreshStats() async {
    await Provider.of<AdminProvider>(context, listen: false).fetchDashboardStats();
  }

  String _formatRupiah(num val) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar dari Akun'),
                  content: const Text('Apakah Anda yakin ingin keluar dari akun Admin?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              }
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        color: AppColors.primary,
        child: adminProvider.isLoading && adminProvider.stats.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : adminProvider.error != null && adminProvider.stats.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat data dashboard:\n${adminProvider.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: AppColors.textMedium),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _refreshStats,
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
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Banner Widget
                        _buildWelcomeBanner(authProvider.user?.fullName ?? 'Administrator'),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quick Navigation Actions
                              const SizedBox(height: 8),
                              const Text(
                                'Akses Cepat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickNavCard(
                                      context,
                                      Icons.holiday_village_rounded,
                                      'Kelola Villa',
                                      'Atur akomodasi & fasilitas',
                                      AppColors.primary,
                                      '/manage_villas',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickNavCard(
                                      context,
                                      Icons.list_alt_rounded,
                                      'Pesanan',
                                      'Manajemen booking & bayar',
                                      AppColors.accent,
                                      '/booking_management',
                                    ),
                                  ),
                                ],
                              ),

                              // Key Metrics KPIs Grid
                              const SizedBox(height: 24),
                              const Text(
                                'Statistik Kunci',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildStatsGrid(adminProvider.stats),

                              // Recent Bookings (Last 5)
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Pemesanan Terbaru',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(context, '/booking_management'),
                                    child: const Text('Lihat Semua'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildRecentBookingsList(adminProvider.recentBookings),

                              // Recent Payments
                              const SizedBox(height: 24),
                              const Text(
                                'Pembayaran Terbaru',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildRecentPaymentsList(adminProvider.recentPayments),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildWelcomeBanner(String adminName) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.admin_panel_settings_rounded, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      adminName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Kelola villa, awasi pesanan masuk, dan pantau performa bisnis dari satu dashboard terpusat.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavCard(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    Color color,
    String route,
  ) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    final revenue = stats['totalRevenue'] ?? 0;
    final bookings = stats['totalBookings'] ?? 0;
    final active = stats['activeBookings'] ?? 0;
    final users = stats['totalUsers'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Pendapatan',
          _formatRupiah(revenue),
          Icons.monetization_on_rounded,
          AppColors.success,
        ),
        _buildStatCard(
          'Total Pesanan',
          '$bookings',
          Icons.shopping_bag_rounded,
          AppColors.primary,
        ),
        _buildStatCard(
          'Pesanan Aktif',
          '$active',
          Icons.pending_actions_rounded,
          AppColors.warning,
        ),
        _buildStatCard(
          'Jumlah Pengguna',
          '$users',
          Icons.people_alt_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.shopping_cart_checkout_rounded, size: 40, color: AppColors.textLight),
            SizedBox(height: 8),
            Text(
              'Belum ada pemesanan terbaru',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final type = booking.bookingType;
        final assetName = type == 'villa'
            ? (booking.villaName ?? 'Villa')
            : (booking.packageName ?? 'Paket Wisata');

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              assetName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Code: ${booking.bookingCode}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                Text(
                  'User: ${booking.userEmail ?? booking.userId}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildStatusChip(booking.bookingStatus, true),
                    const SizedBox(width: 8),
                    _buildStatusChip(booking.paymentStatus, false),
                  ],
                ),
              ],
            ),
            trailing: Text(
              _formatRupiah(booking.totalPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/booking_detail',
                arguments: booking,
              ).then((_) => _refreshStats());
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentPaymentsList(List<dynamic> payments) {
    if (payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.payment_rounded, size: 40, color: AppColors.textLight),
            SizedBox(height: 8),
            Text(
              'Belum ada pembayaran terbaru',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final payment = payments[index];
        final booking = payment['booking'] ?? {};
        final bookingCode = booking['booking_code'] ?? '-';
        final user = booking['user'] ?? {};
        final fullName = user['full_name'] ?? '-';
        final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
        final paymentMethod = payment['payment_method'] ?? 'N/A';
        final paidAtStr = payment['paid_at'] != null
            ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(payment['paid_at']))
            : '-';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.success.withOpacity(0.1),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            ),
            title: Text(
              bookingCode,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Oleh: $fullName',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                ),
                Text(
                  'Metode: $paymentMethod',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
                Text(
                  'Waktu: $paidAtStr',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
            trailing: Text(
              _formatRupiah(amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
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
}
