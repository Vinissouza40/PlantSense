import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'cadastro_page.dart';
import 'home_page.dart';
import 'esqueci_senha_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool mostrarSenha = false;
  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  // ================= LOGIN EMAIL/SENHA =================

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        senhaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha email e senha")));
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      if (userCredential.user != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensagem = "Erro ao fazer login";

      switch (e.code) {
        case 'user-not-found':
          mensagem = "Usuário não encontrado";
          break;

        case 'wrong-password':
          mensagem = "Senha incorreta";
          break;

        case 'invalid-email':
          mensagem = "Email inválido";
          break;

        case 'invalid-credential':
          mensagem = "Email ou senha incorretos";
          break;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  // ================= LOGIN GOOGLE =================

  Future<void> loginComGoogle() async {
    try {
      setState(() {
        carregando = true;
      });

      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          carregando = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao fazer login com Google: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  // ================= NAVEGAÇÃO =================

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPage()),
    );
  }

  void abrirRecuperarSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EsqueciSenhaPage()),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3DBE8B), Color(0xFF2E8B57)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: LayoutBuilder(
          builder: (context, constraints) {
            double largura;

            if (constraints.maxWidth < 600) {
              largura = constraints.maxWidth;
            } else if (constraints.maxWidth < 1000) {
              largura = 450;
            } else {
              largura = 500;
            }

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),

                child: IntrinsicHeight(
                  child: Center(
                    child: SizedBox(
                      width: largura,

                      child: Padding(
                        padding: const EdgeInsets.all(25),

                        child: Card(
                          elevation: 12,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(25),

                            child: Column(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ), // Ajuste o valor como desejar
                                  child: Image.asset(
                                    'assets/Icone.png',
                                    width: 130,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                const SizedBox(height: 5),
                                
                                const Text(
                                  "Login:",
                                  style: TextStyle(
                                    color: Color(0xFF2E8B57),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 30),

                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,

                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.email,
                                      color: Color(0xFF2E8B57),
                                    ),
                                    labelText: "Email",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                TextField(
                                  controller: senhaController,
                                  obscureText: !mostrarSenha,

                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: Color(0xFF2E8B57),
                                    ),

                                    labelText: "Senha",

                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        mostrarSenha
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFF2E8B57),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          mostrarSenha = !mostrarSenha;
                                        });
                                      },
                                    ),

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,

                                  child: ElevatedButton(
                                    onPressed: carregando ? null : login,

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E8B57),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    child:
                                        carregando
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : const Text(
                                              "Entrar",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                SizedBox(
                                  width: double.infinity,
                                  height: 55,

                                  child: OutlinedButton(
                                    onPressed:
                                        carregando ? null : loginComGoogle,

                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,

                                      side: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      children: [
                                        Image.asset(
                                          'assets/google_g.png',
                                          width: 22,
                                          height: 22,
                                        ),

                                        const SizedBox(width: 12),

                                        const Text(
                                          "Entrar com Google",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                TextButton(
                                  onPressed: abrirRecuperarSenha,

                                  child: const Text(
                                    "Esqueceu a senha?",
                                    style: TextStyle(color: Color(0xFF2E8B57)),
                                  ),
                                ),

                                TextButton(
                                  onPressed: abrirCadastro,

                                  child: const Text(
                                    "Criar conta",
                                    style: TextStyle(
                                      color: Color(0xFF2E8B57),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
