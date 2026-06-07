import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/modern_card.dart';
import '../utils/constants.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Lokasi Kami',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '📍',
                              style: TextStyle(fontSize: 60),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pulau Pahawang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Static Map
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Real static map via OpenStreetMap – no API key, works on web & mobile
                      Image.network(
                        'https://staticmap.openstreetmap.de/staticmap.php'
                        '?center=${AppConstants.latitude},${AppConstants.longitude}'
                        '&zoom=12&size=800x400'
                        '&markers=${AppConstants.latitude},${AppConstants.longitude},red',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: theme.colorScheme.primary.withOpacity(0.06),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_rounded, size: 54,
                                  color: theme.colorScheme.primary.withOpacity(0.4)),
                              const SizedBox(height: 10),
                              Text(
                                'Peta tidak tersedia\n(periksa koneksi internet)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Gradient overlay at bottom
                      Positioned(
                        left: 0, right: 0, bottom: 0, height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Location label
                      Positioned(
                        left: 14, bottom: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_pin,
                                  color: Colors.red, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Pulau Pahawang, Lampung',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Open Maps button
                      Positioned(
                        right: 14, bottom: 14,
                        child: ElevatedButton.icon(
                          onPressed: _openMaps,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9,
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.directions_rounded, size: 16),
                          label: const Text(
                            'Buka di Maps',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Address Card
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
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Alamat Lengkap', style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppConstants.address,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildContactRow(
                        Icons.phone_rounded,
                        'Telepon',
                        AppConstants.phone,
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildContactRow(
                        Icons.email_rounded,
                        'Email',
                        AppConstants.email,
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildContactRow(
                        Icons.web_rounded,
                        'Website',
                        AppConstants.website,
                        theme,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // How to Get There
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Cara Menuju Lokasi', style: theme.textTheme.headlineMedium),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildTransportCard(
                      '🚗',
                      'Dari Bandar Lampung',
                      'Naik kendaraan ke Dermaga Ketapang (±1 jam)',
                      '± 1 jam perjalanan',
                      theme.colorScheme.primary,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildTransportCard(
                      '⛴️',
                      'Dari Dermaga Ketapang',
                      'Naik perahu ke Pulau Pahawang (±30 menit)',
                      '± 30 menit penyeberangan',
                      theme.colorScheme.secondary,
                      theme,
                    ),
                    const SizedBox(height: 12),
                    _buildTransportCard(
                      '🚤',
                      'Speedboat Charter',
                      'Sewa speedboat langsung ke pulau',
                      '± 15 menit perjalanan',
                      theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399),
                      theme,
                    ),
                  ],
                ),
              ),
            ),

            // Coordinates
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🌐 Koordinat GPS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCoordItem(
                            'Latitude',
                            AppConstants.latitude.toString(),
                          ),
                          const SizedBox(width: 20),
                          _buildCoordItem(
                            'Longitude',
                            AppConstants.longitude.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (ctx) => OutlinedButton.icon(
                          onPressed: () => _copyCoordinates(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Salin Koordinat'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildTransportCard(
    String emoji,
    String title,
    String desc,
    String duration,
    Color color,
    ThemeData theme,
  ) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc,
                    style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                        color: color, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildCoordItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace')),
      ],
    );
  }

  Future<void> _openMaps() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${AppConstants.latitude},${AppConstants.longitude}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _copyCoordinates(BuildContext context) {
    final theme = Theme.of(context);
    final text =
        '${AppConstants.latitude}, ${AppConstants.longitude}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Koordinat disalin: $text',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: theme.brightness == Brightness.light ? const Color(0xFF059669) : const Color(0xFF34D399),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}