import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  static const Color _background = Color(0xFF07130F);
  static const Color _panel = Color(0xFF10221B);
  static const Color _green = Color(0xFF52D69A);
  static const Color _muted = Color(0xFF9AAFA5);

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool carregando = false;
  bool mostrarSenha = false;

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> cadastrar() async {
    if (carregando || !_formKey.currentState!.validate()) return;

    setState(() => carregando = true);
    try {
      final nome = nomeController.text.trim();
      final email = emailController.text.trim();
      final senha = senhaController.text;

      final credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);
      final usuario = credencial.user;

      if (usuario == null) {
        throw StateError('Não foi possível obter o usuário criado.');
      }

      await FirebaseDatabase.instance.ref('usuarios/${usuario.uid}').set({
        'nome': nome,
        'email': email,
        'criadoEm': DateTime.now().toIso8601String(),
      });
      await usuario.updateDisplayName(nome);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      final mensagem = switch (e.code) {
        'email-already-in-use' => 'Este e-mail já está cadastrado.',
        'weak-password' => 'Escolha uma senha mais forte.',
        'invalid-email' => 'Informe um e-mail válido.',
        _ => e.message ?? 'Não foi possível criar a conta.',
      };
      if (mounted) _mostrarErro(mensagem);
    } catch (e) {
      if (mounted) _mostrarErro('Não foi possível concluir o cadastro: $e');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: const Color(0xFF913D3D)),
    );
  }

  InputDecoration _decoracao(String titulo, IconData icone, {Widget? sufixo}) {
    return InputDecoration(
      labelText: titulo,
      labelStyle: const TextStyle(color: _muted),
      prefixIcon: Icon(icone, color: _green),
      suffixIcon: sufixo,
      filled: true,
      fillColor: _background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF294337)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF294337)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Criar conta', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF294337),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22.5),
                        child: Image.asset(
                          'assets/Icone.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.spa_rounded,
                            color: _green,
                            size: 52,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Comece com o PlantSense',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie sua conta para acompanhar suas plantas e os dados dos sensores.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF294337)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dados da conta',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          const Text('Preencha as informações abaixo.',
                              style: TextStyle(color: _muted, fontSize: 13)),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: nomeController,
                            style: const TextStyle(color: Colors.white),
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            textInputAction: TextInputAction.next,
                            decoration: _decoracao('Nome completo', Icons.person_outline_rounded),
                            validator: (valor) => valor == null || valor.trim().isEmpty
                                ? 'Informe seu nome.' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            decoration: _decoracao('E-mail', Icons.mail_outline_rounded),
                            validator: (valor) {
                              final email = valor?.trim() ?? '';
                              if (email.isEmpty) return 'Informe seu e-mail.';
                              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                                return 'Informe um e-mail válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: senhaController,
                            style: const TextStyle(color: Colors.white),
                            obscureText: !mostrarSenha,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => cadastrar(),
                            decoration: _decoracao(
                              'Senha',
                              Icons.lock_outline_rounded,
                              sufixo: IconButton(
                                tooltip: mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
                                icon: Icon(
                                  mostrarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: _muted,
                                ),
                                onPressed: () => setState(() => mostrarSenha = !mostrarSenha),
                              ),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.isEmpty) return 'Informe uma senha.';
                              if (valor.length < 6) return 'Use pelo menos 6 caracteres.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text('Use pelo menos 6 caracteres.',
                              style: TextStyle(color: _muted, fontSize: 12)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              onPressed: carregando ? null : cadastrar,
                              style: FilledButton.styleFrom(
                                backgroundColor: _green,
                                foregroundColor: _background,
                                disabledBackgroundColor: const Color(0xFF426456),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: carregando
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: _background),
                                    )
                                  : const Text('Criar minha conta',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: carregando ? null : () => Navigator.of(context).pop(),
                    child: const Text('Já tenho uma conta · Voltar ao login',
                        style: TextStyle(color: _green, fontWeight: FontWeight.w600)),
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
