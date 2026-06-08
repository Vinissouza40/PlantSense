import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'home_page.dart';

class NameSplash extends StatelessWidget {
  const NameSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/plantsense_logo_animation_lottie.json'),
        ],
      ),
        nextScreen: const HomePage(),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      splashIconSize: 230,

      animationDuration: Duration(seconds: 6),
    );
  }
}
