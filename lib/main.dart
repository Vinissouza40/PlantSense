import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'auth_check_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nvpracpsptcmynlmmlws.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52cHJhY3BzcHRjbXlubG1tbHdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxODg3NDAsImV4cCI6MjA4ODc2NDc0MH0.QI5E6rYl1ysjXqEj471P_4H4Juo3qV8Nlmso45TRkqE',
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