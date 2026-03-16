import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    final nome = user?.userMetadata?['nome'] ?? "Usuário";
    final email = user?.email ?? "Sem email";

    return Scaffold(

      backgroundColor: const Color(0xFF020617),

      appBar: AppBar(
        title: const Text(
          "Perfil",
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: Colors.transparent,
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3DBE8B),
                Color(0xFF2E8B57),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {

          double largura;

          if (constraints.maxWidth < 600) {
            largura = constraints.maxWidth;
          } else if (constraints.maxWidth < 1000) {
            largura = 500;
          } else {
            largura = 600;
          }

          return Center(
            child: SizedBox(
              width: largura,

              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Card(

                  color: const Color(0xFF111827),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  elevation: 10,

                  child: Padding(
                    padding: const EdgeInsets.all(25),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Divider(color: Colors.white24),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            const Icon(
                              Icons.badge,
                              color: Colors.white70,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "ID do usuário:\n${user?.id}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            )

                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}