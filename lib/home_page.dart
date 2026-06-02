import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'perfil_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // ================= FIREBASE =================

  final DatabaseReference database =
      FirebaseDatabase.instance.ref("sensor");

  // ================= VARIÁVEIS =================

  String temperatura = "--";
  String umidade = "--";
  String timestamp = "--";
  String deviceId = "--";

  // ================= INIT =================

  @override
  void initState() {
    super.initState();

    ouvirDados();
  }

  // ================= OUVIR FIREBASE =================

  void ouvirDados() {

    database.onValue.listen((DatabaseEvent event) {

      final data = event.snapshot.value;

      if (data != null) {

        final record =
            Map<dynamic, dynamic>.from(data as Map);

        setState(() {

          temperatura =
              record['temperatura']?.toString() ?? "--";

          umidade =
              record['umidade']?.toString() ?? "--";

          deviceId =
              record['dispositivo']?.toString() ?? "--";

          timestamp =
              record['atualizacao']?.toString() ?? "--";
        });
      }
    });
  }

  // ================= LOGOUT =================

  Future<void> logout() async {

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> confirmarLogout() async {

    final confirmar = await showDialog<bool>(

      context: context,

      builder: (context) {

        return AlertDialog(

          backgroundColor: const Color(0xFF111827),

          title: const Text(
            "Sair",
            style: TextStyle(color: Colors.white),
          ),

          content: const Text(
            "Tem certeza que deseja sair?",
            style: TextStyle(color: Colors.white70),
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            ElevatedButton(

              onPressed: () => Navigator.pop(context, true),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
              ),

              child: const Text("Sair"),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      logout();
    }
  }

  // ================= CARD =================

  Widget card(
    String titulo,
    String valor,
    IconData icon,
    Color cor,
  ) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: cor,
            size: 30,
          ),

          const SizedBox(height: 10),

          Text(
            titulo,
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 5),

          Text(
            valor,

            style: TextStyle(
              color: cor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF020617),

      appBar: AppBar(

        title: const Text(
          "PlantSense 🌱",
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,

        flexibleSpace: Container(

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3DBE8B),
                Color(0xFF2E8B57),
              ],
            ),
          ),
        ),

        actions: [

          PopupMenuButton<String>(

            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),

            onSelected: (value) {

              if (value == 'perfil') {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PerfilPage(),
                  ),
                );
              }

              if (value == 'logout') {
                confirmarLogout();
              }
            },

            itemBuilder: (_) => const [

              PopupMenuItem(

                value: 'perfil',

                child: Row(
                  children: [

                    Icon(Icons.person),

                    SizedBox(width: 10),

                    Text("Perfil"),
                  ],
                ),
              ),

              PopupMenuItem(

                value: 'logout',

                child: Row(
                  children: [

                    Icon(Icons.logout),

                    SizedBox(width: 10),

                    Text("Sair"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: LayoutBuilder(

        builder: (context, constraints) {

          int crossAxisCount;

          if (constraints.maxWidth < 600) {
            crossAxisCount = 2;
          } else if (constraints.maxWidth < 1000) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 4;
          }

          return Padding(

            padding: const EdgeInsets.all(16),

            child: GridView.count(

              crossAxisCount: crossAxisCount,

              crossAxisSpacing: 15,
              mainAxisSpacing: 15,

              children: [

                card(
                  "Temperatura",
                  "$temperatura °C",
                  Icons.thermostat,
                  Colors.orange,
                ),

                card(
                  "Umidade",
                  umidade,
                  Icons.water_drop,
                  Colors.blue,
                ),

                card(
                  "Dispositivo",
                  deviceId,
                  Icons.memory,
                  Colors.green,
                ),

                Container(

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Center(

                    child: Column(

                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        const Icon(
                          Icons.access_time,
                          color: Colors.white54,
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Última atualização",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 5),

                        Text(
                          timestamp,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),

                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}