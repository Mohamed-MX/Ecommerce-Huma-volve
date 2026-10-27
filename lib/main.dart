import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/services/deep_link_service.dart';
import 'core/theme.dart';
import 'features/splash/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Notice: .env file not found or could not be loaded: $e');
  }

  // Initialize deep linking service
  DeepLinkService.instance.init(navigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

