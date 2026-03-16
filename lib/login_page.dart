import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  final supabase = Supabase.instance.client;

  bool mostrarSenha = false;

  Future<void> login() async {

    try {

      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      if (response.user != null) {

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login realizado com sucesso"),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"),
        ),
      );

    }

  }

  void abrirCadastro() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroPage(),
      ),
    );

  }

  void abrirRecuperarSenha() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EsqueciSenhaPage(),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3DBE8B),
              Color(0xFF2E8B57),
            ],
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
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),

                child: IntrinsicHeight(
                  child: Center(

                    child: SizedBox(
                      width: largura,

                      child: Padding(
                        padding: const EdgeInsets.all(25),

                        child: Card(
                          elevation: 10,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(25),

                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Image.asset(
                                  'assets/plantsense_logo.png',
                                  width: 100,
                                ),

                                const SizedBox(height: 15),

                                const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E8B57),
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

                                  child: ElevatedButton(
                                    onPressed: login,

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E8B57),
                                      padding: const EdgeInsets.symmetric(vertical: 15),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    child: const Text(
                                      "Entrar",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                TextButton(
                                  onPressed: abrirRecuperarSenha,
                                  child: const Text(
                                    "Esqueceu a senha?",
                                    style: TextStyle(
                                      color: Color(0xFF2E8B57),
                                    ),
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