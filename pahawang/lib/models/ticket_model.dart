import 'package:flutter/material.dart';

class TicketPackage {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> includes;
  final String icon;
  final bool isPopular;
  final Color color;

  TicketPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.includes,
    required this.icon,
    this.isPopular = false,
    required this.color,
  });
}

List<TicketPackage> ticketPackages = [
  TicketPackage(
    id: '1',
    name: 'Tiket Masuk',
    description: 'Tiket masuk dasar ke Pulau Pahawang',
    price: 25000,
    includes: [
      'Masuk area pulau',
      'Akses pantai umum',
      'Area parkir',
      'Toilet umum',
    ],
    icon: '🏖️',
    color: const Color(0xFF00B4D8),
  ),
  TicketPackage(
    id: '2',
    name: 'Paket Snorkeling',
    description: 'Paket snorkeling lengkap dengan peralatan',
    price: 150000,
    includes: [
      'Tiket masuk pulau',
      'Sewa alat snorkeling',
      'Guide lokal',
      '1x makan siang',
      'Dokumentasi underwater',
      'Asuransi',
    ],
    icon: '🤿',
    isPopular: true,
    color: const Color(0xFF0077B6),
  ),
  TicketPackage(
    id: '3',
    name: 'Paket Diving',
    description: 'Paket diving untuk pemula dan berpengalaman',
    price: 350000,
    includes: [
      'Tiket masuk pulau',
      'Sewa alat diving lengkap',
      'Instruktur bersertifikat',
      '2x dive spot',
      '2x makan',
      'Dokumentasi underwater',
      'Sertifikat',
      'Asuransi',
    ],
    icon: '🐠',
    color: const Color(0xFF023E8A),
  ),
  TicketPackage(
    id: '4',
    name: 'Paket Island Hopping',
    description: 'Jelajahi beberapa pulau sekitar',
    price: 250000,
    includes: [
      'Tiket masuk semua pulau',
      'Perahu boat',
      'Guide lokal',
      'Snorkeling di 3 spot',
      '1x makan siang',
      'Dokumentasi',
      'Asuransi',
    ],
    icon: '🚤',
    color: const Color(0xFFFF6B35),
  ),
  TicketPackage(
    id: '5',
    name: 'Paket Camping',
    description: 'Bermalam di tepi pantai Pulau Pahawang',
    price: 200000,
    includes: [
      'Tiket masuk pulau',
      'Sewa tenda & sleeping bag',
      'Api unggun',
      'BBQ dinner',
      'Breakfast',
      'Musik akustik',
      'Dokumentasi',
    ],
    icon: '⛺',
    color: const Color(0xFF2ECC71),
  ),
  TicketPackage(
    id: '6',
    name: 'Paket Mancing',
    description: 'Fishing trip di perairan Pulau Pahawang',
    price: 300000,
    includes: [
      'Tiket masuk pulau',
      'Sewa perahu mancing',
      'Alat pancing',
      'Guide mancing',
      '1x makan',
      'Hasil tangkapan dibawa',
      'Dokumentasi',
    ],
    icon: '🎣',
    color: const Color(0xFF9B59B6),
  ),
];