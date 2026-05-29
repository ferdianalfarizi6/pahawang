import 'package:flutter/material.dart';

class Benefit {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  Benefit({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

List<Benefit> benefits = [
  Benefit(
    id: '1',
    title: 'Pemandangan Alam Menakjubkan',
    description: 'Nikmati keindahan pantai pasir putih, air laut jernih, dan panorama sunset yang memukau.',
    icon: Icons.landscape_rounded,
    color: const Color(0xFF00B4D8),
  ),
  Benefit(
    id: '2',
    title: 'Wisata Bahari Lengkap',
    description: 'Snorkeling, diving, island hopping, dan memancing dengan fasilitas lengkap dan guide profesional.',
    icon: Icons.scuba_diving,
    color: const Color(0xFF0077B6),
  ),
  Benefit(
    id: '3',
    title: 'Kuliner Khas Lampung',
    description: 'Cicipi seafood segar dan masakan khas Lampung yang autentik langsung dari nelayan lokal.',
    icon: Icons.restaurant_rounded,
    color: const Color(0xFFFF6B35),
  ),
  Benefit(
    id: '4',
    title: 'Budaya & Tradisi Lokal',
    description: 'Rasakan keramahan warga dan pelajari tradisi unik masyarakat pesisir Pulau Pahawang.',
    icon: Icons.diversity_3_rounded,
    color: const Color(0xFF9B59B6),
  ),
  Benefit(
    id: '5',
    title: 'Harga Terjangkau',
    description: 'Paket wisata dengan harga bersahabat tanpa mengurangi kualitas pengalaman wisata Anda.',
    icon: Icons.savings_rounded,
    color: const Color(0xFF2ECC71),
  ),
  Benefit(
    id: '6',
    title: 'Akomodasi Nyaman',
    description: 'Tersedia homestay, cottage, dan area camping yang nyaman dengan fasilitas memadai.',
    icon: Icons.hotel_rounded,
    color: const Color(0xFFE74C3C),
  ),
  Benefit(
    id: '7',
    title: 'Spot Foto Instagramable',
    description: 'Banyak spot foto menarik untuk mengabadikan momen liburan Anda di media sosial.',
    icon: Icons.camera_alt_rounded,
    color: const Color(0xFFF39C12),
  ),
  Benefit(
    id: '8',
    title: 'Ramah Keluarga',
    description: 'Destinasi yang cocok untuk liburan keluarga dengan area bermain anak yang aman.',
    icon: Icons.family_restroom_rounded,
    color: const Color(0xFF1ABC9C),
  ),
];