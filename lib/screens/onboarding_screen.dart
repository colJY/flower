import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../generated/l10n/app_localizations.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      icon: Icons.camera_alt,
      titleKey: 'onboardingTitle1',
      color: Color(0xFFE8B4B8),
    ),
    OnboardingData(
      icon: Icons.favorite,
      titleKey: 'onboardingTitle2',
      color: Color(0xFFA8D8A8),
    ),
    OnboardingData(
      icon: Icons.share,
      titleKey: 'onboardingTitle3',
      color: Color(0xFFA8C8E8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: SafeArea(
        child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildOnboardingPage(
                        _onboardingData[index],
                        l10n,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildBottomSection(l10n),
        ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data, AppLocalizations l10n) {
    String title;
    switch (data.titleKey) {
      case 'onboardingTitle1':
        title = l10n.onboardingTitle1;
        break;
      case 'onboardingTitle2':
        title = l10n.onboardingTitle2;
        break;
      case 'onboardingTitle3':
        title = l10n.onboardingTitle3;
        break;
      default:
        title = '';
    }

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(75),
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFFE8B4B8)
                      : const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  l10n.skip,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _currentPage == _onboardingData.length - 1
                    ? _finishOnboarding
                    : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B4B8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  _currentPage == _onboardingData.length - 1
                      ? l10n.start
                      : l10n.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final IconData icon;
  final String titleKey;
  final Color color;

  OnboardingData({
    required this.icon,
    required this.titleKey,
    required this.color,
  });
}