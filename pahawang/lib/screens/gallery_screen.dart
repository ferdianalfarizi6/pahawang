import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/gallery_model.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with TickerProviderStateMixin {
  String _selectedCategory = 'Semua';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Semua', 'icon': '🌊'},
    {'label': 'Bahari', 'icon': '🐠'},
    {'label': 'Pantai', 'icon': '🏖️'},
    {'label': 'Sunset', 'icon': '🌅'},
    {'label': 'Budaya', 'icon': '🎭'},
    {'label': 'Camping', 'icon': '⛺'},
    {'label': 'Alam', 'icon': '🌿'},
  ];

  List<GalleryItem> get _filteredItems {
    if (_selectedCategory == 'Semua') return galleryItems;
    return galleryItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectCategory(String cat) {
    setState(() => _selectedCategory = cat);
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = galleryItems.length;
    final totalLikes =
        galleryItems.fold<int>(0, (sum, item) => sum + item.likes);
    final catCount = _categories.length - 1;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Hero Header ───────────────────────────────────
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              stretch: true,
              backgroundColor: theme.colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                title: const Text(
                  'Galeri & Dokumentasi',
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
                      // decorative circles
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                      ),
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('📸', style: TextStyle(fontSize: 52)),
                            SizedBox(height: 8),
                            Text(
                              'Kenangan Indah Pahawang',
                              style: TextStyle(
                                color: Colors.white70,
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

            // ─── Stats Row ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    _buildStatCard('📷', '$total', 'Foto', const Color(0xFF1565C0), theme),
                    const SizedBox(width: 10),
                    _buildStatCard('❤️', '$totalLikes', 'Likes', const Color(0xFFE53935), theme),
                    const SizedBox(width: 10),
                    _buildStatCard('📂', '$catCount', 'Kategori', const Color(0xFF00897B), theme),
                  ],
                ),
              ),
            ),

            // ─── Category Chips ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategori', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final cat = _categories[i];
                          final isSelected =
                              _selectedCategory == cat['label'];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            child: GestureDetector(
                              onTap: () => _selectCategory(cat['label']),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? AppTheme.primaryGradient
                                      : null,
                                  color: isSelected
                                      ? null
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                              .withOpacity(0.3)
                                          : Colors.black.withOpacity(0.04),
                                      blurRadius: isSelected ? 10 : 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(cat['icon'],
                                        style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat['label'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : theme.colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_filteredItems.length} foto ditemukan',
                      style: TextStyle(
                          fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ─── Gallery Grid ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverFadeTransition(
                opacity: _fadeAnimation,
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredItems[index];
                      return _GalleryCard(
                        item: item,
                        onTap: () => _showImageDetail(item),
                      );
                    },
                    childCount: _filteredItems.length,
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

  Widget _buildStatCard(
      String emoji, String value, String label, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            Text(
              label,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDetail(GalleryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ImageDetailSheet(item: item),
    );
  }
}

// ─── Gallery Card Widget ─────────────────────────────────────────────────────

class _GalleryCard extends StatefulWidget {
  final GalleryItem item;
  final VoidCallback onTap;

  const _GalleryCard({required this.item, required this.onTap});

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Hero(
          tag: 'gallery_${widget.item.id}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.6),
                            theme.colorScheme.secondary.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_rounded,
                              color: Colors.white, size: 36),
                          SizedBox(height: 8),
                          Text('Foto tidak tersedia',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),

                  // Bottom gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Category chip
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        widget.item.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Likes badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_rounded,
                              color: Color(0xFFFF5252), size: 11),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.item.likes}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Title & date
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.item.date,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 9,
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
      ),
    );
  }
}

// ─── Image Detail Bottom Sheet ────────────────────────────────────────────────

class _ImageDetailSheet extends StatelessWidget {
  final GalleryItem item;

  const _ImageDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Hero image
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Hero(
                      tag: 'gallery_${item.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 280,
                          errorBuilder: (_, __, ___) => Container(
                            height: 280,
                            color: theme.colorScheme.surfaceVariant,
                            child: Icon(Icons.image_rounded,
                                size: 60, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Chip(
                              icon: Icons.label_rounded,
                              label: item.category,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            _Chip(
                              icon: Icons.favorite_rounded,
                              label: '${item.likes} likes',
                              color: const Color(0xFFE53935),
                            ),
                            const SizedBox(width: 8),
                            _Chip(
                              icon: Icons.calendar_today_rounded,
                              label: item.date,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Dokumentasi kegiatan wisata di Pulau Pahawang. '
                            'Nikmati keindahan alam bawah laut, pantai berpasir '
                            'putih, dan momen tak terlupakan bersama keluarga dan '
                            'sahabat.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF555555),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.share_rounded,
                                label: 'Bagikan',
                                gradient: AppTheme.primaryGradient,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.download_rounded,
                                label: 'Unduh',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00897B),
                                    Color(0xFF43A047),
                                  ],
                                ),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}