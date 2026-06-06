import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../models/villa_model.dart';
import '../models/package_model.dart';
import '../models/destination_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/premium_card.dart';

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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Header Image & Controls
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${isDestination ? "Destinasi" : (isVilla ? "Villa" : "Paket")} ditambahkan ke Wishlist!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
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
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              transform: Matrix4.translationValues(0, -28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Location Header
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
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: AppTheme.caption.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (isDestination) ...[
                              const SizedBox(height: 8),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      destination!.category,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
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
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (isVilla ? AppColors.primary : AppColors.accent).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isVilla ? 'Per Malam' : 'Per Orang',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isVilla ? AppColors.primary : AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatPrice(price),
                                style: TextStyle(
                                  color: isVilla ? AppColors.primary : AppColors.accent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 36, color: Color(0xFFF1F3F5)),

                  // Description
                  Text('Deskripsi Lengkap', style: AppTheme.heading2),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: AppTheme.bodyText.copyWith(height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),

                  // Gallery Horizontal Preview
                  if (gallery.isNotEmpty) ...[
                    Text('Galeri Foto', style: AppTheme.heading2),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: gallery.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                gallery[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
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
                    Text('Fasilitas Lengkap', style: AppTheme.heading2),
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('📌 ', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                'Informasi Penting',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTip(isVilla
                              ? 'Waktu Check-In mulai pukul 14:00 WIB dan Check-Out maksimal 12:00 WIB.'
                              : 'Wajib tiba di Dermaga Ketapang 30 menit sebelum jadwal keberangkatan perahu.'),
                          _buildTip('Pemesanan hanya dijamin setelah pembayaran berhasil diverifikasi.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Checkout Action Button using custom PremiumButton
                    PremiumButton(
                      text: 'Pesan Sekarang',
                      icon: Icons.shopping_cart_checkout_rounded,
                      isSecondary: !isVilla,
                      onPressed: () {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        if (!auth.isAuthenticated) {
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

                        Navigator.pushNamed(
                          context,
                          '/booking_form',
                          arguments: {
                            'villa': villa,
                            'package': package,
                          },
                        );
                      },
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMedium),
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