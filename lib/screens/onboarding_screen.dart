import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/images/pic1.png',
      'title': 'Find Your Perfect Match',
      'description':
          'Discover pets looking for a loving home. Browse profiles, learn their stories, and find your new best friend.',
    },

    {
      'image': 'assets/images/pic2.png',
      'title': 'Visualize Your New Friend',
      'description':
          'Use our Augmented Reality feature to see how your future pet fits into your home and lifestyle.',
    },

    {
      'image': 'assets/images/pic3.png',
      'title': 'Bring Happiness Home',
      'description':
          'Start your journey today and find the perfect companion for you. Your new best friend is waiting.',
    },
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'hasSeenOnboarding',
      true,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,

                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  final page = pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    child: Column(
                      children: [
                        const SizedBox(height: 25),

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(32),

                          child: Image.asset(
                            page['image']!,
                            height: 360,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA94327),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 25,
                          ),

                          child: Text(
                            page['description']!,
                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF756560),
                            ),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) {
                  final selected =
                      currentPage == index;

                  return AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 250),

                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),

                    width: selected ? 28 : 8,
                    height: 8,

                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFA94327)
                          : const Color(0xFFD8B6AC),

                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
              ),

              child: Row(
                children: [
                  TextButton(
                    onPressed: _finishOnboarding,

                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF624D47),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: 200,
                    height: 56,

                    child: ElevatedButton(
                      onPressed: () {
                        if (currentPage ==
                            pages.length - 1) {
                          _finishOnboarding();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                            curve: Curves.easeInOut,
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFA94327),

                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30),
                        ),

                        elevation: 0,
                      ),

                      child: Text(
                        currentPage ==
                                pages.length - 1
                            ? 'Get Started'
                            : 'Next',

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}