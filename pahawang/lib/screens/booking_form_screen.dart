import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../models/villa_model.dart';
import '../models/package_model.dart';
import '../models/booking_model.dart';
import '../providers/bookings_provider.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _totalGuest = 1;
  String _selectedPayment = 'QRIS';

  final List<Map<String, String>> _paymentMethods = [
    {'name': 'QRIS', 'icon': '📱'},
    {'name': 'Bank Transfer', 'icon': '🏦'},
    {'name': 'Dana', 'icon': '🪙'},
    {'name': 'OVO', 'icon': '🟣'},
    {'name': 'GoPay', 'icon': '🟢'},
  ];

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  int _calculateNights() {
    if (_checkIn == null || _checkOut == null) return 0;
    final diff = _checkOut!.difference(_checkIn!).inDays;
    return diff > 0 ? diff : 1;
  }

  double _calculateTotal(double unitPrice, bool isVilla) {
    if (isVilla) {
      final nights = _calculateNights();
      return unitPrice * (nights > 0 ? nights : 1);
    } else {
      return unitPrice * _totalGuest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Villa? villa = args['villa'];
    final TourPackage? package = args['package'];
    final isVilla = villa != null;

    final name = isVilla ? villa.name : package!.title;
    final thumbnail = isVilla ? villa.thumbnail : package!.thumbnail;
    final unitPrice = isVilla ? villa.pricePerNight : package!.price;
    final maxCapacity = isVilla ? villa.maxGuest : package!.quota;

    final totalPrice = _calculateTotal(unitPrice, isVilla);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout Pemesanan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<BookingsProvider>(
        builder: (context, bookingsProvider, child) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Dynamic Summary Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: AppTheme.cardDecoration,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  thumbnail,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isVilla ? AppColors.primary : AppColors.accent).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isVilla ? 'Villa & Resort' : 'Paket Wisata',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isVilla ? AppColors.primary : AppColors.accent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      name,
                                      style: AppTheme.heading3.copyWith(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatPrice(unitPrice)} / ${isVilla ? 'malam' : 'orang'}',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Date Pickers Section
                        Text('Tanggal Kunjungan', style: AppTheme.heading3),
                        const SizedBox(height: 12),
                        if (isVilla) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateTile(
                                  label: 'Check-In',
                                  date: _checkIn,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now().add(const Duration(days: 1)),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 120)),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _checkIn = picked;
                                        if (_checkOut != null && _checkOut!.isBefore(_checkIn!)) {
                                          _checkOut = null;
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDateTile(
                                  label: 'Check-Out',
                                  date: _checkOut,
                                  onTap: () async {
                                    if (_checkIn == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Silakan pilih tanggal Check-In terlebih dahulu.')),
                                      );
                                      return;
                                    }
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _checkIn!.add(const Duration(days: 1)),
                                      firstDate: _checkIn!.add(const Duration(days: 1)),
                                      lastDate: _checkIn!.add(const Duration(days: 120)),
                                    );
                                    if (picked != null) {
                                      setState(() => _checkOut = picked);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_checkIn != null && _checkOut != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Durasi menginap: ${_calculateNights()} malam',
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ] else ...[
                          _buildDateTile(
                            label: 'Tanggal Kunjungan',
                            date: _checkIn,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                              );
                              if (picked != null) {
                                setState(() => _checkIn = picked);
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: 24),

                        // 3. Guest Count Stepper
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Jumlah Tamu', style: AppTheme.heading3),
                                const SizedBox(height: 4),
                                Text('Kapasitas maksimal: $maxCapacity orang', style: AppTheme.caption),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: _totalGuest > 1
                                        ? () => setState(() => _totalGuest--)
                                        : null,
                                  ),
                                  Text(
                                    '$_totalGuest',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: _totalGuest < maxCapacity
                                        ? () => setState(() => _totalGuest++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // 4. Payment Method Grid
                        Text('Metode Pembayaran', style: AppTheme.heading3),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.8,
                          ),
                          itemCount: _paymentMethods.length,
                          itemBuilder: (context, index) {
                            final pm = _paymentMethods[index];
                            final isSelected = _selectedPayment == pm['name'];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPayment = pm['name']!),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.grey.shade200,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    Text(pm['icon']!, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 10),
                                    Text(
                                      pm['name']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppColors.primary : AppColors.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Dynamic Sticky Bottom Action Panel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Pembayaran', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              _formatPrice(totalPrice),
                              style: TextStyle(
                                color: isVilla ? AppColors.primary : AppColors.accent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: bookingsProvider.isLoading ? null : () async {
                              // Perform Validations
                              if (_checkIn == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Silakan tentukan tanggal terlebih dahulu.')),
                                );
                                return;
                              }
                              if (isVilla && _checkOut == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Silakan tentukan tanggal Check-Out terlebih dahulu.')),
                                );
                                return;
                              }

                              final Booking? booking = await bookingsProvider.createBooking(
                                bookingType: isVilla ? 'villa' : 'package',
                                villaId: isVilla ? villa.id : null,
                                packageId: !isVilla ? package!.id : null,
                                checkIn: _checkIn!.toIso8601String(),
                                checkOut: isVilla ? _checkOut!.toIso8601String() : null,
                                totalGuest: _totalGuest,
                                paymentMethod: _selectedPayment,
                              );

                              if (booking != null && context.mounted) {
                                Navigator.of(context).pushReplacementNamed(
                                  '/payment_success',
                                  arguments: booking,
                                );
                              } else {
                                if (context.mounted && bookingsProvider.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(bookingsProvider.error!),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isVilla ? AppColors.primary : AppColors.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: bookingsProvider.isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTile({required String label, DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : '--/--/----',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
            const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
