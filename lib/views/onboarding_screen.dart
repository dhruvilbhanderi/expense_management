import 'package:expense_management/views/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = Get.isRegistered<OnboardingController>()
      ? Get.find<OnboardingController>()
      : Get.put(OnboardingController());
  late PageController pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final pages = [
    _OnboardingPage(
      icon: Icons.analytics,
      title: 'Track Your Expenses',
      description:
          'Keep track of all your expenses and income in one place with detailed analytics',
      color: const Color(0xFF6C63FF),
      gradient: [Color(0xFF6C63FF), Color(0xFF9575CD)],
    ),
    _OnboardingPage(
      icon: Icons.pie_chart,
      title: 'Visual Analytics',
      description:
          'Get insights into your spending habits with beautiful charts and graphs',
      color: const Color(0xFF4ECDC4),
      gradient: [Color(0xFF4ECDC4), Color(0xFF2ECC71)],
    ),
    _OnboardingPage(
      icon: Icons.savings,
      title: 'Save Money',
      description:
          'Set budgets and achieve your financial goals with smart tracking',
      color: const Color(0xFFFFA502),
      gradient: [Color(0xFFFFA502), Color(0xFFFF6B6B)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: pages[currentPage].gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 60),
                    SmoothPageIndicator(
                      controller: pageController,
                      count: pages.length,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white70,
                        spacing: 8,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await controller.completeOnboarding();
                        Get.off(() => const DashboardScreen());
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                    controller.currentPage.value = index;
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) => pages[index],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (controller.currentPage.value == pages.length - 1) {
                                await controller.completeOnboarding();
                                Get.off(() => const DashboardScreen());
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.2),
                            ),
                            child: Text(
                              controller.currentPage.value == pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: pages[controller.currentPage.value].color,
                              ),
                            ),
                          ),
                        )),
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

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
