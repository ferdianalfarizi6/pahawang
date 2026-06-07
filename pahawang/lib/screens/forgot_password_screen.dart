import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/inputs/modern_text_field.dart';
import '../widgets/cards/modern_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success =
        await authProvider.sendPasswordReset(_emailController.text.trim());

    if (mounted) setState(() => _isLoading = false);

    if (success) {
      setState(() => _emailSent = true);
      _animController.reset();
      _animController.forward();
    } else {
      if (mounted) {
        _showErrorSnackbar(authProvider.error ?? 'Gagal mengirim email reset');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── Gradient Header ────────────────────────────────────────
            Stack(
              children: [
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                            onPressed: () => Navigator.maybePop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const Spacer(),

                          // Icon in circle
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Icon(
                              _emailSent
                                  ? Icons.mark_email_read_rounded
                                  : Icons.lock_reset_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _emailSent ? 'Email Terkirim! 🎉' : 'Lupa Password?',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _emailSent
                                ? 'Cek inbox email Anda untuk link reset'
                                : 'Tenang, kami bantu pulihkan akun Anda',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                // Decorative circle overlay
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

            // ─── Content Card ────────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: _emailSent
                        ? _buildSuccessCard(theme)
                        : _buildFormCard(theme),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Success State ──────────────────────────────────────────────────────────
  Widget _buildSuccessCard(ThemeData theme) {
    return ModernCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          // Animated success illustration
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? const Color(0xFF059669).withOpacity(0.1)
                  : const Color(0xFF34D399).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: theme.brightness == Brightness.light
                  ? const Color(0xFF059669)
                  : const Color(0xFF34D399),
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cek Email Anda',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined,
                    color: theme.colorScheme.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  _emailController.text.trim(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kami telah mengirim link reset password ke email di atas. Periksa folder spam jika tidak menemukan emailnya.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // Back to login button
          PrimaryButton(
            text: 'Kembali ke Login',
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/login'),
            isFullWidth: true,
          ),
          const SizedBox(height: 14),

          // Try another email
          GestureDetector(
            onTap: () {
              setState(() => _emailSent = false);
              _emailController.clear();
              _animController.reset();
              _animController.forward();
            },
            child: Text(
              'Coba email lain?',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Form State ─────────────────────────────────────────────────────────────
  Widget _buildFormCard(ThemeData theme) {
    return ModernCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info hint
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light
                    ? const Color(0xFF0284C7).withOpacity(0.06)
                    : const Color(0xFF0C4A6E).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.brightness == Brightness.light
                      ? const Color(0xFF0284C7).withOpacity(0.15)
                      : const Color(0xFF0C4A6E).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: theme.brightness == Brightness.light
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF38BDF8),
                      size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Link reset password akan dikirim ke email yang terdaftar di akun Anda.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.brightness == Brightness.light
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Email field
            ModernTextField(
              label: 'Alamat Email',
              hint: 'contoh@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value.trim())) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Submit button
            PrimaryButton(
              text: 'Kirim Link Reset',
              isLoading: _isLoading,
              onPressed: _resetPassword,
              isFullWidth: true,
            ),
            const SizedBox(height: 18),

            // Back to login link
            Center(
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Ingat password? ',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: 'Masuk Sekarang',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
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
}
