/*
 * Autores:
 * Henrique Leite de Camargo - RA: 25005997
 * Rafaela Jacobsen Braga - RA: 25004280
 * Data: 18/11/2026
 */
import 'package:flutter/material.dart';

import 'chat.dart';
import 'inicio.dart';
import 'perfil.dart';
import 'publicar.dart';
import '../services/sessao.dart';
import '../services/conversas_service.dart';
import '../services/catalogo_produtos.dart';

// uma linha da lista de conversas, ja pronta para mostrar na tela
class ConversaItem {
  final String? matchId;
  final String? status;
  final String nome;
  final String papel;
  final String emojiAvatar;
  final String emojiProduto;
  final String produto;
  final String detalheOferta;
  final double? avaliacao;
  final String ultimaMensagem;
  final String hora;

  const ConversaItem({
    this.matchId,
    this.status,
    required this.nome,
    required this.papel,
    required this.emojiAvatar,
    required this.emojiProduto,
    required this.produto,
    required this.detalheOferta,
    this.avaliacao,
    required this.ultimaMensagem,
    required this.hora,
  });

  // converte a conversa recebida da API: formata a quantidade, a unidade,
  // o tipo (doacao ou venda) e a hora da ultima mensagem
  factory ConversaItem.fromApi(ConversaRemota dados) {
    final simbolo = CatalogoProdutos.ilustracao(dados.produto, dados.categoria);
    final valor = dados.quantidade.toDouble() == dados.quantidade.toInt()
        ? dados.quantidade.toInt().toString()
        : dados.quantidade.toString();
    final unidade = switch (dados.unidade) {
      'un' => 'unidades',
      'maco' => 'maços',
      'muda' => 'mudas',
      _ => dados.unidade,
    };
    final data = dados.ultimaMensagemEm;
    final hora = data == null
        ? ''
        : '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    return ConversaItem(
      matchId: dados.id,
      status: dados.status,
      nome: dados.outroNome,
      papel: dados.papelDoOutro == 'ofertante' ? 'Ofertante' : 'Interessado',
      emojiAvatar: '👤',
      emojiProduto: simbolo,
      produto: dados.produto,
      detalheOferta:
          '${dados.modalidade == 'doacao' ? '🎁 Doação' : '💰 Venda'} · ~$valor $unidade',
      avaliacao: null,
      ultimaMensagem: dados.ultimaMensagem ?? 'Conexão confirmada',
      hora: hora,
    );
  }
}

// tela com a lista de conversas do usuario; busca na API e mostra exemplos
// de apresentacao abaixo da lista real
class ConversasPage extends StatefulWidget {
  // Lista opcional destinada a testes de interface; no aplicativo real, usamos a API.
  final List<ConversaItem>? conversas;
  final ConversasService? api;

  const ConversasPage({super.key, this.conversas, this.api});

  @override
  State<ConversasPage> createState() => _ConversasPageState();
}

// estado da tela: conversas carregadas, carregamento e erro
class _ConversasPageState extends State<ConversasPage> {
  static const Color verde = Color(0xFF267536);
  static const Color fundo = Color(0xFFF7F8F2);
  static const Color cinza = Color(0xFF929A91);
  static const Color textoEscuro = Color(0xFF20251F);
  static const Color fundoAvatar = Color(0xFFE4F2E6);

  late List<ConversaItem> _conversas;
  bool _carregando = false;
  String? _erro;
  // cada carregamento ganha um numero; resposta de um carregamento antigo e descartada
  int _versao = 0;

  // se nao vieram conversas prontas, carrega da API depois do primeiro frame
  @override
  void initState() {
    super.initState();
    _conversas = widget.conversas ?? [];
    if (widget.conversas == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _carregar();
      });
    }
  }

  // busca a lista na API e converte cada conversa em ConversaItem
  Future<void> _carregar() async {
    final versao = ++_versao;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await (widget.api ?? ConversasService()).listar();
      if (!mounted || versao != _versao) return;
      setState(() {
        _conversas = lista.map(ConversaItem.fromApi).toList();
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted || versao != _versao) return;
      setState(() {
        _erro = erro.toString();
        _carregando = false;
      });
    }
  }

  // abre o chat da conversa e, ao voltar, recarrega a lista para mostrar a ultima mensagem
  Future<void> _abrirChat(BuildContext context, ConversaItem conversa) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          nomeOutro: conversa.nome,
          papelOutro: conversa.papel,
          avaliacaoOutro: conversa.avaliacao,
          emojiAvatar: conversa.emojiAvatar,
          emojiProduto: conversa.emojiProduto,
          produto: conversa.produto,
          detalheOferta: conversa.detalheOferta,
          matchId: conversa.matchId,
          mensagensIniciais: const [],
          api: widget.api,
        ),
      ),
    );
    if (mounted && widget.conversas == null) await _carregar();
  }

  // uma linha da lista: avatar, nome, produto e ultima mensagem
  Widget _item(BuildContext context, ConversaItem conversa) {
    return InkWell(
      onTap: () => _abrirChat(context, conversa),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: fundoAvatar,
                shape: BoxShape.circle,
              ),
              child: Text(
                conversa.emojiAvatar,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversa.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textoEscuro,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${conversa.emojiProduto} ${conversa.produto}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: verde,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conversa.ultimaMensagem,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: cinza),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              conversa.hora,
              style: const TextStyle(fontSize: 12, color: cinza),
            ),
          ],
        ),
      ),
    );
  }

  // Exemplos exclusivos de apresentação; nunca são enviados ao MongoDB.
  static const List<ConversaItem> _exemplos = [
    ConversaItem(
      nome: 'Marina',
      papel: 'Ofertante',
      emojiAvatar: '👩🏽',
      emojiProduto: '🍌',
      produto: 'Banana prata',
      detalheOferta: '🎁 Doação · ~2 kg',
      ultimaMensagem: 'Oi! Podemos combinar a retirada?',
      hora: '10:24',
    ),
    ConversaItem(
      nome: 'Pedro',
      papel: 'Interessado',
      emojiAvatar: '👨🏽',
      emojiProduto: '🥬',
      produto: 'Alface',
      detalheOferta: '🎁 Doação · ~3 unidades',
      ultimaMensagem: 'Obrigado pela oferta!',
      hora: 'Ontem',
    ),
  ];

  // abre o chat de um exemplo, sem usar a API
  Future<void> _abrirExemplo(ConversaItem conversa) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          nomeOutro: conversa.nome,
          papelOutro: conversa.papel,
          emojiAvatar: conversa.emojiAvatar,
          emojiProduto: conversa.emojiProduto,
          produto: conversa.produto,
          detalheOferta: conversa.detalheOferta,
          avisoConexao: 'Demonstração · mensagens não são salvas nem enviadas',
          mensagensIniciais: [
            MensagemChat(
              texto: conversa.ultimaMensagem,
              minha: false,
              hora: conversa.hora,
            ),
          ],
          onEnviarMensagem:
              (_) {}, // O chat local permite demonstrar a digitação.
        ),
      ),
    );
  }

  // lista os exemplos de apresentacao
  Widget _secaoExemplos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final exemplo in _exemplos)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _abrirExemplo(exemplo),
              borderRadius: BorderRadius.circular(18),
              child: _cartaoExemplo(exemplo),
            ),
          ),
      ],
    );
  }

  // visual de um exemplo, igual ao de uma conversa real
  Widget _cartaoExemplo(ConversaItem conversa) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: fundoAvatar,
              shape: BoxShape.circle,
            ),
            child: Text(
              conversa.emojiAvatar,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversa.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textoEscuro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${conversa.emojiProduto} ${conversa.produto}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: verde,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conversa.ultimaMensagem,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: cinza),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            conversa.hora,
            style: const TextStyle(fontSize: 12, color: cinza),
          ),
        ],
      ),
    );
  }

  // Mantém o menu inferior entre as telas sem modificar a conversa aberta.
  void _navegar(BuildContext context, Widget pagina) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => pagina));
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

  // menu de baixo para trocar entre as telas do app
  Widget _barraInferior(BuildContext context) {
    final dados = Sessao.usuario;
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
                selecionado: false,
                aoTocar: () => _navegar(context, const InicioPage()),
              ),
              _itemNavegacao(
                icone: Icons.add,
                texto: 'Publicar',
                selecionado: false,
                aoTocar: () => _navegar(context, const PublicarPage()),
              ),
              _itemNavegacao(
                icone: Icons.chat_bubble_outline,
                texto: 'Conversas',
                selecionado: true,
                aoTocar: () {},
              ),
              _itemNavegacao(
                icone: Icons.person,
                texto: 'Perfil',
                selecionado: false,
                aoTocar: () => _navegar(
                  context,
                  PerfilPage(
                    usuario: UsuarioPerfil(
                      nome: (dados?['nome'] ?? 'Usuário').toString(),
                      email: (dados?['email'] ?? '').toString(),
                      tipoUsuario: (dados?['perfil'] ?? 'Interessado')
                          .toString(),
                      localizacao: (dados?['bairro'] ?? dados?['cidade'] ?? '')
                          .toString(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // monta a tela: titulo, lista (ou carregando/erro/vazio), exemplos e menu de baixo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      bottomNavigationBar: _barraInferior(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Conversas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textoEscuro,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _carregando && _conversas.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _erro != null && _conversas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_erro!, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: _carregar,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregar,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            if (_conversas.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'Você ainda não tem conversas reais.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: cinza),
                                ),
                              ),
                            for (final conversa in _conversas)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _item(context, conversa),
                              ),
                            if (widget.conversas == null) _secaoExemplos(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
