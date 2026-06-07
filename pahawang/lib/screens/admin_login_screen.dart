import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@gmail.com'); // Admin default email for convenience
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
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
          // If a regular user tries to login in admin panel, politely kick them back
          await authProvider.logout();
          setState(() {
            _error = 'Akses ditolak. Anda tidak memiliki otoritas Administrator.';
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _error = authProvider.error;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 80),
                    const SizedBox(height: 16),
                    const Text(
                      'Portal Administrator',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masuk untuk mengelola data Pulau Pahawang',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 36),

                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Email wajib diisi' : null,
                      decoration: InputDecoration(
                        hintText: 'Email Admin',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.admin_panel_settings, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => value == null || value.isEmpty ? 'Password wajib diisi' : null,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                            : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                      child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
