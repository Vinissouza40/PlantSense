import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EsqueciSenhaPage extends StatefulWidget {
  const EsqueciSenhaPage({super.key});

  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {
  static const Color _background = Color(0xFF07130F);
  static const Color _panel = Color(0xFF10221B);
  static const Color _green = Color(0xFF52D69A);
  static const Color _muted = Color(0xFF9AAFA5);
  static const Color _border = Color(0xFF294337);

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> recuperarSenha() async {
    if (carregando || !_formKey.currentState!.validate()) return;
    setState(() => carregando = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se o e-mail estiver cadastrado, você receberá um link de recuperação.'),
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final mensagem = switch (e.code) {
        'invalid-email' => 'Informe um e-mail válido.',
        'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
        'network-request-failed' => 'Verifique sua conexão com a internet.',
        _ => 'Não foi possível enviar o e-mail. Tente novamente.',
      };
      _mostrarErro(mensagem);
    } catch (_) {
      if (mounted) _mostrarErro('Ocorreu um erro. Tente novamente.');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: const Color(0xFF913D3D),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recuperar senha',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _panel,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _border, width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22.5),
                              child: Image.asset(
                                'assets/Icone.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.spa_rounded, color: _green, size: 52),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Esqueceu sua senha?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Informe seu e-mail para receber um link e redefinir sua senha.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _muted, height: 1.5, fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: _border),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recuperação de acesso',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Use o e-mail associado à sua conta.',
                                  style: TextStyle(color: _muted, fontSize: 13),
                                ),
                                const SizedBox(height: 22),
                                TextFormField(
                                  controller: emailController,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.email],
                                  onFieldSubmitted: (_) => recuperarSenha(),
                                  decoration: InputDecoration(
                                    labelText: 'E-mail',
                                    labelStyle: const TextStyle(color: _muted),
                                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: _green),
                                    filled: true,
                                    fillColor: _background,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: _border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: _border),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: _green, width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFFF7B79)),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFFFF7B79), width: 1.5),
                                    ),
                                  ),
                                  validator: (valor) {
                                    final email = valor?.trim() ?? '';
                                    if (email.isEmpty) return 'Informe seu e-mail.';
                                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                                      return 'Informe um e-mail válido.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: FilledButton(
                                    onPressed: carregando ? null : recuperarSenha,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _green,
                                      foregroundColor: _background,
                                      disabledBackgroundColor: const Color(0xFF426456),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: carregando
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: _background,
                                            ),
                                          )
                                        : const Text(
                                            'Enviar link de recuperação',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextButton.icon(
                          onPressed: carregando ? null : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Voltar ao login'),
                          style: TextButton.styleFrom(foregroundColor: _green),
                        ),
                      ],
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
