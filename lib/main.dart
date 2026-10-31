import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'screens/splash_screen.dart';

import 'package:flutter/services.dart';
import 'services/adoption_journey_service.dart';
import 'services/favorites_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    // Initialize offline/realtime services
    await FavoritesService().init();
    await NotificationService().init();
    await ThemeService().init();

    // Adoption journey alerts follow whoever is signed in.
    AdoptionJourneyService().init();
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => AdoptionJourneyService().init(),
    );

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const MyApp());
    
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Supabase initialization failed:\n\n$e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Manrope is already wide; default M3 tracking makes body text look loose.
const _textTheme = TextTheme(
  bodyLarge: TextStyle(letterSpacing: 0.1),
  bodyMedium: TextStyle(letterSpacing: 0),
  bodySmall: TextStyle(letterSpacing: 0.1),
  labelLarge: TextStyle(letterSpacing: 0.1),
);

final _pageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Future Pet',
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamily: 'Manrope',
            textTheme: _textTheme,
            pageTransitionsTheme: _pageTransitions,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFA94327),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5FAFD),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF062B35),
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamily: 'Manrope',
            textTheme: _textTheme,
            pageTransitionsTheme: _pageTransitions,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFA94327),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E293B),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            cardColor: const Color(0xFF1E293B),
            dividerColor: const Color(0xFF334155),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Color(0xFFF8FAFC),
              elevation: 0,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
