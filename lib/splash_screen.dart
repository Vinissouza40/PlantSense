import 'package:flutter/material.dart';
import 'home_page.dart';

class NameSplash extends StatefulWidget {
  const NameSplash({super.key});

  @override
  State<NameSplash> createState() => _NameSplashState();
}

class _NameSplashState extends State<NameSplash> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),

      body: LayoutBuilder(
        builder: (context, constraints) {

          double logoSize;

          if (constraints.maxWidth < 600) {
            logoSize = 180;
          } else if (constraints.maxWidth < 1000) {
            logoSize = 250;
          } else {
            logoSize = 300;
          }

          return Center(
            child: Image.asset(
              'assets/plantsense_logo.png',
              width: logoSize,
            ),
          );
        },
      ),
    );
  }
}