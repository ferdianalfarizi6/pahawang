import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/modern_card.dart';
import '../utils/constants.dart';
import '../models/destination_model.dart';
import '../models/benefit_model.dart';
import '../providers/villas_provider.dart';
import '../providers/packages_provider.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_feedback.dart';
import '../widgets/buttons/icon_button.dart';
import 'detail_screen.dart';
import 'benefit_screen.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentBannerIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _banners = [
    {
      'title': 'Selamat Datang di\nPulau Pahawang',
      'subtitle': 'Surga Tersembunyi di Lampung',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    },
    {
      'title': 'Jelajahi Keindahan\nBawah Laut',
      'subtitle': 'Snorkeling & Diving Terbaik',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
    },
    {
      'title': 'Rasakan Pengalaman\nTak Terlupakan',
      'subtitle': 'Wisata Bahari Premium',
      'image': 'https://images.unsplash.com/photo-1507400492013-162706c8c05e?w=800',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    // Trigger dynamic fetch on load for Villa & Tour packages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VillasProvider>(context, listen: false).fetchVillas();
      Provider.of<PackagesProvider>(context, listen: false).fetchPackages();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _startBannerAutoSlide();
    });
  }

  void _startBannerAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        _startBannerAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isLoggedIn = authProvider.isAuthenticated;
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Premium App Bar
            SliverAppBar(
              expandedHeight: 70,
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.waves_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLoggedIn
                                      ? 'Halo, ${user?.fullName?.split(' ').first ?? 'Tamu'}! 🌊'
                                      : 'Pulau Pahawang',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  isLoggedIn ? 'Siap menjelajah hari ini?' : 'Desa Wisata Premium',
                                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        AppIconButton(
                          icon: Icons.search_rounded,
                          onPressed: () => _showSearchDialog(),
                        ),
                        if (isLoggedIn) ...[
                          const SizedBox(width: 8),
                          AppIconButton(
                            icon: Icons.receipt_long_rounded,
                            onPressed: () => Navigator.pushNamed(context, '/booking_history'),
                          ),
                        ],
                        const SizedBox(width: 8),
                        AppIconButton(
                          icon: isLoggedIn ? Icons.person_rounded : Icons.login_rounded,
                          onPressed: () {
                            if (isLoggedIn) {
                              Navigator.pushNamed(context, '/profile');
                            } else {
                              Navigator.pushNamed(context, '/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Hero Banner Slider
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentBannerIndex = index);
                          },
                          itemCount: _banners.length,
                          itemBuilder: (context, index) {
                            return _buildBannerCard(_banners[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_banners.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentBannerIndex == index ? 24 : 8,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (isLoggedIn)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppTheme.shadowMd,
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pesanan Saya',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pantau status tiket dan reservasi aktif Anda',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/booking_history'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Lihat',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Elegant Quick Search Trigger Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: GestureDetector(
                  onTap: _showSearchDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.shadowMd,
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mau liburan ke mana?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Cari akomodasi villa atau paket wisata snorkeling...',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Quick Stats Metric Dashboard style
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat('⭐', '4.9', 'Peringkat', theme),
                      _buildQuickStat('👥', '12K+', 'Pengunjung', theme),
                      _buildQuickStat('📸', '80+', 'Spot Foto', theme),
                      _buildQuickStat('🏆', '#1', 'Destinasi', theme),
                    ],
                  ),
                ),
              ),
            ),

            // Section: Villa & Penginapan Carousel
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: '🏡 Penginapan Terpopuler',
                onViewAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: _buildVillaCarousel(),
            ),

            // Section: Paket Wisata Carousel
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: '🎒 Paket Wisata Seru',
                onViewAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: _buildPackageCarousel(),
            ),

            // Section: Destinasi Populer
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: '✨ Destinasi Pilihan',
                onViewAll: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: _buildDestinationsGrid(),
            ),

            // Section: Info Destinasi
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Tentang Pulau Pahawang', style: theme.textTheme.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ModernCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Informasi Pulau',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppConstants.islandDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip('🏖️ Pantai Pasir Putih', theme.colorScheme.primary.withOpacity(0.7)),
                          _buildChip('🤿 Snorkeling Spot', theme.colorScheme.primary),
                          _buildChip('🌅 Sunset View', theme.colorScheme.secondary),
                          _buildChip('🐠 Clownfish Breeding', theme.colorScheme.primary),
                          _buildChip('⛺ Glamping', theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section: Benefit
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: 'Keunggulan Wisata Kami',
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BenefitScreen(),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _buildBenefitsGrid(),
            ),

            // CTA Booking Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.sunsetGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('🏝️', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text(
                        'Rencanakan Liburan Anda!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dapatkan pengalaman liburan tropical yang tak terlupakan dengan memesan villa atau paket snorkeling sekarang.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {
                          // Trigger default tab switch to booking if necessary, or open tickets
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🏝️ Desa Wisata Pulau Pahawang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppConstants.address,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(Icons.facebook_rounded),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.camera_alt_rounded),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.video_library_rounded),
                        const SizedBox(width: 12),
                        _buildSocialIcon(Icons.web_rounded),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '© 2026 Desa Wisata Pulau Pahawang. All Rights Reserved.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF00897B), size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required VoidCallback onViewAll}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'Lihat Semua',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVillaCarousel() {
    return Consumer<VillasProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.villas.isEmpty) {
          return SizedBox(
            height: 385,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 2,
              itemBuilder: (context, index) => const SizedBox(
                width: 280,
                child: PremiumCardSkeleton(),
              ),
            ),
          );
        }
        if (provider.villas.isEmpty) {
          return const SizedBox();
        }
        return SizedBox(
          height: 385,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: provider.villas.length,
            itemBuilder: (context, index) {
              final villa = provider.villas[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: PremiumVillaCard(
                  villa: villa,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(villa: villa)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPackageCarousel() {
    return Consumer<PackagesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.packages.isEmpty) {
          return SizedBox(
            height: 385,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 2,
              itemBuilder: (context, index) => const SizedBox(
                width: 280,
                child: PremiumCardSkeleton(),
              ),
            ),
          );
        }
        if (provider.packages.isEmpty) {
          return const SizedBox();
        }
        return SizedBox(
          height: 385,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: provider.packages.length,
            itemBuilder: (context, index) {
              final package = provider.packages[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: PremiumPackageCard(
                  package: package,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(package: package)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDestinationsGrid() {
    final theme = Theme.of(context);
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final dest = destinations[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(destination: dest),
                ),
              );
            },
            child: Container(
              width: 170,
              margin: EdgeInsets.only(
                right: index < destinations.length - 1 ? 14 : 0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.shadowMd,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            dest.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: theme.colorScheme.surfaceVariant),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    dest.rating.toString(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dest.name,
                            style: theme.textTheme.titleSmall?.copyWith(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dest.description,
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitsGrid() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          final benefit = benefits[index];
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.shadowMd,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: benefit.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    benefit.icon,
                    color: benefit.color,
                    size: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      benefit.description,
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerCard(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              data['image']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade100),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    data['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['subtitle']!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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

  Widget _buildQuickStat(String emoji, String value, String label, ThemeData theme) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  void _showSearchDialog() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Cari Destinasi', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Ketik nama destinasi...',
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Pencarian Populer', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Snorkeling',
                'Pantai',
                'Diving',
                'Camping',
                'Sunset',
                'Mancing',
              ]
                  .map((e) => ActionChip(
                        label: Text(e, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.06),
                        onPressed: () {},
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}