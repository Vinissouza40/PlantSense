import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

import 'perfil_page.dart';
import 'login_page.dart';
import 'mapa_sensores_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _Reading {
  final DateTime receivedAt;
  final double? temperature, humidity, soil, vpd;
  final String timestamp;
  const _Reading(this.receivedAt, this.temperature, this.humidity,
      this.soil, this.vpd, this.timestamp);
}

class _HomePageState extends State<HomePage> {
  static const _bg = Color(0xFF07130F);
  static const _panel = Color(0xFF10221B);
  static const _green = Color(0xFF52D69A);
  static const _muted = Color(0xFF9AAFA5);

  final DatabaseReference database =
      FirebaseDatabase.instance.ref('plants/PLANT_001/last_reading');
  StreamSubscription<DatabaseEvent>? _subscription;
  final List<_Reading> _history = [];
  String temp = '--', hum = '--', solo = '--', vpd = '--';
  String status = '--', prioridade = '--', zone = '--';
  String rssi = '--', snr = '--', mlLabel = '--', mlScore = '--';
  String timestamp = '--';
  Map<String, dynamic> _rawReading = {};

  String _field(String key) => _rawReading[key]?.toString() ?? '--';
  String _unitField(String key, String unit) => _displayValue(_field(key), unit);
  String? _lastReadingKey;
  DateTime? _ultimaAtualizacao;
  Timer? _relogioAtualizacao;
  bool _connected = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _relogioAtualizacao = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _ultimaAtualizacao != null) setState(() {});
    });
    _subscription = database.onValue.listen((event) {
      if (!mounted) return;
      final raw = event.snapshot.value;
      if (raw is! Map) {
        setState(() { _connected = false; _error = 'Nenhuma leitura disponível'; });
        return;
      }
      final record = Map<String, dynamic>.from(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
      String value(String key) => record[key]?.toString() ?? '--';
      final readingKey = record.toString();
      setState(() {
        _rawReading = record;
        _connected = true;
        _error = null;
        temp = value('temp');
        hum = value('hum');
        solo = value('solo');
        vpd = value('vpd');
        status = value('status');
        prioridade = value('prioridade');
        zone = value('zone');
        rssi = value('rssi');
        snr = value('snr');
        mlLabel = value('ml_label');
        mlScore = value('ml_score');
        timestamp = value('timestamp');
        if (_lastReadingKey != readingKey) {
          _lastReadingKey = readingKey;
          _ultimaAtualizacao = DateTime.now();
          _history.add(_Reading(DateTime.now(), _number(temp), _number(hum),
              _number(solo), _number(vpd), timestamp));
          if (_history.length > 60) _history.removeAt(0);
        }
      });
    }, onError: (Object error) {
      if (mounted) setState(() { _connected = false; _error = 'Falha ao receber leituras'; });
    });
  }

  static double? _number(String value) =>
      double.tryParse(value.replaceAll(',', '.'));

  @override
  void dispose() {
    _subscription?.cancel();
    _relogioAtualizacao?.cancel();
    super.dispose();
  }

  String get _tempoAtualizacao {
    final ultima = _ultimaAtualizacao;
    if (ultima == null) return 'Aguardando primeira leitura';
    final diferenca = DateTime.now().difference(ultima);
    if (diferenca.inSeconds < 60) return 'Atualizado há ${diferenca.inSeconds.clamp(0, 59)} s';
    if (diferenca.inMinutes < 60) {
      final n = diferenca.inMinutes;
      return 'Atualizado há $n ${n == 1 ? 'minuto' : 'minutos'}';
    }
    if (diferenca.inHours < 24) {
      final n = diferenca.inHours;
      return 'Atualizado há $n ${n == 1 ? 'hora' : 'horas'}';
    }
    final n = diferenca.inDays;
    return 'Atualizado há $n ${n == 1 ? 'dia' : 'dias'}';
  }

  Color get _statusColor {
    if (!_connected) return _muted;
    final text = status.toLowerCase().trim();
    if (text.contains('encharc') || text.contains('anomalia') || text.contains('anôm') || text.contains('stress') || text.contains('estress') ||
        text.contains('crít') || text.contains('crit') ||
        text.contains('seca')) {
      return const Color(0xFFFF7474);
    }
    if (text.contains('aten') || text.contains('alert')) {
      return const Color(0xFFF4C56A);
    }
    if (text == 'normal' || text.contains('saud') || text.contains('estável')) {
      return _green;
    }
    if (prioridade.toLowerCase() == 'alta') return const Color(0xFFFF7474);
    if (prioridade.toLowerCase() == 'media' || prioridade.toLowerCase() == 'média') return const Color(0xFFF4C56A);
    return _muted;
  }

  Color get _priorityColor {
    switch (prioridade.toLowerCase()) {
      case 'alta': return const Color(0xFFFF7B79);
      case 'media': case 'média': return const Color(0xFFF4C56A);
      case 'baixa': return _green;
      default: return _muted;
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')));
    }
  }

  Future<void> _confirmLogout() async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (dialogContext) => Dialog(
      backgroundColor: const Color(0xFF10221B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(
          color: Color(0xFF294337),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF52D69A)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFF52D69A),
                size: 30,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Sair do PlantSense?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Deseja realmente encerrar sua sessão? '
              'Você precisará entrar novamente para '
              'acompanhar suas plantas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9AAFA5),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      side: const BorderSide(
                        color: Color(0xFF294337),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF52D69A),
                      foregroundColor: const Color(0xFF07130F),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (!mounted) return;

  if (confirmed == true) {
    await _logout();
  }
}

  Widget _panelCard({required Widget child, EdgeInsetsGeometry? padding}) =>
      Container(
        padding: padding ?? const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: child,
      );

  Widget _metric(String label, String value, String unit, IconData icon,
      Color color) {
    return _panelCard(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 7),
          Expanded(child: Text(label, style: const TextStyle(
            color: _muted, fontSize: 12), maxLines: 2)),
        ]),
        const SizedBox(height: 14),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text('$value${value == '--' ? '' : ' $unit'}',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800,
              color: Colors.white))),
      ],
    ));
  }

  Widget _sectionTitle(String title, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18,
          fontWeight: FontWeight.w800, color: Colors.white)),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    ]),
  );

  Widget _chart(String title, Color color, double? Function(_Reading) selector,
      String unit) {
    final points = <FlSpot>[];
    for (var i = 0; i < _history.length; i++) {
      final y = selector(_history[i]);
      if (y != null && y.isFinite) points.add(FlSpot(i.toDouble(), y));
    }
    return _panelCard(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(
              color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(
              fontWeight: FontWeight.w700, color: Colors.white))),
          Text(unit, style: const TextStyle(color: _muted, fontSize: 12)),
        ]),
        const SizedBox(height: 20),
        SizedBox(height: 145, child: points.length < 2
            ? const Center(child: Text('Aguardando novas leituras para o gráfico',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 12)))
            : LineChart(LineChartData(
                minX: 0,
                maxX: (_history.length - 1).toDouble(),
                gridData: FlGridData(show: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.06),
                      strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 37))),
                lineBarsData: [LineChartBarData(
                  spots: points,
                  isCurved: true,
                  color: color,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true,
                    color: color.withValues(alpha: 0.10)),
                )],
              ))),
      ],
    ));
  }

  Widget _detail(String label, String value, {Color color = Colors.white}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(color: _muted))),
          Flexible(child: Text(value, textAlign: TextAlign.right,
              style: TextStyle(color: color, fontWeight: FontWeight.w700))),
        ]));

  String _displayValue(String value, String unit) =>
      value == '--' || value.trim().isEmpty ? '--' : '$value $unit';

  String get _recommendation {
    if (!_connected) {
      return 'Aguardando dados do Firebase. Verifique a conexão e se o sensor está enviando leituras.';
    }
    final condition = '${status.toLowerCase()} ${mlLabel.toLowerCase()}';
    final priority = prioridade.toLowerCase();
    if (condition.contains('encharc') || condition.contains('excesso de água')) {
      return 'Suspender a irrigação e conferir a drenagem.';
    }
    if (condition.contains('hídr') || condition.contains('hidri') ||
        condition.contains('seca') || condition.contains('dry')) {
      return 'Possível estresse hídrico: confira a umidade do solo e a necessidade de irrigação antes de regar. Considere as necessidades da espécie.';
    }
    if (condition.contains('anomalia bioelétrica') || condition.contains('anomalia bioeletrica')) {
      return 'Foi identificada uma anomalia bioelétrica. Verifique a estabilidade das leituras, a conexão dos eletrodos e as condições ambientais. Compare novas amostras antes de concluir que há um problema na planta.';
    }
    if (condition.contains('stress') || condition.contains('estress') ||
        condition.contains('crít') || condition.contains('crit') ||
        priority == 'alta') {
      return 'Atenção prioritária: confira as leituras de temperatura, umidade do ar, solo e VPD. Inspecione a planta antes de realizar intervenções.';
    }
    if (condition.contains('aten') || condition.contains('alert') ||
        priority == 'media' || priority == 'média') {
      return 'Alguns indicadores merecem acompanhamento. Compare as próximas leituras e verifique possíveis mudanças no ambiente.';
    }
    if (condition.contains('normal') || priority == 'baixa') {
      return 'Os dados recebidos indicam condição estável. Continue monitorando e mantenha os cuidados adequados à espécie.';
    }
    return 'Acompanhe as próximas leituras e confira os sensores. Ainda não há dados suficientes para uma sugestão específica.';
  }

  Widget _dataGroup(String title, IconData icon, List<Widget> rows) =>
      _panelCard(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: _green, size: 21),
            const SizedBox(width: 9),
            Expanded(child: Text(title,
                style: const TextStyle(color: Colors.white,
                    fontSize: 16, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 10),
          ...rows,
        ],
      ));

  Widget _technicalCard() => _dataGroup(
    'Dispositivo e experimento', Icons.memory_outlined, [
      _detail('Dispositivo (device_id)', _field('device_id')),
      _detail('Gateway (gateway_id)', _field('gateway_id')),
      _detail('Experimento', _field('experimento')),
      _detail('Zona (zone)', _field('zone')),
      _detail('Boot ID', _field('boot_id')),
      _detail('Reiniciou', _field('reiniciou')),
      _detail('Tempo ligado (uptime_ms)', _unitField('uptime_ms', 'ms')),
      _detail('Motivo TX (tx_reason)', _field('tx_reason')),
      _detail('Pacote (pkt)', _field('pkt')),
      _detail('Campo e', _field('e')),
      _detail('Última leitura', _field('timestamp')),
    ],
  );

  Widget _bioCard() => _dataGroup(
    'Sinal bioelétrico', Icons.monitor_heart_outlined, [
      _detail('Média (bio_avg)', _field('bio_avg')),
      _detail('Desvio padrão (bio_std)', _field('bio_std')),
      _detail('Tendência (bio_trend)', _field('bio_trend')),
      _detail('BL', _field('bl')),
      _detail('Referência (v_ref)', _unitField('v_ref', 'V')),
    ],
  );

  Widget _networkCard() => _dataGroup(
    'Conectividade', Icons.wifi_tethering_outlined, [
      _detail('RSSI', _unitField('rssi', 'dBm')),
      _detail('SNR', _unitField('snr', 'dB')),
      _detail('Qualidade do sinal', _field('qualidade_sinal')),
      _detail('Taxa de entrega', _unitField('taxa_entrega', '%')),
      _detail('Pacotes perdidos', _field('pacotes_perdidos')),
    ],
  );

  Widget _environmentCard() => _dataGroup(
    'Detalhes ambientais e energia', Icons.thermostat_outlined, [
      _detail('Temperatura', _unitField('temp', '°C')),
      _detail('Umidade do ar', _unitField('hum', '%')),
      _detail('Solo (solo)', _unitField('solo', '%')),
      _detail('Solo relativo (solo_rel)', _unitField('solo_rel', '%')),
      _detail('VPD', _unitField('vpd', 'kPa')),
      _detail('Tensão da bateria', _unitField('v_bat', 'V')),
    ],
  );

  Widget _aiCard(String confidencePercent) => _dataGroup(
    'Análise da inteligência artificial', Icons.psychology_outlined, [
      _detail('Classe (ml_class)', _field('ml_class')),
      _detail('Diagnóstico (ml_label)', _field('ml_label')),
      _detail('Score bruto (ml_score)', _field('ml_score')),
      _detail('Confiança da IA', confidencePercent),
      _detail('Número de amostras', _field('n_amostras')),
      _detail('Status', status, color: _statusColor),
      _detail('Prioridade', prioridade, color: _priorityColor),
    ],
  );


  @override
  Widget build(BuildContext context) {
    final confidence = _number(mlScore);
    final confidencePercent = confidence == null ? '--' :
        '${(confidence <= 1 ? confidence * 100 : confidence).clamp(0, 100).toStringAsFixed(0)}%';
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 600 ? 2 : width < 1000 ? 3 : 4;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.spa_rounded, color: _green),
          SizedBox(width: 8),
          Text('PlantSense', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(tooltip: 'Mapa dos sensores',
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MapaSensoresScreen())),
            icon: const Icon(Icons.map_outlined)),
          StreamBuilder<DatabaseEvent>(
            stream: FirebaseAuth.instance.currentUser == null
                ? null
                : FirebaseDatabase.instance
                    .ref('usuarios/${FirebaseAuth.instance.currentUser!.uid}/fotoPerfil')
                    .onValue,
            builder: (context, snapshot) {
              final url = snapshot.data?.snapshot.value?.toString().trim() ?? '';
              return Padding(
                padding: const EdgeInsets.only(left: 4, right: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilPage()),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: _panel,
                    backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
                    child: url.isEmpty
                        ? const Icon(Icons.person_outline, color: _green)
                        : null,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: (value) {
              if (value == 'perfil') Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilPage()));
              if (value == 'logout') _confirmLogout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'perfil', child: Text('Meu perfil')),
              PopupMenuItem(value: 'logout', child: Text('Sair')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1150),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Visão geral', style: TextStyle(fontSize: 27,
                color: Colors.white, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('Monitoramento da planta PLANT_001 em tempo real',
                style: TextStyle(color: _muted)),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Situação agora', style: TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border(left: BorderSide(color: _statusColor, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 9, runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.circle, color: _statusColor, size: 13),
                            Text(
                              _connected
                                  ? (mlLabel.trim().isNotEmpty && mlLabel != '--' ? mlLabel : status)
                                  : (_error ?? 'Conectando...'),
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 21, fontWeight: FontWeight.w800),
                            ),
                            if (prioridade != '--' && prioridade.trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _priorityColor.withValues(alpha: 0.55)),
                                ),
                                child: Text('PRIORIDADE ${prioridade.toUpperCase()}',
                                  style: TextStyle(color: _priorityColor,
                                    fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text.rich(TextSpan(children: [
                          const TextSpan(text: 'Sugestão: ', style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.white)),
                          TextSpan(text: _recommendation,
                            style: const TextStyle(color: Colors.white)),
                        ]), style: const TextStyle(fontSize: 14, height: 1.5)),
                        const SizedBox(height: 11),
                        Wrap(spacing: 6, runSpacing: 4, children: [
                          Text('Confiança do modelo: ${confidence == null ? '--' : confidencePercent}',
                            style: const TextStyle(color: _muted, fontSize: 12)),
                          const Text('·', style: TextStyle(color: _muted)),
                          Text(_tempoAtualizacao.toLowerCase(),
                            style: const TextStyle(color: _muted, fontSize: 12)),
                          const Text('·', style: TextStyle(color: _muted)),
                          const Text('PLANT_001', style: TextStyle(color: _muted, fontSize: 12)),
                        ]),
                        const SizedBox(height: 7),
                        const Text('Classificação experimental do modelo de IA, não é diagnóstico agronômico.',
                          style: TextStyle(color: _muted, fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, runSpacing: 6, children: [
                    if (_field('v_bat') != '--') Text('Bateria: ${_unitField('v_bat', 'V')}',
                      style: const TextStyle(color: _muted, fontSize: 12)),
                    if (_field('qualidade_sinal') != '--') Text('Sinal: ${_field('qualidade_sinal')}',
                      style: const TextStyle(color: _muted, fontSize: 12)),
                    if (_field('taxa_entrega') != '--') Text('Entrega de pacotes: ${_unitField('taxa_entrega', '%')}',
                      style: const TextStyle(color: _muted, fontSize: 12)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 23),
            _sectionTitle('Indicadores ambientais',
                subtitle: 'Valores da última leitura recebida do Firebase'),
            GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: width < 600 ? 1.35 : 1.65,
              children: [
                _metric('Temperatura', temp, '°C', Icons.thermostat_outlined,
                    const Color(0xFFFFB16A)),
                _metric('Umidade do ar', hum, '%', Icons.water_drop_outlined,
                    const Color(0xFF73C5F5)),
                _metric('Umidade do solo', solo, '%', Icons.grass_outlined, _green),
                _metric('VPD', vpd, 'kPa', Icons.air_outlined,
                    const Color(0xFFBBA3FF)),
              ],
            ),
            const SizedBox(height: 23),
            _sectionTitle('Evolução das leituras',
              subtitle: 'Dados capturados desde que esta tela foi aberta'),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final charts = [
                _chart('Temperatura', const Color(0xFFFFB16A),
                    (r) => r.temperature, '°C'),
                _chart('Umidade do ar', const Color(0xFF73C5F5),
                    (r) => r.humidity, '%'),
                _chart('Umidade do solo', _green, (r) => r.soil, '%'),
                _chart('VPD', const Color(0xFFBBA3FF), (r) => r.vpd, 'kPa'),
              ];
              if (!wide) return Column(children: [
                for (final chart in charts) ...[chart, const SizedBox(height: 12)],
              ]);
              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: charts,
              );
            }),
            const SizedBox(height: 23),
            _sectionTitle('Informações completas',
                subtitle: 'Todos os campos recebidos do Firebase'),
            _aiCard(confidencePercent),
            const SizedBox(height: 12),
            _bioCard(),
            const SizedBox(height: 12),
            _networkCard(),
            const SizedBox(height: 12),
            _environmentCard(),
            const SizedBox(height: 12),
            _technicalCard(),
            const SizedBox(height: 20),
          ],
        ))),
      )),
    );
  }
}
