import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../models/villa_model.dart';
import '../models/package_model.dart';
import '../models/destination_model.dart';
import '../providers/auth_provider.dart';

class DetailScreen extends StatelessWidget {
  final Villa? villa;
  final TourPackage? package;
  final Destination? destination;

  const DetailScreen({super.key, this.villa, this.package, this.destination});

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final isVilla = villa != null;
    final isDestination = destination != null;
    final name = isDestination ? destination!.name : (isVilla ? villa!.name : package!.title);
    final location = isDestination ? 'Pulau Pahawang' : (isVilla ? villa!.location : package!.location);
    final description = isDestination ? destination!.description : (isVilla ? villa!.description : package!.description);
    final thumbnail = isDestination ? destination!.imageUrl : (isVilla ? villa!.thumbnail : package!.thumbnail);
    final gallery = isDestination ? <String>[] : (isVilla ? villa!.gallery : package!.gallery);
    final price = isDestination ? 0.0 : (isVilla ? villa!.pricePerNight : package!.price);
    final facilities = isDestination ? <String>[] : (isVilla ? villa!.facilities : package!.facilities);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Header Image & Controls
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ditambahkan ke Wishlist')),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite_border_rounded, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: isDestination
                        ? 'destination_${destination!.id}'
                        : (isVilla ? 'villa_${villa!.id}' : 'package_${package!.id}'),
                    child: Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primaryLight,
                          child: const Icon(Icons.image_not_supported_rounded, color: Colors.white, size: 50),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Detail Contents
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTheme.heading1.copyWith(fontSize: 22, height: 1.2),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: AppTheme.caption.copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (isDestination) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    destination!.rating.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      destination!.category,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isDestination) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isVilla ? 'Per Malam' : 'Per Orang',
                                style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatPrice(price),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text('Deskripsi Lengkap', style: AppTheme.heading3),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTheme.bodyText.copyWith(height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // Gallery Horizontal Preview
                  if (gallery.isNotEmpty) ...[
                    Text('Galeri Foto', style: AppTheme.heading3),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: gallery.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                gallery[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Facilities Wrap list
                  if (facilities.isNotEmpty) ...[
                    Text('Fasilitas Lengkap', style: AppTheme.heading3),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: facilities.map((f) => _buildFeatureChip(f)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (!isDestination) ...[
                    // Important Tips
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('📌 ', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 6),
                              Text('Informasi Penting', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildTip(isVilla
                              ? 'Waktu Check-In mulai pukul 14:00 WIB dan Check-Out maksimal 12:00 WIB.'
                              : 'Wajib tiba di Dermaga Ketapang 30 menit sebelum jadwal keberangkatan perahu.'),
                          _buildTip('Pemesanan hanya dijamin setelah pembayaran berhasil diverifikasi.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Checkout Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          if (!auth.isAuthenticated) {
                            // BUSINESS RULE: Guest cannot checkout without logging in
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan login terlebih dahulu untuk melakukan pemesanan.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            Navigator.pushNamed(context, '/login');
                            return;
                          }

                          // Navigate to dynamic booking checkout screen
                          Navigator.pushNamed(
                            context,
                            '/booking_form',
                            arguments: {
                              'villa': villa,
                              'package': package,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_checkout_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Pesan Sekarang',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMedium),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}