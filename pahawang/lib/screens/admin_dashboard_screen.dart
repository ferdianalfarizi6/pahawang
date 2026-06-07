import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../models/booking_model.dart';
import '../widgets/premium_card.dart';

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
    final theme = Theme.of(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Apakah Anda yakin ingin keluar dari akun Admin?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                // Navigate away first so this widget is fully removed from the tree
                // BEFORE authProvider.logout() calls notifyListeners(), preventing
                // the '_dependents.isEmpty' assertion error.
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
                authProvider.logout(); // intentionally not awaited
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        color: theme.colorScheme.primary,
        child: adminProvider.isLoading && adminProvider.stats.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
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
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          PremiumButton(
                            text: 'Coba Lagi',
                            icon: Icons.refresh_rounded,
                            width: 160,
                            onPressed: _refreshStats,
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Banner
                        _buildWelcomeBanner(authProvider.user?.fullName ?? 'Administrator', theme),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quick Navigation Actions
                              const SizedBox(height: 12),
                              Text(
                                'Akses Cepat',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickNavCard(
                                      context,
                                      Icons.holiday_village_rounded,
                                      'Kelola Villa',
                                      'Akomodasi & Fasilitas',
                                      theme.colorScheme.primary,
                                      '/manage_villas',
                                      theme,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickNavCard(
                                      context,
                                      Icons.list_alt_rounded,
                                      'Pesanan',
                                      'Manajemen Booking',
                                      theme.colorScheme.secondary,
                                      '/booking_management',
                                      theme,
                                    ),
                                  ),
                                ],
                              ),

                              // Key Metrics Grid
                              const SizedBox(height: 24),
                              Text(
                                'Statistik Kunci',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 12),
                              _buildStatsGrid(adminProvider.stats, theme),

                              // Recent Bookings
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pemesanan Terbaru',
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/booking_management'),
                                    child: Text(
                                      'Lihat Semua',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildRecentBookingsList(adminProvider.recentBookings, theme),

                              // Recent Payments
                              const SizedBox(height: 24),
                              Text(
                                'Pembayaran Terbaru',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 12),
                              _buildRecentPaymentsList(adminProvider.recentPayments, theme),
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

  Widget _buildWelcomeBanner(String adminName, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.18),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                backgroundColor: Colors.white.withOpacity(0.18),
                child: const Icon(Icons.admin_panel_settings_rounded, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      adminName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
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
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
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
    ThemeData theme,
  ) {
    return Container(
      height: 125,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.08),
                  child: Icon(icon, color: color, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
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

  Widget _buildStatsGrid(Map<String, dynamic> stats, ThemeData theme) {
    final revenue = stats['totalRevenue'] ?? 0;
    final bookings = stats['totalBookings'] ?? 0;
    final pending = stats['pendingBookings'] ?? 0;
    final paid = stats['paidBookings'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.35,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Pendapatan',
          _formatRupiah(revenue),
          Icons.monetization_on_rounded,
          theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399),
          theme,
        ),
        _buildStatCard(
          'Total Booking',
          '$bookings',
          Icons.shopping_bag_rounded,
          theme.colorScheme.primary,
          theme,
        ),
        _buildStatCard(
          'Pending Booking',
          '$pending',
          Icons.hourglass_empty_rounded,
          theme.brightness == Brightness.light ? const Color(0xFFD97706) : const Color(0xFFFBBF24),
          theme,
        ),
        _buildStatCard(
          'Paid Booking',
          '$paid',
          Icons.check_circle_outline_rounded,
          theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399),
          theme,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsList(List<Booking> bookings, ThemeData theme) {
    if (bookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.shopping_cart_checkout_rounded, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              'Belum ada pemesanan terbaru',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final type = booking.bookingType;
        final assetName = type == 'villa'
            ? (booking.villaName ?? 'Villa')
            : (booking.packageName ?? 'Paket Wisata');

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            title: Text(
              assetName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Code: ${booking.bookingCode}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
                Text(
                  'User: ${booking.userEmail ?? booking.userId}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(booking.bookingStatus, true, theme),
                    const SizedBox(width: 8),
                    _buildStatusChip(booking.paymentStatus, false, theme),
                  ],
                ),
              ],
            ),
            trailing: Text(
              _formatRupiah(booking.totalPrice),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: type == 'villa' ? theme.colorScheme.primary : theme.colorScheme.secondary,
                fontSize: 13,
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

  Widget _buildRecentPaymentsList(List<dynamic> payments, ThemeData theme) {
    if (payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.payment_rounded, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              'Belum ada pembayaran terbaru',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399)).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399), size: 22),
            ),
            title: Text(
              bookingCode,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Oleh: $fullName',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Metode: $paymentMethod  |  $paidAtStr',
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            trailing: Text(
              _formatRupiah(amount),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399),
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status, bool isBooking, ThemeData theme) {
    Color color;
    String label = status.toUpperCase();

    if (isBooking) {
      switch (status.toLowerCase()) {
        case 'waiting':
          color = theme.brightness == Brightness.light ? const Color(0xFFD97706) : const Color(0xFFFBBF24);
          label = 'Menunggu';
          break;
        case 'confirmed':
          color = theme.colorScheme.primary;
          label = 'Dikonfirmasi';
          break;
        case 'completed':
          color = theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399);
          label = 'Selesai';
          break;
        case 'cancelled':
          color = Colors.redAccent;
          label = 'Dibatalkan';
          break;
        default:
          color = theme.colorScheme.onSurfaceVariant;
      }
    } else {
      switch (status.toLowerCase()) {
        case 'unpaid':
          color = Colors.redAccent;
          label = 'Belum Bayar';
          break;
        case 'paid':
          color = theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399);
          label = 'Lunas';
          break;
        case 'refunded':
          color = Colors.blueGrey;
          label = 'Refund';
          break;
        default:
          color = theme.colorScheme.onSurfaceVariant;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
