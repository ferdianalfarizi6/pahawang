import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/villa_model.dart';
import '../models/package_model.dart';
import '../providers/villas_provider.dart';
import '../providers/packages_provider.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_feedback.dart';
import 'detail_screen.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialise dynamic loading from NestJS API on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VillasProvider>(context, listen: false).fetchVillas();
      Provider.of<PackagesProvider>(context, listen: false).fetchPackages();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final term = _searchController.text.trim();
    if (_tabController.index == 0) {
      Provider.of<VillasProvider>(context, listen: false).fetchVillas(search: term);
    } else {
      Provider.of<PackagesProvider>(context, listen: false).fetchPackages(search: term);
    }
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Tropical Blue Gradient Banner
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jelajahi Pahawang 🏝️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pesan akomodasi & paket snorkeling favorit Anda secara real-time',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  
                  // Live Search Field
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama atau lokasi...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar switcher
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                onTap: (index) {
                  _searchController.clear(); // Clear search on tab switch
                },
                tabs: const [
                  Tab(text: '🏡 Penginapan (Villa)'),
                  Tab(text: '🎒 Paket Wisata'),
                ],
              ),
            ),

            // Tabs Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVillasTab(),
                  _buildPackagesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. VILLAS DYNAMIC LIST TAB
  Widget _buildVillasTab() {
    return Consumer<VillasProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.villas.isEmpty) {
          return _buildSkeletonLoading();
        }

        if (provider.error != null && provider.villas.isEmpty) {
          return _buildErrorState(provider.error!, () => provider.fetchVillas());
        }

        if (provider.villas.isEmpty) {
          return _buildEmptyState('Tidak ada villa ditemukan.');
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchVillas(search: _searchController.text),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: provider.villas.length,
            itemBuilder: (context, index) {
              final villa = provider.villas[index];
              return _buildVillaCard(villa);
            },
          ),
        );
      },
    );
  }

  // 2. PACKAGES DYNAMIC LIST TAB
  Widget _buildPackagesTab() {
    return Consumer<PackagesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.packages.isEmpty) {
          return _buildSkeletonLoading();
        }

        if (provider.error != null && provider.packages.isEmpty) {
          return _buildErrorState(provider.error!, () => provider.fetchPackages());
        }

        if (provider.packages.isEmpty) {
          return _buildEmptyState('Tidak ada paket wisata ditemukan.');
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchPackages(search: _searchController.text),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: provider.packages.length,
            itemBuilder: (context, index) {
              final package = provider.packages[index];
              return _buildPackageCard(package);
            },
          ),
        );
      },
    );
  }

  // VILLA CARD BUILDER
  // VILLA CARD BUILDER
  Widget _buildVillaCard(Villa villa) {
    return PremiumVillaCard(
      villa: villa,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(villa: villa)),
        );
      },
    );
  }

  // TOUR PACKAGE CARD BUILDER
  Widget _buildPackageCard(TourPackage package) {
    return PremiumPackageCard(
      package: package,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(package: package)),
        );
      },
    );
  }

  // SKELETON LOADER WIDGET
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => const PremiumCardSkeleton(),
    );
  }

  // EMPTY WIDGET
  Widget _buildEmptyState(String text) {
    return PremiumEmptyState(
      title: 'Tidak Ada Hasil',
      description: text,
      emoji: '🏖️',
    );
  }

  // ERROR WIDGET
  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            PremiumButton(
              text: 'Coba Lagi',
              icon: Icons.refresh_rounded,
              width: 150,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}