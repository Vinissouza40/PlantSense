import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {

  final supabase = Supabase.instance.client;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;
  bool mostrarSenha = false;

  Future<void> cadastrar() async {

    setState(() {
      carregando = true;
    });

    try {

      await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
        data: {
          'nome': nomeController.text.trim()
        }
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Conta criada com sucesso!"),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"),
        ),
      );

    }

    setState(() {
      carregando = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          elevation: 10,

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
                                  "Criar Conta",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E8B57),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                TextField(
                                  controller: nomeController,

                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: Color(0xFF2E8B57),
                                    ),

                                    labelText: "Nome",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],

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

                                const SizedBox(height: 30),

                                SizedBox(
                                  width: double.infinity,

                                  child: ElevatedButton(

                                    onPressed: carregando ? null : cadastrar,

                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E8B57),
                                      padding: const EdgeInsets.symmetric(vertical: 15),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    child: carregando
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Cadastrar",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
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