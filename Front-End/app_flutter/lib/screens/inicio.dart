// Autor: Rafaela Jacobsen Braga - RA: 25004280
//Autora: Laura Lugli Fonseca Pereira RA:25000739
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/busca_excedentes_api.dart';
import '../services/conexao_service.dart';
import '../services/catalogo_produtos.dart';
import '../services/sessao.dart';
import 'conexao_confirmada.dart';
import 'editar_perfil.dart';
import 'conversas.dart';
import 'perfil.dart';
import 'publicar.dart';

enum TipoOferta { doacao, venda }

class ExcedenteCult {
  final String? id;
  final String nome;
  final String quantidade;
  final double distanciaKm;
  final String categoria;
  final String emoji;
  final TipoOferta tipo;
  final Color corInicial;
  final Color corFinal;
  //foto real do excedente, null quando so tem desenho
  final String? foto;

  const ExcedenteCult({
    this.id,
    required this.nome,
    required this.quantidade,
    required this.distanciaKm,
    required this.categoria,
    required this.emoji,
    required this.tipo,
    required this.corInicial,
    required this.corFinal,
    this.foto,
  });

  // Converte o JSON retornado pela API, sem modificar os dados de demonstração.
  factory ExcedenteCult.fromApi(Map<String, dynamic> dados) {
    final nome = dados['produto'];
    final quantidade = dados['quantidade'];
    final distancia = dados['distanciaKm'];
    final modalidade = dados['modalidade'];
    final categoria = dados['categoria'];
    final unidade = dados['unidade'];
    if (nome is! String ||
        quantidade is! num ||
        distancia is! num ||
        modalidade is! String ||
        categoria is! String ||
        unidade is! String ||
        !['doacao', 'venda'].contains(modalidade)) {
      throw const FormatException('Excedente sem os campos obrigatórios.');
    }

    final categoriaExibida = switch (categoria) {
      'frutas' => 'Frutas',
      'verduras' => 'Verduras',
      'legumes' => 'Legumes',
      'mudas' => 'Plantas',
      _ => 'Outros',
    };
    final emoji = CatalogoProdutos.ilustracao(nome, categoria);
    final numero = quantidade.toDouble();
    final valorQuantidade = numero == numero.truncateToDouble()
        ? numero.toInt().toString()
        : numero.toString();
    final unidadeExibida = switch (unidade) {
      'maco' => 'maços',
      'cacho' => 'cachos',
      'muda' => 'mudas',
      'un' => 'unidades',
      _ => unidade,
    };

    //pega a primeira foto da lista se for uma imagem de verdade
    //os excedentes antigos de teste tem so um caminho de arquivo, esses ficam com o desenho
    final fotos = dados['fotos'];
    final primeira = fotos is List && fotos.isNotEmpty ? fotos.first : null;
    final foto = primeira is String && primeira.startsWith('data:image/')
        ? primeira
        : null;

    return ExcedenteCult(
      id: dados['id'] is String ? dados['id'] as String : null,
      nome: nome,
      quantidade: '~$valorQuantidade $unidadeExibida',
      distanciaKm: distancia.toDouble(),
      categoria: categoriaExibida,
      emoji: emoji,
      tipo: modalidade == 'doacao' ? TipoOferta.doacao : TipoOferta.venda,
      corInicial: CatalogoProdutos.fundo(categoria),
      corFinal: CatalogoProdutos.fundo(categoria),
      foto: foto,
    );
  }
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
  static const Color cinza = Color(0xFF929A91);
  static const Color fundo = Color(0xFFF7F8F2);
  static const Color textoEscuro = Color(0xFF20251F);

  // Usuários autenticados veem ofertas do banco; prévias sem login seguem em demo.
  bool get _usarApi =>
      Sessao.logado || const bool.fromEnvironment('CULT_USAR_API');
  static const String _latitudeConfigurada = String.fromEnvironment(
    'CULT_LATITUDE',
  );
  static const String _longitudeConfigurada = String.fromEnvironment(
    'CULT_LONGITUDE',
  );
  static const bool _apiDemonstracao = bool.fromEnvironment('CULT_API_DEMO');
  final BuscaExcedentesApi _api = BuscaExcedentesApi();
  List<ExcedenteCult> _excedentesApi = [];
  bool _carregando = false;
  bool _enviandoInteresse = false;
  bool _mostrarTodasOfertas = false;
  String? _erroApi;
  int _versaoConsulta = 0;
  Timer? _debounceBusca;

  final TextEditingController _buscaController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _localizacao = Sessao.logado
      ? (Sessao.usuario?['bairro']?.toString() ?? 'Localização do cadastro')
      : 'Jardim das Flores';
  String _categoria = Sessao.logado ? 'Todas' : 'Frutas';
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
  void initState() {
    super.initState();
    if (_usarApi) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _carregarExcedentes();
      });
    }
  }

  Future<void> _carregarExcedentes() async {
    if (!_usarApi) return;
    final versao = ++_versaoConsulta;
    final latitude = double.tryParse(_latitudeConfigurada);
    final longitude = double.tryParse(_longitudeConfigurada);
    if (!Sessao.logado &&
        (latitude == null ||
            longitude == null ||
            latitude < -90 ||
            latitude > 90 ||
            longitude < -180 ||
            longitude > 180)) {
      setState(() {
        _carregando = false;
        _erroApi = 'Configure coordenadas autorizadas para a busca.';
        _excedentesApi = [];
      });
      return;
    }
    setState(() {
      _carregando = true;
      _erroApi = null;
    });
    try {
      final resultados = await _api.buscar(
        FiltrosExcedentesApi(
          latitude: Sessao.logado ? null : latitude,
          longitude: Sessao.logado ? null : longitude,
          raioKm: _raioKm,
          categoria: _categoria,
          modalidade: _tipo,
          busca: _buscaController.text,
        ),
      );
      final produtos = resultados.map(ExcedenteCult.fromApi).toList();
      if (!mounted || versao != _versaoConsulta) return;
      setState(() {
        _excedentesApi = produtos;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted || versao != _versaoConsulta) return;
      setState(() {
        _erroApi = erro is FormatException
            ? 'O servidor retornou um produto inválido.'
            : erro.toString();
        _excedentesApi = [];
        _carregando = false;
      });
    }
  }

  void _atualizarBusca() {
    setState(() {});
    if (!_usarApi) return;
    _debounceBusca?.cancel();
    _debounceBusca = Timer(
      const Duration(milliseconds: 350),
      _carregarExcedentes,
    );
  }

  @override
  void dispose() {
    _debounceBusca?.cancel();
    ++_versaoConsulta;
    _buscaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _distancia(double valor) =>
      valor.toStringAsFixed(1).replaceAll('.', ',');

  List<ExcedenteCult> get _filtrados {
    if (_usarApi) return _excedentesApi;
    final termo = _buscaController.text.trim().toLowerCase();
    return widget.excedentes.where((produto) {
      final correspondeBusca = produto.nome.toLowerCase().contains(termo);
      final correspondeCategoria =
          _categoria == 'Todas' || produto.categoria == _categoria;
      final correspondeRaio = produto.distanciaKm <= _raioKm;
      final correspondeTipo =
          _tipo == 'Todos' ||
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
    if (Sessao.logado) {
      final alterou = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const EditarPerfilPage(editarLocalizacao: true),
        ),
      );
      if (!mounted || alterou != true) return;
      setState(() {
        _localizacao = Sessao.usuario?['bairro']?.toString() ?? _localizacao;
        _mostrarTodasOfertas = false;
      });
      await _carregarExcedentes();
      return;
    }
    _mensagem('Entre na sua conta para alterar sua localização.');
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
                        onSelected: (_) =>
                            atualizarModal(() => raioTemporario = raio),
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
                        onSelected: (_) =>
                            atualizarModal(() => tipoTemporario = tipo),
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
                        _carregarExcedentes();
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

  Future<void> _registrarInteresse(ExcedenteCult produto) async {
    if (_enviandoInteresse || produto.id == null || !Sessao.logado) {
      _mensagem('Faça login e selecione uma oferta real para se conectar.');
      return;
    }
    setState(() => _enviandoInteresse = true);
    try {
      // Só apresenta a confirmação após o backend retornar HTTP 201.
      final conexao = await ConexaoService.criar(
        excedenteId: produto.id!,
        raioKm: _raioKm,
        categoria: _categoria == 'Todas' ? null : _categoria,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ConexaoConfirmadaPage(
            nomeOfertante: conexao.nomeOfertante,
            nomeProduto: conexao.nomeProduto,
            quantidade: conexao.quantidadeFormatada,
            localizacao: conexao.localizacao,
            distanciaKm: conexao.distanciaKm,
            ehDoacao: conexao.ehDoacao,
            emojiProduto: produto.emoji,
            avaliacaoOfertante: conexao.avaliacaoOfertante,
            totalAvaliacoes: conexao.totalAvaliacoes,
            onVoltarBusca: () => Navigator.of(context).pop(),
            onAbrirChat: () => _mensagem(
              'Chat deste match ainda precisa ser conectado ao módulo Conversas.',
            ),
          ),
        ),
      );
    } on ErroConexao catch (erro) {
      if (mounted) _mensagem(erro.mensagem);
    } finally {
      if (mounted) setState(() => _enviandoInteresse = false);
    }
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
                    _registrarInteresse(produto);
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

  // Reduz repetição visual por nome sem apagar ofertas distintas do banco.
  List<ExcedenteCult> _ofertasVisiveis(List<ExcedenteCult> produtos) {
    if (_mostrarTodasOfertas) return produtos;
    final vistos = <String>{};
    return produtos
        .where(
          (p) => vistos.add('${p.categoria}|${p.nome.toLowerCase().trim()}'),
        )
        .toList();
  }

  Widget _expandirOfertas(int total, int exibidas) {
    if (total == exibidas) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$total ofertas encontradas · $exibidas produtos diferentes',
              style: const TextStyle(fontSize: 12, color: cinza),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _mostrarTodasOfertas = true),
            child: const Text(
              'Ver todas',
              style: TextStyle(color: verde, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagemProduto(ExcedenteCult produto, {double tamanho = 78}) {
    //se o excedente tem foto real mostra ela no lugar do desenho
    final foto = produto.foto;
    if (foto != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Image.memory(
          //tira o comeco data:image/...;base64, e transforma o texto em imagem
          base64Decode(foto.split(',').last),
          width: tamanho,
          height: tamanho,
          fit: BoxFit.cover,
          //evita a foto piscar quando a lista atualiza
          gaplessPlayback: true,
        ),
      );
    }
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
                    onChanged: (_) => _atualizarBusca(),
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
                                _atualizarBusca();
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
                    child: Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
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
            onSelected: (_) {
              setState(() => _categoria = nome);
              _carregarExcedentes();
            },
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
              _carregarExcedentes();
            },
            child: const Text('Limpar filtros', style: TextStyle(color: verde)),
          ),
        ],
      ),
    );
  }

  Widget _situacaoApi() {
    if (!_usarApi) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(22, 0, 22, 8),
        child: Text(
          'Produtos de demonstração',
          style: TextStyle(fontSize: 12, color: cinza),
        ),
      );
    }
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.all(25),
        child: Center(child: CircularProgressIndicator(color: verde)),
      );
    }
    if (_erroApi != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_outlined, size: 35, color: cinza),
            const SizedBox(height: 8),
            Text(_erroApi!, textAlign: TextAlign.center),
            TextButton(
              onPressed: _carregarExcedentes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_apiDemonstracao) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(22, 0, 22, 8),
        child: Text(
          'Resposta de API demonstrativa (sem MongoDB)',
          style: TextStyle(fontSize: 12, color: cinza),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _tocarNavegacao(VoidCallback? callback, String nome) {
    // Mantém a navegação fornecida pelo aplicativo, quando disponível.
    if (callback != null) {
      callback();
      return;
    }

    // Navegação padrão para as telas que já existem no projeto.
    // Ao navegar de uma sessão real, usa os dados públicos do login.
    final usuario = Sessao.usuario;
    final Widget? pagina = switch (nome) {
      'Publicar' => const PublicarPage(),
      'Conversas' => const ConversasPage(),
      'Perfil' => PerfilPage(
        usuario: UsuarioPerfil(
          nome: usuario?['nome']?.toString() ?? 'Usuário de demonstração',
          email: usuario?['email']?.toString() ?? 'Sem autenticação',
          tipoUsuario: switch (usuario?['perfil']) {
            'ofertante' => 'Ofertante',
            'ambos' => 'Ambos',
            _ => 'Interessado',
          },
          localizacao: usuario?['bairro']?.toString() ?? 'Jardim das Flores',
        ),
      ),
      _ => null,
    };

    if (pagina == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => pagina));
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
              Icon(icone, size: 28, color: selecionado ? verde : Colors.grey),
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
    final visiveis = _ofertasVisiveis(produtos);
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
            SliverToBoxAdapter(child: _situacaoApi()),
            if (!_carregando && _erroApi == null && produtos.isNotEmpty)
              SliverToBoxAdapter(
                child: _expandirOfertas(produtos.length, visiveis.length),
              ),
            if (!_carregando && _erroApi == null && produtos.isEmpty)
              SliverToBoxAdapter(child: _semResultados())
            else if (!_carregando && _erroApi == null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _cardProduto(visiveis[index]),
                    childCount: visiveis.length,
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
