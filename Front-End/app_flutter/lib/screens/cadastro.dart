//Autora: Laura Lugli Fonseca Pereira RA:25000739
import 'package:flutter/material.dart';

// precisa importar o login pra conseguir mandar o usuário pra lá pelo link "Entrar"
import 'login.dart';

// cores da identidade visual do CULT+
// 0xFF diz que a cor é 100% opaca
const corVerde = Color(0xFF2E7D32);
//fundo do cartão de perfil quando ele tá selecionado
const corVerdeClaro = Color(0xFFE6F1E3);
const corLaranja = Color(0xFFEF6C00);
//bege do fundo da tela
const corFundo = Color(0xFFF7F6F1);
const corTexto = Color(0xFF1F2A1F);
//usado nas dicas dos campos e nos textos secundários
const corCinza = Color(0xFF8A8F87);
const corBorda = Color(0xFFE6E6E0);

//os três jeitos que a pessoa pode usar o app
enum TipoPerfil { ofertante, interessado, ambos }

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

  //começa com a senha escondida
  bool _senhaOculta = true;

  //perfil marcado, começa em interessado
  TipoPerfil _perfil = TipoPerfil.interessado;

  //usada para validar todos os campos de uma vez
  final _formKey = GlobalKey<FormState>();

  //libera os controllers quando a tela fecha
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _localController.dispose();
    super.dispose();
  }

  void _criarConta() {
    //se algum campo der erro para aqui
    if (!_formKey.currentState!.validate()) return;

    //depois aqui entra o cadastro no banco
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Conta criada!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      //evita que o conteúdo fique embaixo da câmera e do relógio
      body: SafeArea(
        //deixa rolar a tela quando o teclado abre
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _cabecalho(),
                const SizedBox(height: 24),
                _rotulo('Nome completo'),
                //trim tira os espaços para nao aceitar nome só com espaço
                _campo(
                  controller: _nomeController,
                  dica: 'Seu nome',
                  validador: (v) => (v == null || v.trim().isEmpty)
                      ? 'Digite seu nome'
                      : null,
                ),
                _rotulo('E-mail'),
                _campo(
                  controller: _emailController,
                  dica: 'voce@email.com',
                  teclado: TextInputType.emailAddress,
                  validador: (v) => (v == null || !v.contains('@'))
                      ? 'E-mail inválido'
                      : null,
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
                    onPressed: () =>
                        setState(() => _senhaOculta = !_senhaOculta),
                  ),
                  validador: (v) => (v == null || v.length < 6)
                      ? 'Mínimo de 6 caracteres'
                      : null,
                ),
                _rotulo('Localização'),
                _campo(
                  controller: _localController,
                  dica: 'Bairro ou cidade',
                  prefixo: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Text('📍', style: TextStyle(fontSize: 18)),
                  ),
                  validador: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe sua localização'
                      : null,
                ),
                _rotulo('Quero usar o CULT+ como'),
                _seletorPerfil(),
                const SizedBox(height: 24),
                _botaoCriarConta(),
                const SizedBox(height: 16),
                _linkEntrar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //logo, nome do app, título e subtítulo
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

  //texto em negrito em cima de cada campo
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

  //campo usado em todos os inputs, cada um passa só o que muda
  Widget _campo({
    required TextEditingController controller,
    required String dica,
    String? Function(String?)? validador,
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
      validator: validador,
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
        //tira o espaço extra que o Flutter deixa antes do ícone
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: sufixo,
        border: borda,
        enabledBorder: borda,
        //borda verde quando o campo tá selecionado
        focusedBorder: borda.copyWith(
          borderSide: const BorderSide(color: corVerde, width: 2),
        ),
      ),
    );
  }

  //os três cartões lado a lado com a mesma altura
  Widget _seletorPerfil() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _cartaoPerfil(
              TipoPerfil.ofertante,
              '🧑‍🌾',
              'Ofertante',
              'Tenho excedentes',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _cartaoPerfil(
              TipoPerfil.interessado,
              '🛒',
              'Interessado',
              'Procuro produtos',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _cartaoPerfil(
              TipoPerfil.ambos,
              '🤝',
              'Ambos',
              'Os dois perfis',
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartaoPerfil(
    TipoPerfil tipo,
    String emoji,
    String titulo,
    String descricao,
  ) {
    final selecionado = _perfil == tipo;

    //ao tocar troca o perfil escolhido 
    return GestureDetector(
      onTap: () => setState(() => _perfil = tipo),
      //stack pra colocar a bolinha do check encima do cartão
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
            decoration: BoxDecoration(
              color: selecionado ? corVerdeClaro : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selecionado ? corVerde : corBorda,
                width: selecionado ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: corTexto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descricao,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: corCinza),
                ),
              ],
            ),
          ),

          //bolinha do check só no cartão escolhido
          if (selecionado)
            Positioned(
              top: -8,
              right: -6,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: corVerde,
                  shape: BoxShape.circle,
                  border: Border.all(color: corFundo, width: 2),
                ),
                child: const Icon(Icons.check, size: 15, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _botaoCriarConta() {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: _criarConta,
        style: ElevatedButton.styleFrom(
          backgroundColor: corLaranja,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: const Color(0x66EF6C00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          'Criar conta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _linkEntrar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Já tem conta? ',
          style: TextStyle(fontSize: 15, color: corCinza),
        ),
        GestureDetector(
          //troca o cadastro pelo login pra não voltar pro cadastro depois
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
          child: const Text(
            'Entrar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: corVerde,
            ),
          ),
        ),
      ],
    );
  }
}
