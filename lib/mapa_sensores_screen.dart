import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapaSensoresScreen extends StatefulWidget {
  const MapaSensoresScreen({super.key});

  @override
  State<MapaSensoresScreen> createState() => _MapaSensoresScreenState();
}

class _MapaSensoresScreenState extends State<MapaSensoresScreen> {
  static const Color _background = Color(0xFF07130F);
  static const Color _panel = Color(0xFF10221B);
  static const Color _green = Color(0xFF52D69A);
  static const Color _muted = Color(0xFF9AAFA5);

  final MapController _mapController = MapController();
  LatLng? _minhaLocalizacao;
  bool _carregando = true;
  String? _erro;
  bool _permissaoBloqueada = false;

  @override
  void initState() {
    super.initState();
    _obterLocalizacao();
  }

  Future<void> _obterLocalizacao() async {
    if (!mounted) return;
    setState(() {
      _carregando = true;
      _erro = null;
      _permissaoBloqueada = false;
    });

    try {
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        _mostrarErro('Ative a localização do celular e tente novamente.');
        return;
      }

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.deniedForever) {
        _mostrarErro(
          'A permissão de localização está bloqueada. Libere o acesso nas configurações do aplicativo.',
          bloqueada: true,
        );
        return;
      }
      if (permissao == LocationPermission.denied) {
        _mostrarErro('Permissão de localização negada. Tente novamente.');
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _minhaLocalizacao = LatLng(posicao.latitude, posicao.longitude);
        _carregando = false;
        _erro = null;
      });
    } catch (e) {
      _mostrarErro('Não foi possível obter a localização. Verifique o GPS e a conexão e tente novamente.');
    }
  }

  void _mostrarErro(String mensagem, {bool bloqueada = false}) {
    if (!mounted) return;
    setState(() {
      _erro = mensagem;
      _permissaoBloqueada = bloqueada;
      _carregando = false;
    });
  }

  void _centralizarMapa() {
    final posicao = _minhaLocalizacao;
    if (posicao == null) return;
    _mapController.move(posicao, 18);
  }

  Widget _cartao({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: child,
    );
  }

  Widget _estadoLocalizacao() {
    if (_carregando) {
      return _cartao(
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _green),
            SizedBox(height: 18),
            Text('Buscando sua localização...',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 6),
            Text('Aguarde enquanto consultamos o GPS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted)),
          ],
        ),
      );
    }

    return _cartao(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off_outlined,
              color: Color(0xFFFFB16A), size: 42),
          const SizedBox(height: 14),
          const Text('Localização indisponível',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(_erro ?? 'Não foi possível carregar o mapa.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted)),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: _background,
            ),
            onPressed: _permissaoBloqueada
                ? () async { await Geolocator.openAppSettings(); }
                : _obterLocalizacao,
            icon: Icon(_permissaoBloqueada
                ? Icons.settings_outlined
                : Icons.refresh_rounded),
            label: Text(_permissaoBloqueada
                ? 'Abrir configurações'
                : 'Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _mapa() {
    final posicao = _minhaLocalizacao!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: posicao,
          initialZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.plant_sense',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: posicao,
                width: 72,
                height: 72,
                child: const Icon(
                  Icons.location_pin,
                  color: Color(0xFFEF5350),
                  size: 56,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 10)],
                ),
              ),
            ],
          ),
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posicao = _minhaLocalizacao;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, color: _green),
            SizedBox(width: 10),
            Text('Mapa dos Sensores',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar localização',
            onPressed: _carregando ? null : _obterLocalizacao,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Localização em tempo real',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      )),
                  const SizedBox(height: 5),
                  const Text(
                    'Visualize sua posição no mapa e consulte as coordenadas GPS.',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: posicao == null || _carregando || _erro != null
                        ? Center(child: _estadoLocalizacao())
                        : Stack(
                            children: [
                              Positioned.fill(child: _mapa()),
                              Positioned(
                                right: 14,
                                top: 14,
                                child: Material(
                                  color: _panel,
                                  borderRadius: BorderRadius.circular(14),
                                  child: IconButton(
                                    tooltip: 'Centralizar no GPS',
                                    onPressed: _centralizarMapa,
                                    icon: const Icon(Icons.my_location_rounded,
                                        color: _green),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (posicao != null && !_carregando && _erro == null) ...[
                    const SizedBox(height: 14),
                    _cartao(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: _green),
                              SizedBox(width: 8),
                              Text('Sua localização',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Latitude: ${posicao.latitude.toStringAsFixed(6)}',
                              style: const TextStyle(color: _muted)),
                          const SizedBox(height: 5),
                          Text('Longitude: ${posicao.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(color: _muted)),
                          const SizedBox(height: 9),
                          const Text(
                            'O marcador vermelho indica a posição do celular.',
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
