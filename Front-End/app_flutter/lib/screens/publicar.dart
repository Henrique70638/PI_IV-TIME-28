import 'package:flutter/material.dart';

const corVerde = Color(0xFF2E7D32);
const corVerdeClaro = Color(0xFFE6F1E3);
const corLaranja = Color(0xFFEF6C00);
const corFundo = Color(0xFFF7F6F1);
const corTexto = Color(0xFF1F2A1F);
const corCinza = Color(0xFF8A8F87);
const corBorda = Color(0xFFE6E6E0);

enum Categoria { frutas, verduras, legumes, mudas }

enum Modalidade { doacao, venda }

class PublicarPage extends StatefulWidget {
  const PublicarPage({super.key});

  @override
  State<PublicarPage> createState() => _PublicarPageState();
}

class _PublicarPageState extends State<PublicarPage> {
  final List<String> _fotos = ['🥭'];

  final _produtoController = TextEditingController(text: 'Manga Tommy');

  Categoria _categoria = Categoria.frutas;

  final _quantidadeController = TextEditingController(text: '5');

  final List<String> _unidades = ['kg', 'un', 'cx'];
  final List<String> _urgencias = ['Hoje', 'Alguns dias', 'Esta semana'];
  String _unidade = 'kg';
  String _urgencia = 'Alguns dias';

  Modalidade _modalidade = Modalidade.doacao;
  String _local = 'Jardim das Flores';

  @override
  void dispose() {
    _produtoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        child: Column(
          children: [
            _topo(),
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
          ],
        ),
      ),
    );
  }

  Widget _topo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          GestureDetector(
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

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

  Widget _fotosProduto() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (int i = 0; i < _fotos.length; i++) _foto(i),
        _botaoAdicionarFoto(),
      ],
    );
  }

  Widget _foto(int indice) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD36B), Color(0xFFF5A623)],
            ),
          ),
          alignment: Alignment.center,
          child: Text(_fotos[indice], style: const TextStyle(fontSize: 52)),
        ),
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
        focusedBorder: borda.copyWith(
          borderSide: const BorderSide(color: corVerde, width: 2),
        ),
      ),
    );
  }

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

    return GestureDetector(
      onTap: () => setState(() => _categoria = categoria),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
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

  BoxDecoration _decoracaoCaixa() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: corBorda),
    );
  }

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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 16, color: corTexto),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: corCinza),
              ),
            ),
          ),
          DropdownButton<String>(
            value: _unidade,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(16),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: corCinza,
              size: 18,
            ),
            style: const TextStyle(fontSize: 16, color: corCinza),
            items: _unidades
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
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
        isExpanded: true,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(16),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down, color: corCinza, size: 18),
        style: const TextStyle(fontSize: 16, color: corTexto),
        items: _urgencias
            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
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

    return GestureDetector(
      onTap: () => setState(() => _modalidade = modalidade),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selecionado ? corVerde : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
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
}

class _BordaTracejada extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = corVerde
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final caminho = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          const Radius.circular(18),
        ),
      );

    for (final medida in caminho.computeMetrics()) {
      double distancia = 0;
      while (distancia < medida.length) {
        canvas.drawPath(medida.extractPath(distancia, distancia + 6), pincel);
        distancia += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
