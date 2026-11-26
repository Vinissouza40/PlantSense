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
  static const Color _background = Color(0xFF07130F);
  static const Color _panel = Color(0xFF10221B);
  static const Color _green = Color(0xFF52D69A);
  static const Color _muted = Color(0xFF9AAFA5);
  static const Color _border = Color(0xFF294337);

  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool mostrarSenha = false;
  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: const Color(0xFF913D3D),
      ),
    );
  }

  void _abrirHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Future<void> login() async {
    if (carregando || !_formKey.currentState!.validate()) return;

    setState(() => carregando = true);
    try {
      final resultado = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );
      if (resultado.user != null) _abrirHome();
    } on FirebaseAuthException catch (e) {
      final mensagem = switch (e.code) {
        'user-not-found' => 'Usuário não encontrado.',
        'wrong-password' => 'Senha incorreta.',
        'invalid-email' => 'E-mail inválido.',
        'invalid-credential' => 'E-mail ou senha incorretos.',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
        'network-request-failed' => 'Verifique sua conexão com a internet.',
        _ => e.message ?? 'Não foi possível entrar.',
      };
      _mostrarMensagem(mensagem);
    } catch (e) {
      _mostrarMensagem('Erro ao fazer login: $e');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> loginComGoogle() async {
    if (carregando) return;
    setState(() => carregando = true);
    try {
      // Mantém a API do Google Sign-In utilizada no código original.
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credencial = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final resultado = await _auth.signInWithCredential(credencial);
      if (resultado.user != null) _abrirHome();
    } catch (e) {
      _mostrarMensagem('Erro ao fazer login com Google: $e');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
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
                        border: Border.all(color: _border, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23),
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
                    'Bem-vindo ao PlantSense',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Acompanhe a saúde das suas plantas em tempo real.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: _border),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Entrar na minha conta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Informe seus dados para continuar.',
                            style: TextStyle(color: _muted, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: Colors.white),
                            decoration: _decoracao(
                              'E-mail',
                              Icons.mail_outline_rounded,
                            ),
                            validator: (valor) {
                              final email = valor?.trim() ?? '';
                              if (email.isEmpty) return 'Informe seu e-mail.';
                              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(email)) {
                                return 'Informe um e-mail válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: senhaController,
                            obscureText: !mostrarSenha,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => login(),
                            style: const TextStyle(color: Colors.white),
                            decoration: _decoracao(
                              'Senha',
                              Icons.lock_outline_rounded,
                              sufixo: IconButton(
                                tooltip: mostrarSenha
                                    ? 'Ocultar senha'
                                    : 'Mostrar senha',
                                icon: Icon(
                                  mostrarSenha
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _muted,
                                ),
                                onPressed: () => setState(
                                  () => mostrarSenha = !mostrarSenha,
                                ),
                              ),
                            ),
                            validator: (valor) =>
                                valor == null || valor.isEmpty
                                    ? 'Informe sua senha.'
                                    : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: carregando
                                  ? null
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const EsqueciSenhaPage(),
                                        ),
                                      ),
                              child: const Text(
                                'Esqueceu a senha?',
                                style: TextStyle(color: _green),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: carregando ? null : login,
                              style: FilledButton.styleFrom(
                                backgroundColor: _green,
                                foregroundColor: _background,
                                disabledBackgroundColor: Color(0xFF426456),
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
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Expanded(child: Divider(color: _border)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'ou continue com',
                                  style: TextStyle(color: _muted, fontSize: 12),
                                ),
                              ),
                              Expanded(child: Divider(color: _border)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: carregando ? null : loginComGoogle,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: _border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: Image.asset(
                                'assets/google_g.png',
                                width: 22,
                                height: 22,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.account_circle_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              label: const Text(
                                'Entrar com Google',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: carregando
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CadastroPage(),
                              ),
                            ),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Ainda não tem uma conta? ',
                            style: TextStyle(color: _muted),
                          ),
                          TextSpan(
                            text: 'Cadastre-se',
                            style: TextStyle(
                              color: _green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
