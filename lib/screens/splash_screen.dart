import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final session =
        Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // User is already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      // User is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/onboarding_pet.png',
              width: 120,
              height: 120,
            ),

            const SizedBox(height: 30),

            const Text(
              'My Future Pet',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA94327),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              'Your Journey to a New Best Friend\nStarts Here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 80),

            const CircularProgressIndicator(),

            const SizedBox(height: 15),

            const Text(
              'WARMING UP...',
              style: TextStyle(
                color: Color(0xFFA94327),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}









// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'login_screen.dart';
// import 'onboarding_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _startSplash();
//   }

//   Future<void> _startSplash() async {
//     await Future.delayed(
//       const Duration(seconds: 3),
//     );

//     if (!mounted) return;

//     final prefs = await SharedPreferences.getInstance();

//     final hasSeenOnboarding =
//         prefs.getBool('hasSeenOnboarding') ?? false;

//     if (hasSeenOnboarding) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const LoginScreen(),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const OnboardingScreen(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       body: SafeArea(
//         child: Column(
//           children: [
//             const Spacer(flex: 2),

//             Container(
//               width: 130,
//               height: 130,

//               padding: const EdgeInsets.all(15),

//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5FAFD),
//                 borderRadius: BorderRadius.circular(25),

//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 15,
//                     offset: const Offset(0, 7),
//                   ),
//                 ],
//               ),

//               child: Image.asset(
//                 'assets/images/logo.png',
//                 fit: BoxFit.contain,
//               ),
//             ),

//             const SizedBox(height: 55),

//             const Text(
//               'My Future\nPet',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 fontSize: 54,
//                 height: 1.05,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFA94327),
//               ),
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               'Your Journey to a New Best Friend\nStarts Here.',
//               textAlign: TextAlign.center,

//               style: TextStyle(
//                 fontSize: 16,
//                 height: 1.5,
//                 color: Color(0xFF6F5C56),
//               ),
//             ),

//             const Spacer(flex: 2),

//             const SizedBox(
//               width: 30,
//               height: 30,
//               child: CircularProgressIndicator(
//                 strokeWidth: 3,
//                 color: Color(0xFFA94327),
//               ),
//             ),

//             const SizedBox(height: 18),

//             const Text(
//               'WARMING UP...',
//               style: TextStyle(
//                 color: Color(0xFFA94327),
//                 fontSize: 12,
//                 letterSpacing: 1.5,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),

//             const SizedBox(height: 28),

//             const Text(
//               'Tap anywhere to start',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Color(0xFF6F5C56),
//               ),
//             ),

//             const SizedBox(height: 25),
//           ],
//         ),
//       ),
//     );
//   }
// }