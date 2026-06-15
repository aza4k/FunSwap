import 'package:flutter/material.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/features/main_layout.dart';
import 'package:funswap/core/services/localization_service.dart';
import 'package:funswap/core/services/preferences_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingStep> get _steps => [
    OnboardingStep(
      title: 'onboarding_title_1'.tr,
      subtitle: 'onboarding_subtitle_1'.tr,
      illustrationType: IllustrationType.folder,
    ),
    OnboardingStep(
      title: 'onboarding_title_2'.tr,
      subtitle: 'onboarding_subtitle_2'.tr,
      illustrationType: IllustrationType.orbit,
    ),
    OnboardingStep(
      title: 'onboarding_title_3'.tr,
      subtitle: 'onboarding_subtitle_3'.tr,
      illustrationType: IllustrationType.security,
    ),
    OnboardingStep(
      title: 'onboarding_title_4'.tr,
      subtitle: 'onboarding_subtitle_4'.tr,
      illustrationType: IllustrationType.rocket,
    ),
    OnboardingStep(
      title: 'onboarding_title_5'.tr,
      subtitle: 'onboarding_subtitle_5'.tr,
      illustrationType: IllustrationType.mobile,
    ),
    OnboardingStep(
      title: 'onboarding_title_6'.tr,
      subtitle: 'onboarding_subtitle_6'.tr,
      illustrationType: IllustrationType.logo,
    ),
  ];

  Future<void> _completeOnboarding() async {
    await PreferencesService.setOnboardingCompleted(true);
    await PreferencesService.setLanguage(appLanguageNotifier.value);
    await PreferencesService.setDarkMode(true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepsList = _steps;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
        title: const Text('FunSwap'),
        actions: [
          if (_currentPage < stepsList.length - 1)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'onboarding_skip'.tr,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: stepsList.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPageContent(stepsList[index]);
                },
              ),
            ),
            
            // Bottom Action Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(stepsList.length, (index) {
                      final isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: isSelected ? 24 : 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                        ),
                      );
                    }),
                  ),
                  
                  // Keyingi / Boshlash button
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < stepsList.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == stepsList.length - 1 ? 'onboarding_start'.tr : 'onboarding_next'.tr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == stepsList.length - 1 ? Icons.check : Icons.arrow_forward,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Widget
          Expanded(
            flex: 5,
            child: Center(
              child: _buildIllustration(step.illustrationType),
            ),
          ),
          
          // Texts
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  step.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(IllustrationType type) {
    switch (type) {
      case IllustrationType.folder:
        return Center(
          child: Image.asset(
            'assets/icons/folder_logo.png',
            width: 320,
            height: 320,
            fit: BoxFit.contain,
          ),
        );
      
      case IllustrationType.orbit:
        return Stack(
          alignment: Alignment.center,
          children: [
            // Floating File Icons around central logo (made larger and cleaner)
            Positioned(
              left: 10,
              top: 20,
              child: Image.asset('assets/icons/pdf_logo.png', width: 64, height: 64),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Image.asset('assets/icons/doc_logo.png', width: 64, height: 64),
            ),
            Positioned(
              left: 30,
              bottom: 20,
              child: Image.asset('assets/icons/image_logo.png', width: 64, height: 64),
            ),
            Positioned(
              right: 30,
              bottom: 20,
              child: Image.asset('assets/icons/music_logo.png', width: 64, height: 64),
            ),
            // Central Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                image: const DecorationImage(
                  image: AssetImage('assets/icons/app_logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );

      case IllustrationType.security:
        return Center(
          child: Image.asset(
            'assets/icons/safe_logo.png',
            width: 320,
            height: 320,
            fit: BoxFit.contain,
          ),
        );

      case IllustrationType.rocket:
        return Center(
          child: Image.asset(
            'assets/icons/rocket_logo.png',
            width: 320,
            height: 320,
            fit: BoxFit.contain,
          ),
        );

      case IllustrationType.mobile:
        return Container(
          width: 160,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surfaceLight, width: 4),
            borderRadius: BorderRadius.circular(30),
            color: AppColors.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 55,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case IllustrationType.logo:
        return Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              image: const DecorationImage(
                image: AssetImage('assets/icons/app_logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
    }
  }
}

enum IllustrationType { folder, orbit, security, rocket, mobile, logo }

class OnboardingStep {
  final String title;
  final String subtitle;
  final IllustrationType illustrationType;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.illustrationType,
  });
}

