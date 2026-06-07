import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/ghost_button.dart';
import '../widgets/inputs/modern_text_field.dart';
import '../widgets/cards/modern_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(email, password);

    if (success) {
      if (mounted) {
        if (authProvider.isAdmin) {
          Navigator.of(context).pushReplacementNamed('/admin_dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } else {
      if (mounted) {
        final err = authProvider.error ?? 'Login gagal. Silakan coba lagi.';
        if (err.contains('Email belum diverifikasi')) {
          Navigator.of(context).pushNamed(
            '/email_verification',
            arguments: {'email': email},
          );
          setState(() {
            _isLoading = false;
            _error = null;
          });
        } else {
          setState(() {
            _error = err;
            _isLoading = false;
          });
        }
      }
    }
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
            // Upper Curved Brand Header Block
            Stack(
              children: [
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // Brand Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(
                              Icons.waves_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Selamat Datang',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Masuk ke akun Desa Wisata Pulau Pahawang',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Soft background geometric overlays
                Positioned(
                  top: -50,
                  right: -50,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white.withOpacity(0.04),
                  ),
                ),
              ],
            ),

            // Form Block in Translucent Card
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ModernCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message banner
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Email Field
                        ModernTextField(
                          label: 'Alamat Email',
                          hint: 'nama@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        ModernTextField(
                          label: 'Kata Sandi',
                          hint: '••••••••',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          onSuffixIconPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password wajib diisi';
                            if (value.length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),

                        // Forgot password text link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/forgot_password'),
                            child: Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Login Action Button
                        PrimaryButton(
                          text: 'Masuk',
                          isLoading: _isLoading,
                          onPressed: _login,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 20),

                        // Elegant Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: theme.colorScheme.outline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'atau lanjutkan dengan',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: theme.colorScheme.outline)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Guest check-in button
                        GhostButton(
                          text: 'Lanjutkan sebagai Tamu',
                          icon: Icons.explore_outlined,
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Register Redirect link
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/register'),
                    child: Text(
                      'Daftar Sekarang',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
