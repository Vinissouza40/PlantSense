import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'firebase_options.dart';
import 'auth_check_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PlantSense());
}

class PlantSense extends StatelessWidget {
  const PlantSense({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "PlantSense",
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: Image.asset(
          'assets/plantsense_logo.png',
          width: 180,
        ),
        nextScreen: const AuthCheckPage(),
        splashIconSize: 200,
        backgroundColor: Colors.white,
        duration: 4000,
        splashTransition: SplashTransition.fadeTransition,
      ),
    );
  }
}