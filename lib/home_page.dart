
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'perfil_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final DatabaseReference database = FirebaseDatabase.instance.ref(
    "plants/PLANT_001/last_reading",
  );

  String temp = "--";
  String hum = "--";
  String solo = "--";
  String vpd = "--";

  String status = "--";
  String prioridade = "--";
  String zone = "--";

  String rssi = "--";
  String snr = "--";

  String mlLabel = "--";
  String mlScore = "--";

  String timestamp = "--";

  @override
  void initState() {
    super.initState();
    ouvirDados();
  }

  void ouvirDados() {
    database.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;

      if (data != null) {
        final record = Map<dynamic, dynamic>.from(data as Map);

        setState(() {
          temp = record['temp']?.toString() ?? "--";
          hum = record['hum']?.toString() ?? "--";
          solo = record['solo']?.toString() ?? "--";
          vpd = record['vpd']?.toString() ?? "--";

          status = record['status']?.toString() ?? "--";
          prioridade = record['prioridade']?.toString() ?? "--";
          zone = record['zone']?.toString() ?? "--";

          rssi = record['rssi']?.toString() ?? "--";
          snr = record['snr']?.toString() ?? "--";

          mlLabel = record['ml_label']?.toString() ?? "--";
          mlScore = record['ml_score']?.toString() ?? "--";

          timestamp = record['timestamp']?.toString() ?? "--";
        });
      }
    });
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')),
      );
    }
  }

  Future<void> confirmarLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text("Sair", style: TextStyle(color: Colors.white)),
          content: const Text(
            "Deseja realmente sair?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar",
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
              ),
              child: const Text("Sair", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await logout();
    }
  }

  Widget infoCard(
      String titulo, String valor, IconData icone, Color cor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: cor, size: 32),
          const SizedBox(height: 10),
          Text(titulo,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 5),
          Text(valor,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: cor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

Color getStatusColor() {
  switch (status.toLowerCase()) {
    case "normal":
      return Colors.green;

    case "atencao":
      return Colors.yellow;

    case "stress":
      return Colors.red;

    default:
      return Colors.grey;
  }
}
  Color getPriorityColor() {
    switch (prioridade.toLowerCase()) {
      case "alta":
        return Colors.red;
      case "media":
        return Colors.orange;
      case "baixa":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    double score = (double.tryParse(mlScore) ?? 0) * 100;

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
          FutureBuilder<DataSnapshot>(
            future: FirebaseDatabase.instance
                .ref()
                .child("usuarios")
                .child(FirebaseAuth.instance.currentUser!.uid)
                .child("fotoPerfil")
                .get(),
            builder: (context, snapshot) {
              String url = "";

              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data!.value != null) {
                url = snapshot.data!.value.toString();
              }

              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        url.isNotEmpty ? NetworkImage(url) : null,
                    child: url.isEmpty
                        ? const Icon(Icons.person, color: Colors.black)
                        : null,
                  ),

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
              );
            },
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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          getStatusColor(),
                          getStatusColor().withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.eco,
                            color: Colors.white, size: 60),
                        const SizedBox(height: 10),
                        const Text("PLANT_001",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Chip(
                          label: Text(
                              "Prioridade: ${prioridade.toUpperCase()}"),
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text("IA: $mlLabel",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                        Text(
                          "Confiança: ${score.toStringAsFixed(0)}%",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      infoCard("Temperatura", "$temp °C",
                          Icons.thermostat, Colors.orange),
                      infoCard("Umidade Ar", "$hum %",
                          Icons.water_drop, Colors.blue),
                      infoCard("Umidade Solo", "$solo %",
                          Icons.grass, Colors.green),
                      infoCard("VPD", vpd,
                          Icons.analytics, Colors.purple),
                      infoCard("Zona", zone,
                          Icons.location_on, Colors.cyan),
                      infoCard("RSSI", "$rssi dBm",
                          Icons.wifi, Colors.teal),
                      infoCard("SNR", "$snr dB",
                          Icons.network_check, Colors.lightGreen),
                      infoCard("Status", status,
                          Icons.health_and_safety,
                          getStatusColor()),
                      infoCard("Prioridade", prioridade,
                          Icons.priority_high,
                          getPriorityColor()),
                      infoCard("IA Detectou", mlLabel,
                          Icons.psychology, Colors.amber),
                      infoCard("Confiança IA",
                          "${score.toStringAsFixed(0)}%",
                          Icons.auto_graph,
                          Colors.deepPurple),
                      infoCard("Última Leitura", timestamp,
                          Icons.access_time, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
