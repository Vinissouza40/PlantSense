import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'firebase_options.dart';
import 'auth_check_page.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

    
  );
   await Supabase.initialize(
    url: 'https://otqwfksxywkdqnjcwxuu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90cXdma3N4eXdrZHFuamN3eHV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwOTcyNTAsImV4cCI6MjA4ODY3MzI1MH0.x-rYCvdwHONAy-I2w6pT3UR-cZ05h-q1caTSXXP2TAY',
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
        splash: Lottie.asset(
          'assets/plantsense_logo_animation_lottie.json',
          repeat: true,
        ),
        nextScreen: const AuthCheckPage(), // Verifica se está logado
        splashIconSize: 200,
        backgroundColor: Colors.white,
        duration: 6000,
        splashTransition: SplashTransition.fadeTransition,
      ),
    );
  }
}