//autor: Emilly Morelatto
import 'package:flutter/material.dart';
import 'cadastro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool mostrarSenha = false;

  final Color verde = const Color(0xFF267536);
  final Color laranja = const Color(0xFFF47700);
  final Color cinza = const Color(0xFF929A91);

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void entrar() {
    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o e-mail e a senha.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login ainda não conectado ao servidor.')),
    );
  }

  void recuperarSenha() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recuperação de senha ainda não implementada.'),
      ),
    );
  }

  void criarConta() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPage()),
    );
  }

  Widget campoTexto({
    required String titulo,
    required String dica,
    required TextEditingController controller,
    required IconData icone,
    bool senha = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF20251F),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 76,
          child: TextField(
            controller: controller,
            obscureText: senha && !mostrarSenha,
            keyboardType: senha
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
            style: const TextStyle(fontSize: 17, color: Color(0xFF252A24)),
            decoration: InputDecoration(
              hintText: dica,
              hintStyle: TextStyle(color: cinza, fontSize: 17),
              prefixIcon: Icon(icone, color: cinza, size: 27),
              suffixIcon: senha
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          mostrarSenha = !mostrarSenha;
                        });
                      },
                      icon: Icon(
                        mostrarSenha
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: cinza,
                        size: 27,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                  color: Color(0xFFDDE3D9),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: verde, width: 1.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),

                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                color: const Color(0xFF19752D),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: verde.withValues(alpha: 0.15),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.spa,
                                color: Color(0xFFB5DB57),
                                size: 65,
                              ),
                            ),
                            const SizedBox(height: 22),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'CULT',
                                    style: TextStyle(
                                      color: Color(0xFF206D31),
                                      fontSize: 43,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '+',
                                    style: TextStyle(
                                      color: Color(0xFFF47700),
                                      fontSize: 43,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 42),

                      const Text(
                        'Entrar na sua conta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF191D18),
                          letterSpacing: -0.7,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Bem-vindo de volta! Faça login para\ncontinuar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          height: 1.5,
                          color: cinza,
                        ),
                      ),

                      const SizedBox(height: 64),

                      campoTexto(
                        titulo: 'E-mail',
                        dica: 'seu@email.com',
                        controller: emailController,
                        icone: Icons.mail_outline,
                      ),

                      const SizedBox(height: 38),

                      campoTexto(
                        titulo: 'Senha',
                        dica: 'Digite sua senha',
                        controller: senhaController,
                        icone: Icons.lock_outline,
                        senha: true,
                      ),

                      const SizedBox(height: 30),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: recuperarSenha,
                          style: TextButton.styleFrom(
                            foregroundColor: verde,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Esqueceu sua senha?',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 54),

                      SizedBox(
                        height: 104,
                        child: ElevatedButton(
                          onPressed: entrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: laranja,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: laranja.withValues(alpha: 0.25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFD7DDD4),
                              thickness: 1.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'ou',
                              style: TextStyle(color: cinza, fontSize: 20),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFD7DDD4),
                              thickness: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        height: 92,
                        child: OutlinedButton(
                          onPressed: criarConta,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: verde,
                            side: BorderSide(color: verde, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Criar uma conta',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),

                      Text(
                        'Cultivando melhores escolhas\npara o seu futuro.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cinza,
                          fontSize: 19,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
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
