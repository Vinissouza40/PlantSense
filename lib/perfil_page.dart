import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  static const Color _bg = Color(0xFF07130F);
  static const Color _panel = Color(0xFF10221B);
  static const Color _green = Color(0xFF52D69A);
  static const Color _muted = Color(0xFF9AAFA5);

  final User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker picker = ImagePicker();

  String nome = 'Carregando...';
  String email = 'Carregando...';
  String fotoUrl = '';
  bool carregando = true;
  bool enviandoFoto = false;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final currentUser = user;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          nome = 'Usuário não autenticado';
          email = '';
          carregando = false;
        });
      }
      return;
    }

    try {
      final ref = FirebaseDatabase.instance.ref('usuarios/${currentUser.uid}');
      final snapshot = await ref.get();
      final dados = snapshot.value is Map
          ? Map<String, dynamic>.from(
              (snapshot.value as Map).map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : <String, dynamic>{};

      String campo(String chave, String alternativa) {
        final valor = dados[chave]?.toString().trim();
        return valor != null && valor.isNotEmpty ? valor : alternativa;
      }

      if (!snapshot.exists) {
        await ref.set({
          'nome': currentUser.displayName ?? 'Usuário',
          'email': currentUser.email ?? '',
          'fotoPerfil': currentUser.photoURL ?? '',
        });
      }

      if (!mounted) return;
      setState(() {
        nome = campo('nome', currentUser.displayName ?? 'Usuário');
        email = campo('email', currentUser.email ?? '');
        fotoUrl = campo('fotoPerfil', currentUser.photoURL ?? '');
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        nome = currentUser.displayName ?? 'Usuário';
        email = currentUser.email ?? '';
        fotoUrl = currentUser.photoURL ?? '';
        carregando = false;
      });
    }
  }

  Future<bool> solicitarPermissaoCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) await openAppSettings();
    return false;
  }

  Future<void> selecionarFoto() async {
    if (enviandoFoto || user == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  'Alterar foto do perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: _green),
                title: const Text('Tirar foto',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  alterarFotoPerfil(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: _green),
                title: const Text('Escolher da galeria',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  alterarFotoPerfil(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> alterarFotoPerfil(ImageSource source) async {
    final currentUser = user;
    if (currentUser == null || enviandoFoto) return;
    try {
      if (source == ImageSource.camera && !await solicitarPermissaoCamera()) {
        return;
      }
      final XFile? imagem = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (imagem == null || !mounted) return;
      setState(() => enviandoFoto = true);

      final caminho = 'perfil/${currentUser.uid}.jpg';
      final storage = Supabase.instance.client.storage.from('imagens');
      await storage.upload(
        caminho,
        File(imagem.path),
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );
      final imageUrl = storage.getPublicUrl(caminho);
      await FirebaseDatabase.instance
          .ref('usuarios/${currentUser.uid}')
          .update({'fotoPerfil': imageUrl});

      // A URL do arquivo é mantida no Firebase, como no código original.
      // Evita exibir a imagem antiga caso o cache retenha a foto anterior.
      await NetworkImage(imageUrl).evict();
      if (!mounted) return;
      setState(() => fotoUrl = imageUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto atualizada com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar foto: $e')),
      );
    } finally {
      if (mounted) setState(() => enviandoFoto = false);
    }
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _green, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 5),
              SelectableText(
                value.isEmpty ? 'Não informado' : value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Meu perfil',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: _green))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Minha conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Gerencie sua foto e consulte seus dados pessoais.',
                          style: TextStyle(color: _muted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        _card(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 26,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _green.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CircleAvatar(
                                          radius: 60,
                                          backgroundColor: _green,
                                          child: CircleAvatar(
                                            radius: 57,
                                            backgroundColor: _panel,
                                            backgroundImage: fotoUrl.isNotEmpty
                                                ? NetworkImage(fotoUrl)
                                                : null,
                                            child: fotoUrl.isEmpty
                                                ? const Icon(
                                                    Icons.person_rounded,
                                                    color: _green,
                                                    size: 65,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -3,
                                          right: -3,
                                          child: Material(
                                            color: _green,
                                            shape: const CircleBorder(),
                                            child: IconButton(
                                              tooltip: 'Alterar foto',
                                              onPressed: enviandoFoto
                                                  ? null
                                                  : selecionarFoto,
                                              icon: const Icon(
                                                Icons.camera_alt_rounded,
                                                color: _bg,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 17),
                                    Text(
                                      nome,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 23,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      email,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      enviandoFoto ? null : selecionarFoto,
                                  icon: enviandoFoto
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _bg,
                                          ),
                                        )
                                      : const Icon(Icons.photo_camera_outlined),
                                  label: Text(enviandoFoto
                                      ? 'Enviando foto...'
                                      : 'Alterar foto de perfil'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _green,
                                    foregroundColor: _bg,
                                    disabledBackgroundColor: _green.withOpacity(0.5),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Informações da conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _card(
                          child: Column(
                            children: [
                              _infoRow(Icons.badge_outlined, 'Nome', nome),
                              const Divider(
                                color: Color(0xFF294136),
                                height: 30,
                              ),
                              _infoRow(Icons.alternate_email, 'E-mail', email),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
