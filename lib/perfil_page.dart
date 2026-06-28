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
  String fotoUrl = "";

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    if (user == null) {
      setState(() {
        carregando = false;
      });
      return;
    }

    try {
      final snapshot =
          await FirebaseDatabase.instance.ref("usuarios/${user!.uid}").get();

      if (snapshot.exists && snapshot.value != null) {
        final dados = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          nome = dados["nome"]?.toString().isNotEmpty == true
              ? dados["nome"].toString()
              : (user!.displayName ?? "Usuário");

          email = dados["email"]?.toString().isNotEmpty == true
              ? dados["email"].toString()
              : (user!.email ?? "");

          fotoUrl = dados["fotoPerfil"]?.toString().isNotEmpty == true
              ? dados["fotoPerfil"].toString()
              : (user!.photoURL ?? "");

          carregando = false;
        });
      } else {
        setState(() {
          nome = user!.displayName ?? "Usuário";
          email = user!.email ?? "";
          fotoUrl = user!.photoURL ?? "";
          carregando = false;
        });

        await FirebaseDatabase.instance.ref("usuarios/${user!.uid}").set({
          "nome": user!.displayName ?? "Usuário",
          "email": user!.email ?? "",
          "fotoPerfil": user!.photoURL ?? "",
        });
      }
    } catch (e) {
      setState(() {
        nome = user!.displayName ?? "Usuário";
        email = user!.email ?? "";
        fotoUrl = user!.photoURL ?? "";
        carregando = false;
      });
    }
  }

  Future<bool> solicitarPermissaoCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
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
                title: const Text(
                  "Tirar Foto",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  alterarFotoPerfil(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  "Escolher da Galeria",
                  style: TextStyle(color: Colors.white),
                ),
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
      if (source == ImageSource.camera) {
        final permitido = await solicitarPermissaoCamera();

        if (!permitido) return;
      }

      final XFile? imagem = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (imagem == null) return;

      final file = File(imagem.path);
      final caminho = "perfil/${user!.uid}.jpg";

      await Supabase.instance.client.storage.from("imagens").upload(
            caminho,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl =
          Supabase.instance.client.storage.from("imagens").getPublicUrl(caminho);

      await FirebaseDatabase.instance.ref("usuarios/${user!.uid}").update({
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
                              backgroundImage:
                                  fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                              child: fotoUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
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
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          nome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
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