import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/cards/modern_card.dart';

class OperationalScreen extends StatefulWidget {
  const OperationalScreen({super.key});

  @override
  State<OperationalScreen> createState() => _OperationalScreenState();
}

class _OperationalScreenState extends State<OperationalScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late DateTime _now;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _schedules = [
    {'day': 'Senin', 'open': '08:00', 'close': '17:00', 'isOpen': true, 'dayIndex': 1, 'icon': '🌤'},
    {'day': 'Selasa', 'open': '08:00', 'close': '17:00', 'isOpen': true, 'dayIndex': 2, 'icon': '☀️'},
    {'day': 'Rabu', 'open': '08:00', 'close': '17:00', 'isOpen': true, 'dayIndex': 3, 'icon': '🌊'},
    {'day': 'Kamis', 'open': '08:00', 'close': '17:00', 'isOpen': true, 'dayIndex': 4, 'icon': '🌴'},
    {'day': 'Jumat', 'open': '08:00', 'close': '17:30', 'isOpen': true, 'dayIndex': 5, 'icon': '🏄'},
    {'day': 'Sabtu', 'open': '07:00', 'close': '18:00', 'isOpen': true, 'dayIndex': 6, 'icon': '🎉'},
    {'day': 'Minggu', 'open': '07:00', 'close': '18:00', 'isOpen': true, 'dayIndex': 7, 'icon': '🌅'},
  ];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool _isCurrentlyOpen() {
    final today = _schedules.firstWhere(
      (s) => s['dayIndex'] == _now.weekday,
      orElse: () => {'isOpen': false},
    );
    if (!(today['isOpen'] as bool)) return false;

    final openParts = (today['open'] as String).split(':');
    final closeParts = (today['close'] as String).split(':');

    final openMin = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
    final closeMin = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);
    final nowMin = _now.hour * 60 + _now.minute;

    return nowMin >= openMin && nowMin < closeMin;
  }

  String _getCloseTime() {
    final today = _schedules.firstWhere(
      (s) => s['dayIndex'] == _now.weekday,
      orElse: () => {'close': '--:--'},
    );
    return '${today['close']} WIB';
  }

  String _twoDigit(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = _isCurrentlyOpen();
    final timeStr =
        '${_twoDigit(_now.hour)}:${_twoDigit(_now.minute)}:${_twoDigit(_now.second)}';
    final statusGradient = isOpen
        ? const LinearGradient(
            colors: [Color(0xFF00897B), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFD81B60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header ────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              stretch: true,
              backgroundColor: theme.colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                title: const Text(
                  'Jam Operasional',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: 0.3,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Live clock
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                timeStr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Jadwal Buka & Tutup',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                                letterSpacing: 0.5,
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

            // ─── Status Card ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: statusGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: (isOpen
                                ? const Color(0xFF00897B)
                                : const Color(0xFFE53935))
                            .withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Animated pulse dot
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, __) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                isOpen ? '🟢' : '🔴',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOpen ? 'Saat Ini Buka' : 'Saat Ini Tutup',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOpen
                                  ? 'Tutup pukul ${_getCloseTime()}'
                                  : 'Silakan kunjungi kami besok',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isOpen ? 'OPEN' : 'CLOSED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Weekly Schedule ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Text('Jadwal Mingguan', style: theme.textTheme.headlineMedium),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Buka 7 Hari',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Schedule timeline
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final s = _schedules[index];
                  final isToday = s['dayIndex'] == _now.weekday;
                  final isLast = index == _schedules.length - 1;
                  return _ScheduleRow(
                    schedule: s,
                    isToday: isToday,
                    isLast: isLast,
                    nowMinute: _now.hour * 60 + _now.minute,
                  );
                },
                childCount: _schedules.length,
              ),
            ),

            // ─── Special Hours ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text('Jam Khusus & Aktivitas', style: theme.textTheme.headlineMedium),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  children: [
                    _SpecialCard(
                      emoji: '🌅',
                      title: 'Sunrise Tour',
                      time: '05:00 – 07:00 WIB',
                      note: 'Weekend & Hari Libur',
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 10),
                    _SpecialCard(
                      emoji: '🌊',
                      title: 'Snorkeling & Diving',
                      time: '08:00 – 15:00 WIB',
                      note: 'Setiap hari (cuaca baik)',
                      color: const Color(0xFF0288D1),
                    ),
                    const SizedBox(height: 10),
                    _SpecialCard(
                      emoji: '🌙',
                      title: 'Night Fishing',
                      time: '19:00 – 22:00 WIB',
                      note: 'Dengan reservasi',
                      color: const Color(0xFF7B1FA2),
                    ),
                    const SizedBox(height: 10),
                    _SpecialCard(
                      emoji: '🎉',
                      title: 'Event Khusus',
                      time: 'Sesuai jadwal event',
                      note: 'Cek media sosial kami',
                      color: const Color(0xFFD81B60),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Holiday ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text('Hari Libur Nasional', style: theme.textTheme.headlineMedium),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: ModernCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildHolidayRow('🕌', 'Idul Fitri (H+1 & H+2)',
                          'Tutup', const Color(0xFF43A047)),
                      _divider(theme),
                      _buildHolidayRow('🇮🇩', 'Hari Kemerdekaan RI',
                          '07:00 – 18:00', const Color(0xFFE53935)),
                      _divider(theme),
                      _buildHolidayRow('🎆', 'Tahun Baru',
                          '07:00 – 20:00', theme.colorScheme.primary),
                      _divider(theme),
                      _buildHolidayRow('🎄', 'Natal',
                          '08:00 – 17:00', const Color(0xFF7B1FA2)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.05),
                              theme.colorScheme.secondary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: theme.colorScheme.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Jadwal dapat berubah sewaktu-waktu. '
                                'Selalu cek media sosial kami sebelum berkunjung.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.primary,
                                  height: 1.5,
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

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
      );

  Widget _buildHolidayRow(String emoji, String name, String schedule, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Schedule Row (Timeline) ──────────────────────────────────────────────────

class _ScheduleRow extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final bool isToday;
  final bool isLast;
  final int nowMinute;

  const _ScheduleRow({
    required this.schedule,
    required this.isToday,
    required this.isLast,
    required this.nowMinute,
  });

  double _progress() {
    if (!isToday || !(schedule['isOpen'] as bool)) return 0;
    final openParts = (schedule['open'] as String).split(':');
    final closeParts = (schedule['close'] as String).split(':');
    final openMin = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
    final closeMin = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);
    if (nowMinute < openMin || nowMinute >= closeMin) return 0;
    return (nowMinute - openMin) / (closeMin - openMin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prog = _progress();
    final isActiveNow = prog > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: isToday
                      ? AppTheme.primaryGradient
                      : null,
                  color: isToday ? null : theme.colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    schedule['icon'] ?? schedule['day'].substring(0, 2),
                    style: TextStyle(
                      fontSize: isToday ? 20 : 14,
                      color: isToday ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 52,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isToday
                          ? [
                              theme.colorScheme.primary.withOpacity(0.5),
                              Colors.transparent,
                            ]
                          : [
                              theme.colorScheme.outlineVariant,
                              theme.colorScheme.surfaceVariant,
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToday
                    ? theme.colorScheme.primary.withOpacity(0.04)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isToday
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.outlineVariant,
                  width: isToday ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isToday ? 0.06 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
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
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'HARI INI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: schedule['isOpen']
                              ? const Color(0xFF00897B).withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          schedule['isOpen'] ? 'Buka' : 'Tutup',
                          style: TextStyle(
                            color: schedule['isOpen']
                                ? const Color(0xFF00897B)
                                : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 14,
                        color: schedule['isOpen']
                            ? const Color(0xFF00897B)
                            : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        schedule['isOpen']
                            ? '${schedule['open']} – ${schedule['close']} WIB'
                            : 'Libur',
                        style: TextStyle(
                          color: schedule['isOpen']
                              ? const Color(0xFF00897B)
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  // Progress bar for today
                  if (isActiveNow) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: prog,
                              minHeight: 5,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(prog * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}

// ─── Special Activity Card ────────────────────────────────────────────────────

class _SpecialCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String time;
  final String note;
  final Color color;

  const _SpecialCard({
    required this.emoji,
    required this.title,
    required this.time,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}