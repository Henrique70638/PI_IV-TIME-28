import 'package:flutter/material.dart';

const corVerde = Color(0xFF2E7D32);
const corVerdeClaro = Color(0xFFE6F1E3);
const corLaranja = Color(0xFFEF6C00);
const corFundo = Color(0xFFF7F6F1);
const corTexto = Color(0xFF1F2A1F);
const corCinza = Color(0xFF8A8F87);
const corBorda = Color(0xFFE6E6E0);

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _localController = TextEditingController();

  bool _senhaOculta = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cabecalho(),
              const SizedBox(height: 24),
              _rotulo('Nome completo'),
              _campo(controller: _nomeController, dica: 'Seu nome'),
              _rotulo('E-mail'),
              _campo(
                controller: _emailController,
                dica: 'voce@email.com',
                teclado: TextInputType.emailAddress,
              ),
              _rotulo('Senha'),
              _campo(
                controller: _senhaController,
                dica: '••••••••',
                oculto: _senhaOculta,
                sufixo: IconButton(
                  icon: Icon(
                    _senhaOculta
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: corCinza,
                  ),
                  onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
                ),
              ),
              _rotulo('Localização'),
              _campo(
                controller: _localController,
                dica: 'Bairro ou cidade',
                prefixo: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Text('📍', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: corVerde,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x332E7D32),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text('🌱', style: TextStyle(fontSize: 44)),
        ),
        const SizedBox(height: 12),
        const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            children: [
              TextSpan(
                text: 'CULT',
                style: TextStyle(color: corVerde),
              ),
              TextSpan(
                text: '+',
                style: TextStyle(color: corLaranja),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Crie sua conta',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: corTexto,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Conecte excedentes a quem procura.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: corCinza),
        ),
      ],
    );
  }

  Widget _rotulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: corTexto,
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String dica,
    TextInputType teclado = TextInputType.text,
    bool oculto = false,
    Widget? prefixo,
    Widget? sufixo,
  }) {
    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: corBorda),
    );

    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      obscureText: oculto,
      style: const TextStyle(fontSize: 16, color: corTexto),
      decoration: InputDecoration(
        hintText: dica,
        hintStyle: const TextStyle(color: corCinza),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        prefixIcon: prefixo,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: sufixo,
        border: borda,
        enabledBorder: borda,
        focusedBorder: borda.copyWith(
          borderSide: const BorderSide(color: corVerde, width: 2),
        ),
      ),
    );
  }
}
