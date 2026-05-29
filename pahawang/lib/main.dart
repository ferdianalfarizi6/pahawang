import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/booking_model.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/location_screen.dart';
import 'screens/ticket_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/operational_screen.dart';
import 'screens/benefit_screen.dart';
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
import 'services/auth_service.dart';
import 'utils/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');
  } catch (e, stack) {
    debugPrint('❌ Firebase initialization error: $e');
    debugPrintStack(stackTrace: stack);
  }
  runApp(const PulauPahawangApp());
}

class PulauPahawangApp extends StatelessWidget {
  const PulauPahawangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desa Wisata Pulau Pahawang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: {
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
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // If snapshot is still waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is not logged in, they can stay as guest or go to login
        // But for consistency with user request, we go to MainNavigation (Guest Mode enabled)
        // If they need to book, the buttons in screens will check AuthService().isLoggedIn
        return const MainNavigation();
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_rounded),
                label: 'Lokasi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_rounded),
                label: 'Tiket',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library_rounded),
                label: 'Galeri',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time_rounded),
                label: 'Jam Buka',
              ),
            ],
          ),
        ),
      ),
    );
  }
}