import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EsqueciSenhaPage extends StatefulWidget {
  const EsqueciSenhaPage({super.key});

  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {

  final supabase = Supabase.instance.client;

  final emailController = TextEditingController();

  bool carregando = false;

  Future<void> recuperarSenha() async {

    setState(() {
      carregando = true;
    });

    try {

      await supabase.auth.resetPasswordForEmail(
        emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email de recuperação enviado!"),
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
                                  "Recuperar Senha",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E8B57),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  "Digite seu email para receber o link de recuperação de senha.",
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 25),

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

                                const SizedBox(height: 30),

                                SizedBox(
                                  width: double.infinity,

                                  child: ElevatedButton(

                                    onPressed: carregando ? null : recuperarSenha,

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
                                            "Enviar Email",
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