import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/colors.dart';
import '../widgets/premium_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _storage = const FlutterSecureStorage();

  final List<Map<String, String>> _slides = [
    {
      'title': 'Surga Bahari Tersembunyi',
      'description': 'Temukan keindahan pasir putih bersih dan pesona tropical alami yang menakjubkan di Pulau Pahawang.',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    },
    {
      'title': 'Pesona Bawah Laut',
      'description': 'Nikmati snorkeling dan diving terbaik bersama biota laut eksotis dan terumbu karang yang terjaga indah.',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
    },
    {
      'title': 'Resort & Villa Premium',
      'description': 'Rasakan kenyamanan menginap di villa terapung premium dengan pemandangan langsung ke lautan biru.',
      'image': 'https://images.unsplash.com/photo-1507400492013-162706c8c05e?w=800',
    },
  ];

  Future<void> _completeOnboarding() async {
    await _storage.write(key: 'seen_onboarding', value: 'true');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Slide page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Full bleed illustration image
                  Image.network(
                    slide['image']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryGradient),
                      ),
                    ),
                  ),
                  // Dark shadow gradient from bottom
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Text Content
                  Padding(
                    padding: const EdgeInsets.only(left: 28, right: 28, top: 60, bottom: 110),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  slide['title']!,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.8,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  slide['description']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'Lewati',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Bottom Slide Indicator & Action Button Block
          Positioned(
            bottom: 40,
            left: 28,
            right: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Animated dots
                Row(
                  children: List.generate(_slides.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.primaryLight : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                // Premium action button
                PremiumButton(
                  text: _currentPage == _slides.length - 1 ? 'Mulai' : 'Lanjut',
                  width: 120,
                  height: 46,
                  isSecondary: _currentPage == _slides.length - 1,
                  onPressed: () {
                    if (_currentPage == _slides.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
