import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_page.dart';
import 'login_page.dart';

class AuthCheckPage extends StatelessWidget {
  const AuthCheckPage({super.key});

  @override
  Widget build(BuildContext context) {

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }

  }
}