//Autora: Laura Lugli Fonseca Pereira RA: 25000739
import 'package:flutter/material.dart';
import '../services/excedente_service.dart';

// cores da identidade visual
// 0xFF diz que a cor é 100% opaca
const corVerde = Color(0xFF2E7D32);
//fundo do botão de adicionar foto
const corVerdeClaro = Color(0xFFE6F1E3);
const corLaranja = Color(0xFFEF6C00);
//bege do fundo da tela
const corFundo = Color(0xFFF7F6F1);
const corTexto = Color(0xFF1F2A1F);
//usado nas dicas dos campos e nos textos secundários
const corCinza = Color(0xFF8A8F87);
const corBorda = Color(0xFFE6E6E0);

//tipos de produto que dá pra publicar
enum Categoria { frutas, verduras, legumes, mudas }

//se o excedente vai ser doado ou vendido
enum Modalidade { doacao, venda }

class PublicarPage extends StatefulWidget {
  const PublicarPage({super.key});

  @override
  State<PublicarPage> createState() => _PublicarPageState();
}

class _PublicarPageState extends State<PublicarPage> {
  //por enquanto as fotos são emojis, depois troca pelas imagens de verdade
  final List<String> _fotos = ['🥭'];

  //guarda o nome do produto, já começa preenchido
  final _produtoController = TextEditingController(text: 'Manga Tommy');

  //categoria marcada, começa em frutas
  Categoria _categoria = Categoria.frutas;

  final _quantidadeController = TextEditingController(text: '5');

  //a chave é o valor que vai pro banco e o valor é o que aparece na tela
  final Map<String, String> _unidades = {
    'kg': 'kg',
    'un': 'un',
    'maco': 'maço',
    'cacho': 'cacho',
    'muda': 'muda',
  };
  final Map<String, String> _urgencias = {
    'hoje': 'Hoje',
    'alguns_dias': 'Alguns dias',
    'sem_pressa': 'Sem pressa',
  };

  //opção escolhida em cada listinha, guarda o valor do banco
  String _unidade = 'kg';
  String _urgencia = 'alguns_dias';

  //modalidade marcada, começa em doação
  Modalidade _modalidade = Modalidade.doacao;
  //depois vem do perfil do usuário
  String _local = 'Jardim das Flores';
  //até o login ficar pronto, publica com um usuário de teste
  final String _ofertanteId = '6543a1f2b3c4d5e6f7a8b9c0';
  final String _ofertanteNome = 'Laura';

  //depois vem da localização do usuário
  final String _cidade = 'Campinas';
  final double _latitude = -22.90;
  final double _longitude = -47.06;

  //libera os controllers quando a tela fecha
  @override
  void dispose() {
    _produtoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  //mostra uma mensagem embaixo da tela
  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _publicar() async {
    //troca a vírgula por ponto pra aceitar 2,5 e tenta transformar em número
    final quantidade = double.tryParse(
      _quantidadeController.text.replaceAll(',', '.'),
    );

    //cada if confere uma coisa, se der erro mostra a mensagem e para aqui
    if (_fotos.isEmpty) {
      _mostrarMensagem('Adicione pelo menos uma foto.');
      return;
    }
    if (_produtoController.text.trim().isEmpty) {
      _mostrarMensagem('Digite o nome do produto.');
      return;
    }

    //null é quando o texto não é um número
    if (quantidade == null || quantidade <= 0) {
      _mostrarMensagem('Informe uma quantidade válida.');
      return;
    }

    //manda pra api, os nomes são os mesmos que o backend espera
    final erro = await ExcedenteService.publicar({
      'ofertanteId': _ofertanteId,
      'ofertanteNome': _ofertanteNome,
      'produto': _produtoController.text.trim(),
      'categoria': _categoria.name,
      'quantidade': quantidade,
      'unidade': _unidade,
      'urgencia': _urgencia,
      'modalidade': _modalidade.name,
      'bairro': _local,
      'cidade': _cidade,
      'latitude': _latitude,
      'longitude': _longitude,
    });

    //a tela pode ter sido fechada enquanto esperava
    if (!mounted) return;

    //se voltou mensagem é porque deu erro
    if (erro != null) {
      _mostrarMensagem(erro);
      return;
    }

    _mostrarMensagem('Excedente publicado!');

    //fecha a tela e volta pra anterior (true avisa que publicou)
    Navigator.maybePop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      //evita que o conteúdo fique embaixo da câmera e do relógio
      body: SafeArea(
        child: Column(
          children: [
            _topo(),
            //só o meio rola, o topo e o botão ficam fixos
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _rotulo('Fotos'),
                    _fotosProduto(),
                    _rotulo('Produto'),
                    _campoProduto(),
                    _rotulo('Categoria'),
                    _seletorCategoria(),
                    _quantidadeEUrgencia(),
                    const SizedBox(height: 8),
                    const Text(
                      'Urgência não é usada no match desta versão (MVP).',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: corCinza,
                      ),
                    ),
                    _rotulo('Localização'),
                    _caixaLocalizacao(),
                    _rotulo('Modalidade'),
                    _seletorModalidade(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            //botão fora do scroll pra ficar sempre visível embaixo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: _botaoPublicar(),
            ),
          ],
        ),
      ),
    );
  }

  //botão de voltar e título da tela
  Widget _topo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            //volta pra tela anterior se tiver alguma
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: corTexto, size: 20),
            ),
          ),
          const Expanded(
            child: Text(
              'Novo excedente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: corTexto,
              ),
            ),
          ),
          //espaço do mesmo tamanho do botão pra deixar o título bem no meio
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  //texto em negrito em cima de cada parte
  Widget _rotulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
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

  //fotos já adicionadas e o botão de adicionar no final
  //wrap joga pra linha de baixo quando não cabe
  Widget _fotosProduto() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        //cria um quadradinho pra cada foto da lista
        for (int i = 0; i < _fotos.length; i++) _foto(i),
        _botaoAdicionarFoto(),
      ],
    );
  }

  Widget _foto(int indice) {
    //stack pra colocar o X em cima da foto
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            //degradê de amarelo pra laranja
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD36B), Color(0xFFF5A623)],
            ),
          ),
          alignment: Alignment.center,
          child: Text(_fotos[indice], style: const TextStyle(fontSize: 52)),
        ),
        //botão de remover a foto, os valores negativos puxam ele pra fora do canto
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () => setState(() => _fotos.removeAt(indice)),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: corTexto,
                shape: BoxShape.circle,
                border: Border.all(color: corFundo, width: 2),
              ),
              child: const Icon(Icons.close, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _botaoAdicionarFoto() {
    return GestureDetector(
      onTap: () => _mostrarMensagem('Seleção de fotos ainda não implementada.'),
      //CustomPaint desenha a borda tracejada, o Flutter não tem pronta
      child: CustomPaint(
        painter: _BordaTracejada(),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: corVerdeClaro,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📷', style: TextStyle(fontSize: 26)),
              SizedBox(height: 4),
              Text(
                'Adicionar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: corVerde,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoProduto() {
    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: corBorda),
    );

    return TextField(
      controller: _produtoController,
      style: const TextStyle(fontSize: 16, color: corTexto),
      decoration: InputDecoration(
        hintText: 'Ex: Manga, alface, cenoura',
        hintStyle: const TextStyle(color: corCinza),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        enabledBorder: borda,
        //borda verde quando o campo tá selecionado
        focusedBorder: borda.copyWith(
          borderSide: const BorderSide(color: corVerde, width: 2),
        ),
      ),
    );
  }

  //chips de categoria, o wrap joga pra linha de baixo os que não cabem
  Widget _seletorCategoria() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _chipCategoria(Categoria.frutas, '🍎 Frutas'),
        _chipCategoria(Categoria.verduras, '🥬 Verduras'),
        _chipCategoria(Categoria.legumes, '🥕 Legumes'),
        _chipCategoria(Categoria.mudas, '🌱 Mudas'),
      ],
    );
  }

  Widget _chipCategoria(Categoria categoria, String texto) {
    final selecionado = _categoria == categoria;

    //ao tocar troca a categoria escolhida
    return GestureDetector(
      onTap: () => setState(() => _categoria = categoria),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          //selecionado fica verde, os outros ficam brancos
          color: selecionado ? corVerde : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selecionado ? corVerde : corBorda),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selecionado ? Colors.white : corCinza,
          ),
        ),
      ),
    );
  }

  //caixa branca com borda que se repete em vários campos
  BoxDecoration _decoracaoCaixa() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: corBorda),
    );
  }

  //quantidade e urgência lado a lado, cada uma com metade da largura
  Widget _quantidadeEUrgencia() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_rotulo('Quantidade'), _campoQuantidade()],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_rotulo('Urgência'), _listaUrgencia()],
          ),
        ),
      ],
    );
  }

  //número digitado e a unidade escolhida dentro da mesma caixa
  Widget _campoQuantidade() {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 18, right: 8),
      decoration: _decoracaoCaixa(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _quantidadeController,
              //abre o teclado de números com vírgula
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 16, color: corTexto),
              //sem borda porque quem faz a borda é a caixa de fora
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: corCinza),
              ),
            ),
          ),
          DropdownButton<String>(
            value: _unidade,
            //tira a linha que o dropdown tem embaixo
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(16),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: corCinza,
              size: 18,
            ),
            style: const TextStyle(fontSize: 16, color: corCinza),
            //transforma cada texto da lista numa opção do dropdown
            //value é o que vai pro banco e o Text é o que aparece
            items: _unidades.entries
                .map(
                  (u) => DropdownMenuItem(value: u.key, child: Text(u.value)),
                )
                .toList(),
            onChanged: (valor) => setState(() => _unidade = valor!),
          ),
        ],
      ),
    );
  }

  Widget _listaUrgencia() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: _decoracaoCaixa(),
      child: DropdownButton<String>(
        value: _urgencia,
        //ocupa a caixa inteira e joga a setinha pro canto
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(16),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down, color: corCinza, size: 18),
        style: const TextStyle(fontSize: 16, color: corTexto),
        items: _urgencias.entries
            .map((u) => DropdownMenuItem(value: u.key, child: Text(u.value)))
            .toList(),
        onChanged: (valor) => setState(() => _urgencia = valor!),
      ),
    );
  }

  Widget _caixaLocalizacao() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: _decoracaoCaixa(),
      child: Row(
        children: [
          const Text('📍', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          //ocupa o meio e empurra o Alterar pro canto direito
          Expanded(
            child: Text(
              _local,
              style: const TextStyle(fontSize: 16, color: corTexto),
            ),
          ),
          GestureDetector(
            onTap: () => _mostrarMensagem(
              'Troca de localização ainda não implementada.',
            ),
            child: const Text(
              'Alterar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: corVerde,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //caixa branca com as duas opções dentro, a escolhida fica verde
  Widget _seletorModalidade() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: corBorda),
      ),
      child: Row(
        children: [
          Expanded(child: _opcaoModalidade(Modalidade.doacao, '🎁 Doação')),
          Expanded(child: _opcaoModalidade(Modalidade.venda, '💰 Venda')),
        ],
      ),
    );
  }

  Widget _opcaoModalidade(Modalidade modalidade, String texto) {
    final selecionado = _modalidade == modalidade;

    //ao tocar troca a modalidade escolhida

    return GestureDetector(
      onTap: () => setState(() => _modalidade = modalidade),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          //a que não tá escolhida fica transparente e some no fundo branco
          color: selecionado ? corVerde : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          //sombra só na opção escolhida
          boxShadow: selecionado
              ? const [
                  BoxShadow(
                    color: Color(0x332E7D32),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: selecionado ? Colors.white : corCinza,
          ),
        ),
      ),
    );
  }

  //botão laranja que chama a função _publicar lá de cima
  Widget _botaoPublicar() {
    return SizedBox(
      height: 58,
      //ocupa toda a largura disponível
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _publicar,
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
          'Publicar excedente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

//desenha a borda tracejada verde do botão de adicionar foto
class _BordaTracejada extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    //pincel verde que só faz o contorno
    final pincel = Paint()
      ..color = corVerde
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    //caminho com o formato do botão, um retângulo de cantos arredondados
    final caminho = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          const Radius.circular(18),
        ),
      );

    //vai andando pela borda e desenhando um tracinho de 6 com espaço de 5
    for (final medida in caminho.computeMetrics()) {
      double distancia = 0;
      while (distancia < medida.length) {
        canvas.drawPath(medida.extractPath(distancia, distancia + 6), pincel);
        distancia += 11;
      }
    }
  }

  //a borda nunca muda, então não precisa redesenhar
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
