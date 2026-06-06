import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../widgets/premium_card.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false;
  bool _isResending = false;
  int _secondsRemaining = 0;
  Timer? _resendTimer;
  Timer? _pollTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Pulse animation for email icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-poll email verification status every 5 seconds
    _startPolling();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resendTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isChecking) return;
      await _authService.reloadUser();
      if (_authService.isEmailVerified && mounted) {
        _pollTimer?.cancel();
        _checkVerification();
      }
    });
  }

  void _startResendCooldown() {
    setState(() => _secondsRemaining = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkVerification() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final name = args?['name'] ?? '';
      final phone = args?['phone'] ?? '';
      final email = args?['email'] ?? '';
      final password = args?['password'] ?? '';

      // Reload user to check verification status
      await _authService.reloadUser();
      
      if (!_authService.isEmailVerified) {
        if (mounted) setState(() => _isChecking = false);
        _showSnackbar(
          message: 'Email belum diverifikasi. Silakan cek inbox/spam Anda.',
          isError: true,
        );
        return;
      }

      _pollTimer?.cancel();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bool success;

      if (phone.isNotEmpty) {
        // Registration Flow: Sync user details to server database
        success = await authProvider.finalizeRegistration(phone);
      } else {
        // Login Flow: Directly login after verification
        success = await authProvider.loginAfterVerification();
      }

      if (mounted) setState(() => _isChecking = false);

      if (success) {
        if (mounted) {
          _showSuccessDialog(authProvider.isAdmin);
        }
      } else {
        if (mounted) {
          final errorMsg = authProvider.error ??
              (phone.isNotEmpty ? 'Registrasi gagal. Silakan coba lagi.' : 'Gagal masuk setelah verifikasi.');
          _showSnackbar(
            message: errorMsg,
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        _showSnackbar(
          message: e.toString(),
          isError: true,
        );
      }
    }
  }

  Future<void> _resendEmail() async {
    if (_secondsRemaining > 0) return;
    setState(() => _isResending = true);
    try {
      await _authService.resendVerificationEmail();
      _startResendCooldown();
      _showSnackbar(
        message: 'Email verifikasi telah dikirim ulang!',
        isError: false,
      );
    } catch (e) {
      _showSnackbar(
        message: 'Gagal mengirim email. Coba lagi nanti.',
        isError: true,
      );
    }
    if (mounted) setState(() => _isResending = false);
  }

  void _navigateToDashboard(bool isAdmin) {
    if (isAdmin) {
      Navigator.of(context).pushNamedAndRemoveUntil('/admin_dashboard', (r) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    }
  }

  void _showSuccessDialog(bool isAdmin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Verifikasi Berhasil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          isAdmin
              ? 'Akun Admin Anda telah terverifikasi!\n\nAnda akan dialihkan ke Dashboard Admin.'
              : 'Akun Anda telah terverifikasi!\n\nSelamat menjelajah keindahan Pulau Pahawang 🏝️',
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToDashboard(isAdmin);
            },
            child: const Text(
              'Lanjutkan',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    // Auto navigate after 2.5 seconds for a smooth transition if they don't press "Lanjutkan"
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close dialog
        _navigateToDashboard(isAdmin);
      }
    });
  }

  void _showSnackbar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── Gradient Header ──────────────────────────────────────────
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Animated email icon
                          const Spacer(),
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Verifikasi Email',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Satu langkah lagi menuju Pahawang 🌊',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.75),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -60,
                  right: -60,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white.withOpacity(0.05),
                  ),
                ),
              ],
            ),

            // ─── Content Card ───────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Steps indicator
                      _buildStepsIndicator(),
                      const SizedBox(height: 24),

                      // Email badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.email_outlined,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              email,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Kami telah mengirim email verifikasi ke alamat di atas. Klik link dalam email untuk mengaktifkan akun Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info tips
                      _buildTipCard(
                        icon: Icons.inbox_rounded,
                        text: 'Cek folder Inbox & Spam email Anda',
                      ),
                      const SizedBox(height: 10),
                      _buildTipCard(
                        icon: Icons.access_time_rounded,
                        text: 'Email mungkin membutuhkan 1-2 menit',
                      ),
                      const SizedBox(height: 28),

                      // Check verification button
                      PremiumButton(
                        text: 'Saya Sudah Verifikasi',
                        isLoading: _isChecking,
                        onPressed: _checkVerification,
                      ),
                      const SizedBox(height: 16),

                      // Resend email button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: (_secondsRemaining > 0 || _isResending)
                              ? null
                              : _resendEmail,
                          icon: _isResending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            _secondsRemaining > 0
                                ? 'Kirim Ulang (${_secondsRemaining}s)'
                                : 'Kirim Ulang Email',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Sign out
                      GestureDetector(
                        onTap: _signOut,
                        child: Text(
                          'Gunakan akun lain',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsIndicator() {
    return Row(
      children: [
        _buildStep(label: 'Daftar', isDone: true),
        _buildStepLine(isDone: true),
        _buildStep(label: 'Verifikasi', isDone: false, isActive: true),
        _buildStepLine(isDone: false),
        _buildStep(label: 'Selesai', isDone: false),
      ],
    );
  }

  Widget _buildStep(
      {required String label, required bool isDone, bool isActive = false}) {
    final color = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : Colors.grey.shade300;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.success
                : isActive
                    ? AppColors.primary
                    : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Icon(Icons.circle,
                    size: 8,
                    color: isActive ? Colors.white : Colors.grey.shade400),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isDone}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
        decoration: BoxDecoration(
          color: isDone ? AppColors.success : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTipCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
