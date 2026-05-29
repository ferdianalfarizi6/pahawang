import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';

class OperationalScreen extends StatelessWidget {
  const OperationalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentDay = now.weekday;

    final List<Map<String, dynamic>> schedules = [
      {
        'day': 'Senin',
        'open': '08:00',
        'close': '17:00',
        'isOpen': true,
        'dayIndex': 1,
      },
      {
        'day': 'Selasa',
        'open': '08:00',
        'close': '17:00',
        'isOpen': true,
        'dayIndex': 2,
      },
      {
        'day': 'Rabu',
        'open': '08:00',
        'close': '17:00',
        'isOpen': true,
        'dayIndex': 3,
      },
      {
        'day': 'Kamis',
        'open': '08:00',
        'close': '17:00',
        'isOpen': true,
        'dayIndex': 4,
      },
      {
        'day': 'Jumat',
        'open': '08:00',
        'close': '17:30',
        'isOpen': true,
        'dayIndex': 5,
      },
      {
        'day': 'Sabtu',
        'open': '07:00',
        'close': '18:00',
        'isOpen': true,
        'dayIndex': 6,
      },
      {
        'day': 'Minggu',
        'open': '07:00',
        'close': '18:00',
        'isOpen': true,
        'dayIndex': 7,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Jam Operasional',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.success],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🕐', style: TextStyle(fontSize: 50)),
                        SizedBox(height: 8),
                        Text(
                          'Jadwal Buka & Tutup',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Current Status
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withOpacity(0.15),
                        AppColors.success.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saat Ini Buka',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tutup pukul 17:00 WIB',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        '🟢',
                        style: TextStyle(fontSize: 30),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Schedule List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text('Jadwal Mingguan', style: AppTheme.heading2),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final schedule = schedules[index];
                  final isToday = schedule['dayIndex'] == currentDay;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isToday
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          width: isToday ? 2 : 1,
                        ),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          // Day indicator
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.primary
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                schedule['day'].substring(0, 2),
                                style: TextStyle(
                                  color: isToday ? Colors.white : AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Day info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      schedule['day'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isToday
                                            ? AppColors.primary
                                            : AppColors.textDark,
                                      ),
                                    ),
                                    if (isToday) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'HARI INI',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 14,
                                        color: schedule['isOpen']
                                            ? AppColors.success
                                            : Colors.red),
                                    const SizedBox(width: 4),
                                    Text(
                                      schedule['isOpen']
                                          ? '${schedule['open']} - ${schedule['close']} WIB'
                                          : 'Tutup',
                                      style: TextStyle(
                                        color: schedule['isOpen']
                                            ? AppColors.success
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: schedule['isOpen']
                                  ? AppColors.success.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              schedule['isOpen'] ? 'Buka' : 'Tutup',
                              style: TextStyle(
                                color: schedule['isOpen']
                                    ? AppColors.success
                                    : Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: schedules.length,
              ),
            ),

            // Special Hours Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('⚠️', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Text('Jam Khusus', style: AppTheme.heading3),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildSpecialHour(
                        '🌅 Sunrise Tour',
                        '05:00 - 07:00 WIB',
                        'Weekend & Hari Libur',
                      ),
                      const SizedBox(height: 8),
                      _buildSpecialHour(
                        '🌙 Night Fishing',
                        '19:00 - 22:00 WIB',
                        'Dengan reservasi',
                      ),
                      const SizedBox(height: 8),
                      _buildSpecialHour(
                        '🎉 Event Khusus',
                        'Sesuai jadwal event',
                        'Cek media sosial kami',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Holiday Schedule
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎄', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Text('Jadwal Hari Libur', style: AppTheme.heading3),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildHolidayItem(
                        'Hari Raya Idul Fitri',
                        'Tutup (H+1 & H+2)',
                        Colors.green,
                      ),
                      _buildHolidayItem(
                        'Hari Kemerdekaan RI',
                        'Buka (07:00 - 18:00)',
                        Colors.red,
                      ),
                      _buildHolidayItem(
                        'Tahun Baru',
                        'Buka (07:00 - 20:00)',
                        AppColors.primary,
                      ),
                      _buildHolidayItem(
                        'Natal',
                        'Buka (08:00 - 17:00)',
                        Colors.purple,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_rounded,
                                color: AppColors.primary, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Jadwal dapat berubah sewaktu-waktu. Pastikan untuk mengecek media sosial kami sebelum berkunjung.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialHour(String title, String time, String note) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        Expanded(
          flex: 2,
          child: Text(time,
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        ),
        Expanded(
          flex: 2,
          child: Text(note,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              textAlign: TextAlign.end),
        ),
      ],
    );
  }

  Widget _buildHolidayItem(String name, String schedule, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text(schedule,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}