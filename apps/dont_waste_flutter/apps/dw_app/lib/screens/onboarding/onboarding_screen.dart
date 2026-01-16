import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dw_ui/dw_ui.dart';

/// Onboarding data model
class OnboardingPage {
  final String emoji;
  final String title;
  final String description;
  final Color accentColor;

  const OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}

/// Premium onboarding screen with page view and animations
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '🛒',
      title: 'Discover Surplus Deals',
      description:
          'Find amazing deals on surplus food and products from local businesses. Save up to 70% on quality items.',
      accentColor: Color(0xFF10B981),
    ),
    OnboardingPage(
      emoji: '📍',
      title: 'Find Nearby Sellers',
      description:
          'Use our interactive map to discover sellers near you. Filter by category, distance, and availability.',
      accentColor: Color(0xFF3B82F6),
    ),
    OnboardingPage(
      emoji: '⏰',
      title: 'Never Miss a Deal',
      description:
          'Get notified about expiring deals and new listings. Set up alerts for your favorite categories.',
      accentColor: Color(0xFFF59E0B),
    ),
    OnboardingPage(
      emoji: '🌍',
      title: 'Reduce Food Waste',
      description:
          'Join thousands of users making a difference. Every purchase helps reduce waste and save the planet.',
      accentColor: Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go('/');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0A0A0B), const Color(0xFF141416)]
                : [Colors.white, const Color(0xFFF8F9FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _OnboardingPageContent(
                      page: page,
                      isDark: isDark,
                    );
                  },
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[_currentPage].accentColor
                            : (isDark ? Colors.white24 : Colors.black12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: _currentPage > 0 ? 2 : 1,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pages[_currentPage].accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingPage page;
  final bool isDark;

  const _OnboardingPageContent({
    required this.page,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji with animated container
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: page.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: page.accentColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      page.emoji,
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
