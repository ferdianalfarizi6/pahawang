import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models/booking_model.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/location_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/operational_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/booking_form_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/edit_booking_screen.dart';
import 'screens/payment_success_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/manage_villas_screen.dart';
import 'screens/booking_management_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/villas_provider.dart';
import 'providers/packages_provider.dart';
import 'providers/bookings_provider.dart';
import 'providers/admin_provider.dart';
import 'theme/app_theme.dart';
import 'core/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dynamic API base URL resolution
  await AppConfig.resolveBaseUrl();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');
  } catch (e, stack) {
    debugPrint('❌ Firebase initialization error: $e');
    debugPrintStack(stackTrace: stack);
  }

  // Set portrait upward orientation for mobile app layout consistency
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VillasProvider()),
        ChangeNotifierProvider(create: (_) => PackagesProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const PulauPahawangApp(),
    ),
  );
}

class PulauPahawangApp extends StatelessWidget {
  const PulauPahawangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desa Wisata Pulau Pahawang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/': (_) => const AuthGate(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/email_verification': (_) => const EmailVerificationScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot_password': (_) => const ForgotPasswordScreen(),
        '/admin_login': (_) => const AdminLoginScreen(),
        '/admin_dashboard': (_) => const AdminDashboardScreen(),
        '/booking_form': (_) => const BookingFormScreen(),
        '/booking_history': (_) => const BookingHistoryScreen(),
        '/booking_detail': (context) => BookingDetailScreen(booking: ModalRoute.of(context)!.settings.arguments as Booking),
        '/edit_booking': (context) => EditBookingScreen(booking: ModalRoute.of(context)!.settings.arguments as Booking),
        '/payment_success': (_) => const PaymentSuccessScreen(),
        '/profile': (_) => const UserProfileScreen(),
        '/manage_villas': (_) => const ManageVillasScreen(),
        '/booking_management': (_) => const BookingManagementScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      );
    }

    if (authProvider.isAuthenticated && authProvider.isAdmin) {
      return const AdminDashboardScreen();
    }

    // Both guest users and authenticated users proceed to main navigation.
    // Feature components check authProvider.isAuthenticated interactively.
    return const MainNavigation();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LocationScreen(),
    const TicketScreen(),
    const GalleryScreen(),
    const OperationalScreen(),
  ];

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Beranda'),
              _buildNavItem(1, Icons.location_on_rounded, 'Lokasi'),
              _buildNavItem(2, Icons.confirmation_number_rounded, 'Tiket'),
              _buildNavItem(3, Icons.photo_library_rounded, 'Galeri'),
              _buildNavItem(4, Icons.access_time_rounded, 'Jam Buka'),
            ],
          ),
        ),
      ),
    );
  }
}