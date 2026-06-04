
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final user = FirebaseAuth.instance.currentUser;
  final ImagePicker picker = ImagePicker();

  String nome = "Carregando...";
  String email = "Carregando...";
  String telefone = "--";
  String fotoUrl = "";

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    if (user == null) return;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child("usuarios")
          .child(user!.uid)
          .get();

      if (snapshot.exists) {
        final dados = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          nome = dados["nome"] ?? "Usuário";
          email = dados["email"] ?? user!.email ?? "";
          telefone = dados["telefone"] ?? "--";
          fotoUrl = dados["fotoPerfil"] ?? "";
          carregando = false;
        });
      } else {
        setState(() {
          nome = user!.displayName ?? "Usuário";
          email = user!.email ?? "";
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        carregando = false;
      });
    }
  }

  // ✅ PERMISSÃO DA CÂMERA
  Future<bool> solicitarPermissaoCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  // ✅ PERMISSÃO DA GALERIA (CORRIGIDO)
  Future<bool> solicitarPermissaoGaleria() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();

      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }

      return false;
    } else {
      final status = await Permission.photos.request();

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }

      return false;
    }
  }

  Future<void> selecionarFoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text("Tirar Foto",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  alterarFotoPerfil(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text("Escolher da Galeria",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  alterarFotoPerfil(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> alterarFotoPerfil(ImageSource source) async {
    try {
      bool permitido = false;

      if (source == ImageSource.camera) {
        permitido = await solicitarPermissaoCamera();
      } else {
        permitido = await solicitarPermissaoGaleria();
      }

      if (!permitido) {
        print("Permissão negada");
        return;
      }

      final XFile? imagem = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      print("Imagem selecionada: ${imagem?.path}");

      if (imagem == null) return;

      final file = File(imagem.path);

      final caminho = "perfil/${user!.uid}.jpg";

      await Supabase.instance.client.storage.from("imagens").upload(
            caminho,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = Supabase.instance.client.storage
          .from("imagens")
          .getPublicUrl(caminho);

      await FirebaseDatabase.instance
          .ref()
          .child("usuarios")
          .child(user!.uid)
          .update({
        "fotoPerfil": imageUrl,
      });

      setState(() {
        fotoUrl = imageUrl;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto atualizada com sucesso!")),
      );
    } catch (e) {
      print("ERRO: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar foto: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text("Perfil", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3DBE8B), Color(0xFF2E8B57)],
            ),
          ),
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: const Color(0xFF2E8B57),
                              backgroundImage: fotoUrl.isNotEmpty
                                  ? NetworkImage(fotoUrl)
                                  : null,
                              child: fotoUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 60, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: selecionarFoto,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(nome,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 25),
                        const Divider(color: Colors.white24),
                        ListTile(
                          leading:
                              const Icon(Icons.phone, color: Colors.green),
                          title: const Text("Telefone",
                              style: TextStyle(color: Colors.white70)),
                          subtitle: Text(telefone,
                              style: const TextStyle(color: Colors.white)),
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
