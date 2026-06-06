import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../widgets/premium_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;
  String? _error;

  String _passwordStrength = '';
  Color _strengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      _onPasswordChanged(_passwordController.text);
    });
  }

  void _onPasswordChanged(String pass) {
    if (pass.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthColor = Colors.transparent;
      });
      return;
    }
    if (pass.length < 6) {
      setState(() {
        _passwordStrength = 'Lemah';
        _strengthColor = AppColors.danger;
      });
    } else if (pass.length < 8 || !RegExp(r'[0-9]').hasMatch(pass)) {
      setState(() {
        _passwordStrength = 'Sedang';
        _strengthColor = AppColors.warning;
      });
    } else {
      setState(() {
        _passwordStrength = 'Kuat';
        _strengthColor = AppColors.success;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(() => _error = 'Anda harus menyetujui Syarat & Ketentuan.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    String rawPhone = _phoneController.text.trim();
    if (rawPhone.startsWith('0')) {
      rawPhone = '62${rawPhone.substring(1)}';
    }
    _phoneController.text = rawPhone;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      rawPhone,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/email_verification',
          arguments: {
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
            'phone': rawPhone,
            'password': _passwordController.text,
          },
        );
      }
    } else {
      setState(() => _error = authProvider.error ?? 'Gagal mendaftar. Silakan coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Upper Curved Block
            Stack(
              children: [
                Container(
                  height: 240,
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () => Navigator.maybePop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Buat Akun Baru',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Daftar untuk menikmati wisata Pulau Pahawang',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -50,
                  right: -50,
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.white.withOpacity(0.04),
                  ),
                ),
              ],
            ),

            // Form Block
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cardDecoration,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error banner
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: AppColors.danger,
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

                        // Name field
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Nama lengkap wajib diisi';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.grey.shade400, size: 20),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Alamat Email',
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade400, size: 20),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Phone field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Nomor WhatsApp wajib diisi';
                            String trimmed = value.trim();
                            if (trimmed.startsWith('0')) {
                              trimmed = '62${trimmed.substring(1)}';
                            }
                            if (!trimmed.startsWith('62')) return 'Gunakan format 62xxx atau 08xxx';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Nomor WhatsApp (628xxx)',
                            prefixIcon: Icon(Icons.phone_android_rounded, color: Colors.grey.shade400, size: 20),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password wajib diisi';
                            if (value.length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Kata Sandi',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        
                        // Live password strength indicator
                        if (_passwordStrength.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _passwordStrength == 'Lemah' ? 0.3 : (_passwordStrength == 'Sedang' ? 0.6 : 1.0),
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                                    minHeight: 5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _passwordStrength,
                                style: TextStyle(color: _strengthColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Confirm Password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
                            if (value != _passwordController.text) return 'Password tidak sama';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Konfirmasi Sandi',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Terms agreement checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                activeColor: AppColors.primary,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                onChanged: (val) {
                                  setState(() {
                                    _agreeToTerms = val ?? false;
                                    if (_agreeToTerms) _error = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Saya menyetujui Syarat & Ketentuan Desa Wisata',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        PremiumButton(
                          text: 'Daftar',
                          isLoading: _isLoading,
                          onPressed: _handleRegister,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom redirect link
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: AppColors.primary,
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
