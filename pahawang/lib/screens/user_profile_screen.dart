import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/premium_card.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (!auth.isAuthenticated) {
            return _buildGuestView(context);
          }

          final user = auth.user!;
          final initials = user.fullName != null && user.fullName!.isNotEmpty
              ? user.fullName!.split(' ').map((x) => x[0]).take(2).join().toUpperCase()
              : 'G';

          // Profile Completeness logic
          final hasWa = user.phone != null && user.phone!.isNotEmpty;
          final completenessProgress = hasWa ? 1.0 : 0.7;
          final completenessPercent = hasWa ? '100%' : '70%';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Frame with Gradient Rim
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: AppColors.primaryGradient),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 51,
                            backgroundColor: AppColors.primary.withOpacity(0.08),
                            backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                                ? NetworkImage(user.avatar!)
                                : null,
                            child: user.avatar == null || user.avatar!.isEmpty
                                ? Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                
                // Name & Role Badge
                Text(
                  user.fullName ?? 'Tamu Pahawang',
                  style: AppTheme.heading1.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (auth.isAdmin ? AppColors.accent : AppColors.primary).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: (auth.isAdmin ? AppColors.accent : AppColors.primary).withOpacity(0.2)),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: auth.isAdmin ? AppColors.accent : AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Completeness Indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kelengkapan Profil',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark),
                          ),
                          Text(
                            completenessPercent,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: completenessProgress,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                      if (!hasWa) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Lengkapi nomor WhatsApp Anda agar mudah dihubungi pemandu.',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Profile Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    children: [
                      _buildProfileItem(Icons.email_outlined, 'Alamat Email', user.email),
                      const Divider(height: 24, color: Color(0xFFF1F3F5)),
                      _buildProfileItem(Icons.phone_android_rounded, 'Nomor WhatsApp', user.phone ?? 'Belum diisi'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Navigation list card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.receipt_long_rounded,
                        title: 'Riwayat Pemesanan',
                        onTap: () => Navigator.of(context).pushNamed('/booking_history'),
                      ),
                      if (auth.isAdmin) ...[
                        const Divider(height: 1, color: Color(0xFFF1F3F5)),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.dashboard_customize_rounded,
                          title: 'Admin Dashboard',
                          onTap: () => Navigator.of(context).pushReplacementNamed('/admin_dashboard'),
                        ),
                      ],
                      const Divider(height: 1, color: Color(0xFFF1F3F5)),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.lock_reset_rounded,
                        title: 'Lupa Password',
                        onTap: () => Navigator.of(context).pushNamed('/forgot_password'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Logout button using custom PremiumButton style with accent/secondary colors
                PremiumButton(
                  text: 'Keluar Akun',
                  icon: Icons.logout_rounded,
                  isSecondary: true,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text(
                          'Keluar Akun',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                        ),
                        content: const Text(
                          'Apakah Anda yakin ingin keluar dari akun Anda?',
                          style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              if (context.mounted) {
                                // Navigate first so widget is gone from tree before
                                // notifyListeners() fires inside logout().
                                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                              }
                              auth.logout(); // intentionally not awaited
                            },
                            child: const Text(
                              'Keluar',
                              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: AppTheme.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌴', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 18),
              const Text(
                'Selamat Datang Tamu!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan masuk atau daftar terlebih dahulu untuk mengakses riwayat booking dan detail profil Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              PremiumButton(
                text: 'Masuk ke Akun',
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }
}
