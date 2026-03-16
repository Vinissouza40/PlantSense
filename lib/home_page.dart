import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'perfil_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final supabase = Supabase.instance.client;

  List dados = [];
  RealtimeChannel? channel;

  Future<void> carregarDados() async {

    final response = await supabase
        .from('sensor_readings')
        .select()
        .order('created_at', ascending: false)
        .limit(20);

    setState(() {
      dados = response;
    });
  }

  void escutarSensores() {

    channel = supabase.channel('sensor_changes');

    channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'sensor_readings',
          callback: (payload) {

            setState(() {

              dados.insert(0, payload.newRecord);

              if (dados.length > 20) {
                dados.removeLast();
              }

            });

          },
        )
        .subscribe();
  }

  Future<void> logout() async {

    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
              ),

              child: const Text(
                "Sair",
                style: TextStyle(color: Colors.white),
              ),
            )

          ],
        );

      },
    );

    if (confirmar == true) {
      logout();
    }
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
    escutarSensores();
  }

  @override
  void dispose() {

    if (channel != null) {
      supabase.removeChannel(channel!);
    }

    super.dispose();
  }

  Color corTemperatura(double temp) {

    if (temp < 20) {
      return Colors.blue;
    } else if (temp < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }

  }

  Widget sensorCard(String titulo, String valor, IconData icon, Color cor) {

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(icon, color: cor, size: 30),

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
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )

        ],
      ),
    );
  }

  Widget graficoTemperatura() {

    List<FlSpot> pontos = [];

    for (int i = 0; i < dados.length; i++) {

      pontos.add(
        FlSpot(
          i.toDouble(),
          (dados[i]['temperatura'] as num).toDouble(),
        ),
      );
    }

    double tempAtual = (dados.first['temperatura'] as num).toDouble();

    return SizedBox(
      height: 250,
      child: LineChart(

        LineChartData(

          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white24,
                strokeWidth: 1,
              );
            },
          ),

          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white),
          ),

          titlesData: FlTitlesData(

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          lineBarsData: [

            LineChartBarData(
              spots: pontos,
              isCurved: true,
              color: corTemperatura(tempAtual),
              barWidth: 4,
              dotData: FlDotData(show: false),
            ),

          ],
        ),

      ),
    );
  }

  Widget graficoUmidade() {

    List<FlSpot> pontos = [];

    for (int i = 0; i < dados.length; i++) {

      pontos.add(
        FlSpot(
          i.toDouble(),
          (dados[i]['umidade'] as num).toDouble(),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: LineChart(

        LineChartData(

          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white24,
                strokeWidth: 1,
              );
            },
          ),

          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white),
          ),

          titlesData: FlTitlesData(

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          lineBarsData: [

            LineChartBarData(
              spots: pontos,
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              dotData: FlDotData(show: false),
            ),

          ],
        ),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (dados.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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

            icon: const Icon(Icons.more_vert, color: Colors.white),

            onSelected: (value) {

              if (value == 'perfil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PerfilPage(),
                  ),
                );
              }

              if (value == 'logout') {
                confirmarLogout();
              }

            },

            itemBuilder: (context) => [

              const PopupMenuItem(
                value: 'perfil',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text("Perfil"),
                  ],
                ),
              ),

              const PopupMenuItem(
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
          )

        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {

          bool celular = constraints.maxWidth < 700;

          if (celular) {

            return Padding(
              padding: const EdgeInsets.all(20),

              child: ListView(
                children: [

                  sensorCard(
                    "Temperatura",
                    "${dados.first['temperatura']} °C",
                    Icons.thermostat,
                    corTemperatura((dados.first['temperatura'] as num).toDouble()),
                  ),

                  const SizedBox(height: 20),

                  graficoTemperatura(),

                  const SizedBox(height: 30),

                  sensorCard(
                    "Umidade",
                    "${dados.first['umidade']} %",
                    Icons.water_drop,
                    Colors.blue,
                  ),

                  const SizedBox(height: 20),

                  graficoUmidade(),

                ],
              ),
            );

          } else {

            return Padding(
              padding: const EdgeInsets.all(20),

              child: Row(
                children: [

                  Expanded(
                    child: Column(
                      children: [

                        sensorCard(
                          "Temperatura",
                          "${dados.first['temperatura']} °C",
                          Icons.thermostat,
                          corTemperatura((dados.first['temperatura'] as num).toDouble()),
                        ),

                        const SizedBox(height: 20),

                        graficoTemperatura(),

                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      children: [

                        sensorCard(
                          "Umidade",
                          "${dados.first['umidade']} %",
                          Icons.water_drop,
                          Colors.blue,
                        ),

                        const SizedBox(height: 20),

                        graficoUmidade(),

                      ],
                    ),
                  ),

                ],
              ),
            );

          }

        },
      ),

    );
  }
}