import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../models/villa_model.dart';
import '../models/package_model.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double height;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height = 50,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      onTap: isEnabled ? widget.onPressed : null,
      child: Transform.scale(
        scale: _scale,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.6,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: widget.isOutlined
                ? BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isSecondary ? AppColors.accent : AppColors.primary,
                      width: 1.5,
                    ),
                  )
                : BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isSecondary
                          ? AppColors.sunsetGradient
                          : AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isEnabled
                        ? [
                            BoxShadow(
                              color: (widget.isSecondary ? AppColors.accent : AppColors.primary)
                                  .withOpacity(0.24),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ]
                        : null,
                  ),
            child: Theme(
              data: Theme.of(context).copyWith(
                iconTheme: IconThemeData(
                  color: widget.isOutlined
                      ? (widget.isSecondary ? AppColors.accent : AppColors.primary)
                      : Colors.white,
                ),
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.isOutlined
                      ? (widget.isSecondary ? AppColors.accent : AppColors.primary)
                      : Colors.white,
                  fontFamily: 'Poppins',
                ),
                child: Center(child: buttonContent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumVillaCard extends StatefulWidget {
  final Villa villa;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const PremiumVillaCard({
    super.key,
    required this.villa,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  State<PremiumVillaCard> createState() => _PremiumVillaCardState();
}

class _PremiumVillaCardState extends State<PremiumVillaCard> {
  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: AppTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with gradient overlay
              Stack(
                children: [
                  Image.network(
                    widget.villa.thumbnail,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 40),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Room Badge
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.door_sliding_outlined, color: AppColors.primaryLight, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Kamar: ${widget.villa.availableRoom}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Floating Favorite Button
                  Positioned(
                    top: 14,
                    right: 14,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: IconButton(
                        icon: Icon(
                          widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: widget.isFavorite ? Colors.redAccent : Colors.grey.shade600,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: widget.onFavoriteTap ?? () {},
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.villa.name,
                            style: AppTheme.heading3.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              SizedBox(width: 2),
                              Text(
                                '4.9',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.villa.location,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Facilities Preview
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.villa.facilities
                          .take(3)
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Text(f, style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    
                    // Price & Call-To-Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mulai dari', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _formatPrice(widget.villa.pricePerNight),
                                  style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                const Text(' /malam', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        PremiumButton(
                          text: 'Detail',
                          width: 90,
                          height: 38,
                          onPressed: widget.onTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumPackageCard extends StatefulWidget {
  final TourPackage package;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const PremiumPackageCard({
    super.key,
    required this.package,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  State<PremiumPackageCard> createState() => _PremiumPackageCardState();
}

class _PremiumPackageCardState extends State<PremiumPackageCard> {
  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: AppTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with gradient overlay
              Stack(
                children: [
                  Image.network(
                    widget.package.thumbnail,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 40),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Duration Badge
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_bottom_rounded, color: AppColors.accentLight, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            widget.package.duration,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Floating Favorite Button
                  Positioned(
                    top: 14,
                    right: 14,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: IconButton(
                        icon: Icon(
                          widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: widget.isFavorite ? Colors.redAccent : Colors.grey.shade600,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: widget.onFavoriteTap ?? () {},
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.package.title,
                            style: AppTheme.heading3.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              SizedBox(width: 2),
                              Text(
                                '4.8',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.package.location,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Facilities Preview
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.package.facilities
                          .take(3)
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Text(f, style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    
                    // Price & Call-To-Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mulai dari', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _formatPrice(widget.package.price),
                                  style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                const Text(' /orang', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        PremiumButton(
                          text: 'Detail',
                          width: 90,
                          height: 38,
                          isSecondary: true,
                          onPressed: widget.onTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
