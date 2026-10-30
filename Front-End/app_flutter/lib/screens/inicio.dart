// Autor: Rafaela Jacobsen Braga - 25004280
import 'package:flutter/material.dart';

enum TipoOferta { doacao, venda }

class ExcedenteCult {
  final String nome;
  final String quantidade;
  final double distanciaKm;
  final String categoria;
  final String emoji;
  final TipoOferta tipo;
  final Color corInicial;
  final Color corFinal;

  const ExcedenteCult({
    required this.nome,
    required this.quantidade,
    required this.distanciaKm,
    required this.categoria,
    required this.emoji,
    required this.tipo,
    required this.corInicial,
    required this.corFinal,
  });
}

const List<ExcedenteCult> excedentesExemplo = [
  ExcedenteCult(
    nome: 'Manga Tommy',
    quantidade: '~5 kg',
    distanciaKm: 1.2,
    categoria: 'Frutas',
    emoji: '🥭',
    tipo: TipoOferta.doacao,
    corInicial: Color(0xFFFBDD88),
    corFinal: Color(0xFFF5AF49),
  ),
  ExcedenteCult(
    nome: 'Limão Taiti',
    quantidade: '~3 kg',
    distanciaKm: 2.4,
    categoria: 'Frutas',
    emoji: '🍋',
    tipo: TipoOferta.doacao,
    corInicial: Color(0xFFF8F09B),
    corFinal: Color(0xFFECDC52),
  ),
  ExcedenteCult(
    nome: 'Banana prata',
    quantidade: '~2 cachos',
    distanciaKm: 3.0,
    categoria: 'Frutas',
    emoji: '🍌',
    tipo: TipoOferta.venda,
    corInicial: Color(0xFFFBEA99),
    corFinal: Color(0xFFF7D054),
  ),
  ExcedenteCult(
    nome: 'Laranja pera',
    quantidade: '~8 kg',
    distanciaKm: 3.8,
    categoria: 'Frutas',
    emoji: '🍊',
    tipo: TipoOferta.venda,
    corInicial: Color(0xFFFDD49D),
    corFinal: Color(0xFFF8A653),
  ),
  ExcedenteCult(
    nome: 'Maçã',
    quantidade: '~4 kg',
    distanciaKm: 4.3,
    categoria: 'Frutas',
    emoji: '🍎',
    tipo: TipoOferta.doacao,
    corInicial: Color(0xFFF6AEA6),
    corFinal: Color(0xFFEB6965),
  ),
];

class InicioPage extends StatefulWidget {
  // Os callbacks permitem integrar as telas do grupo sem criar imports
  // circulares ou depender de arquivos que ainda não estejam prontos.
  final VoidCallback? onPublicar;
  final VoidCallback? onConversas;
  final VoidCallback? onPerfil;
  final List<ExcedenteCult> excedentes;

  const InicioPage({
    super.key,
    this.onPublicar,
    this.onConversas,
    this.onPerfil,
    this.excedentes = excedentesExemplo,
  });

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  static const Color verde = Color(0xFF267536);
  static const Color verdeEscuro = Color(0xFF206D31);
  static const Color laranja = Color(0xFFF47700);
  static const Color cinza = Color(0xFF929A91);
  static const Color fundo = Color(0xFFF7F8F2);
  static const Color textoEscuro = Color(0xFF20251F);

  final TextEditingController _buscaController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _localizacao = 'Jardim das Flores';
  String _categoria = 'Frutas'; // Filtro inicial igual ao da modelagem.
  String _tipo = 'Todos';
  double _raioKm = 5;

  static const List<(String, String)> _categorias = [
    ('Todas', ''),
    ('Frutas', '🍎'),
    ('Verduras', '🥬'),
    ('Legumes', '🥕'),
    ('Plantas', '🪴'),
  ];

  @override
  void dispose() {
    _buscaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _distancia(double valor) =>
      valor.toStringAsFixed(1).replaceAll('.', ',');

  List<ExcedenteCult> get _filtrados {
    final termo = _buscaController.text.trim().toLowerCase();
    return widget.excedentes.where((produto) {
      final correspondeBusca = produto.nome.toLowerCase().contains(termo);
      final correspondeCategoria =
          _categoria == 'Todas' || produto.categoria == _categoria;
      final correspondeRaio = produto.distanciaKm <= _raioKm;
      final correspondeTipo = _tipo == 'Todos' ||
          (_tipo == 'Doação' && produto.tipo == TipoOferta.doacao) ||
          (_tipo == 'Venda' && produto.tipo == TipoOferta.venda);
      return correspondeBusca &&
          correspondeCategoria &&
          correspondeRaio &&
          correspondeTipo;
    }).toList();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _editarLocalizacao() async {
    String localTemporario = _localizacao;
    final novaLocalizacao = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sua localização'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: localTemporario,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Bairro ou região',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              onChanged: (valor) => localTemporario = valor,
              onFieldSubmitted: (valor) => Navigator.pop(dialogContext, valor),
            ),
            const SizedBox(height: 12),
            const Text(
              'Localização ilustrativa. As distâncias serão atualizadas '
              'quando o aplicativo estiver conectado ao backend.',
              style: TextStyle(fontSize: 12, color: cinza),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, localTemporario),
            child: const Text('Salvar', style: TextStyle(color: verde)),
          ),
        ],
      ),
    );
    if (!mounted || novaLocalizacao == null || novaLocalizacao.trim().isEmpty) {
      return;
    }
    setState(() => _localizacao = novaLocalizacao.trim());
  }

  Future<void> _abrirFiltros() async {
    double raioTemporario = _raioKm;
    String tipoTemporario = _tipo;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (modalContext, atualizarModal) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar excedentes',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: textoEscuro,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Distância máxima',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [1.0, 3.0, 5.0, 10.0].map((raio) {
                      return ChoiceChip(
                        label: Text('${raio.toInt()} km'),
                        selected: raioTemporario == raio,
                        selectedColor: const Color(0xFFE4EFDF),
                        labelStyle: TextStyle(
                          color: raioTemporario == raio ? verdeEscuro : cinza,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => atualizarModal(
                          () => raioTemporario = raio,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Tipo de anúncio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['Todos', 'Doação', 'Venda'].map((tipo) {
                      return ChoiceChip(
                        label: Text(tipo),
                        selected: tipoTemporario == tipo,
                        selectedColor: const Color(0xFFE4EFDF),
                        labelStyle: TextStyle(
                          color: tipoTemporario == tipo ? verdeEscuro : cinza,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => atualizarModal(
                          () => tipoTemporario = tipo,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verde,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _raioKm = raioTemporario;
                          _tipo = tipoTemporario;
                        });
                        Navigator.pop(modalContext);
                      },
                      child: const Text(
                        'Aplicar filtros',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _abrirProduto(ExcedenteCult produto) {
    final doacao = produto.tipo == TipoOferta.doacao;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _imagemProduto(produto, tamanho: 76),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto.nome,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textoEscuro,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${produto.quantidade} · ${_distancia(produto.distanciaKm)} km',
                          style: const TextStyle(color: cinza, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _seloOferta(produto.tipo),
              const SizedBox(height: 18),
              Text(
                doacao
                    ? 'Este excedente está disponível para doação.'
                    : 'Este excedente está disponível para venda.',
                style: const TextStyle(fontSize: 16, color: textoEscuro),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(modalContext);
                    _mensagem(
                      'O interesse em ${produto.nome} poderá ser enviado '
                      'quando a conexão com o servidor estiver pronta.',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Tenho interesse',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagemProduto(ExcedenteCult produto, {double tamanho = 78}) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [produto.corInicial, produto.corFinal],
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Text(produto.emoji, style: TextStyle(fontSize: tamanho * 0.53)),
    );
  }

  Widget _seloOferta(TipoOferta tipo) {
    final doacao = tipo == TipoOferta.doacao;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: doacao ? const Color(0xFFE5F3E9) : const Color(0xFFFFEBDD),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(doacao ? '🎁' : '💰', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            doacao ? 'Doação' : 'Venda',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: doacao ? verdeEscuro : const Color(0xFF9E510B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardProduto(ExcedenteCult produto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.07),
        child: InkWell(
          onTap: () => _abrirProduto(produto),
          borderRadius: BorderRadius.circular(23),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                _imagemProduto(produto),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textoEscuro,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '${produto.quantidade} · ${_distancia(produto.distanciaKm)} km',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: cinza, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _seloOferta(produto.tipo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perto de você',
            style: TextStyle(color: cinza, fontSize: 15),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _editarLocalizacao,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📍', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _localizacao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textoEscuro,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.025),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _buscaController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar frutas, verduras...',
                      hintStyle: const TextStyle(color: Color(0xFFA4AAA2)),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF8F9990),
                        size: 25,
                      ),
                      suffixIcon: _buscaController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _buscaController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded, size: 19),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Material(
                color: verde,
                borderRadius: BorderRadius.circular(20),
                elevation: 4,
                shadowColor: verde.withValues(alpha: 0.22),
                child: InkWell(
                  onTap: _abrirFiltros,
                  borderRadius: BorderRadius.circular(20),
                  child: const SizedBox(
                    width: 58,
                    height: 58,
                    child: Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filtrosCategoria() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
        itemCount: _categorias.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final (nome, emoji) = _categorias[index];
          final selecionada = _categoria == nome;
          return ChoiceChip(
            selected: selecionada,
            showCheckmark: false,
            label: Text(
              emoji.isEmpty ? nome : '$emoji $nome',
              style: TextStyle(
                color: selecionada ? Colors.white : const Color(0xFF687067),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            selectedColor: verde,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selecionada ? verde : const Color(0xFFE5E9E2),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            onSelected: (_) => setState(() => _categoria = nome),
          );
        },
      ),
    );
  }

  Widget _tituloLista() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 17, 22, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Excedentes disponíveis',
              style: TextStyle(
                color: textoEscuro,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F3E9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              '📍 Até ${_raioKm.toInt()} km',
              style: const TextStyle(
                color: verdeEscuro,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _semResultados() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 35, 28, 35),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 54, color: cinza),
          const SizedBox(height: 12),
          const Text(
            'Nenhum excedente encontrado',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente outra categoria, busca ou distância.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cinza),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              _buscaController.clear();
              setState(() {
                _categoria = 'Todas';
                _tipo = 'Todos';
                _raioKm = 10;
              });
            },
            child: const Text('Limpar filtros', style: TextStyle(color: verde)),
          ),
        ],
      ),
    );
  }

  void _tocarNavegacao(VoidCallback? callback, String nome) {
    if (callback != null) {
      callback();
    } else {
      _mensagem('A navegação para $nome será conectada às telas do grupo.');
    }
  }

  Widget _itemNavegacao({
    required IconData icone,
    required String texto,
    required bool selecionado,
    required VoidCallback aoTocar,
  }) {
    return Expanded(
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 28,
                color: selecionado ? verde : Colors.grey,
              ),
              const SizedBox(height: 5),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                  color: selecionado ? verde : Colors.grey,
                ),
              ),
              if (selecionado)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: verde,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barraInferior() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7EAE4))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              _itemNavegacao(
                icone: Icons.home_outlined,
                texto: 'Início',
                selecionado: true,
                aoTocar: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
              _itemNavegacao(
                icone: Icons.add,
                texto: 'Publicar',
                selecionado: false,
                aoTocar: () => _tocarNavegacao(widget.onPublicar, 'Publicar'),
              ),
              _itemNavegacao(
                icone: Icons.chat_bubble_outline,
                texto: 'Conversas',
                selecionado: false,
                aoTocar: () => _tocarNavegacao(widget.onConversas, 'Conversas'),
              ),
              _itemNavegacao(
                icone: Icons.person,
                texto: 'Perfil',
                selecionado: false,
                aoTocar: () => _tocarNavegacao(widget.onPerfil, 'Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produtos = _filtrados;
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _cabecalho()),
            SliverToBoxAdapter(child: _filtrosCategoria()),
            SliverToBoxAdapter(child: _tituloLista()),
            if (produtos.isEmpty)
              SliverToBoxAdapter(child: _semResultados())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _cardProduto(produtos[index]),
                    childCount: produtos.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _barraInferior(),
    );
  }
}
