/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */
import 'package:flutter/material.dart';

import 'detalhe_oferta.dart';

class MensagemChat {
  final String texto;
  final bool minha;
  final String hora;

  const MensagemChat({
    required this.texto,
    required this.minha,
    required this.hora,
  });
}

class ChatPage extends StatefulWidget {
  final String nomeOutro;
  final String papelOutro;
  final double avaliacaoOutro;
  final String emojiAvatar;
  final String emojiProduto;
  final String produto;
  final String detalheOferta;
  final String avisoConexao;
  final List<MensagemChat> mensagensIniciais;
  final ValueChanged<String>? onEnviarMensagem;
  final VoidCallback? onVerOferta;

  const ChatPage({
    super.key,
    this.nomeOutro = 'Roberto C.',
    this.papelOutro = 'Ofertante',
    this.avaliacaoOutro = 4.8,
    this.emojiAvatar = '🧑🏽‍🌾',
    this.emojiProduto = '🥭',
    this.produto = 'Manga Tommy',
    this.detalheOferta = '🎁 Doação · ~5 kg · 1,2 km',
    this.avisoConexao = '🤝 Conexão confirmada · combinem a retirada ou entrega',
    this.mensagensIniciais = const [
      MensagemChat(
        texto: 'Oi, Roberto! Tenho interesse nas mangas 😊',
        minha: true,
        hora: '9:38',
      ),
      MensagemChat(
        texto: 'Oi! Que bom! Colhi hoje cedo, ainda tem bastante.',
        minha: false,
        hora: '9:39',
      ),
      MensagemChat(
        texto: 'Posso retirar amanhã às 9h, aí na sua casa?',
        minha: true,
        hora: '9:40',
      ),
      MensagemChat(
        texto: 'Pode sim! Te envio o endereço certinho por aqui.',
        minha: false,
        hora: '9:41',
      ),
      MensagemChat(
        texto: 'Combinado, obrigado! 🙌',
        minha: true,
        hora: '9:41',
      ),
    ],
    this.onEnviarMensagem,
    this.onVerOferta,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color verde = Color(0xFF267536);
  static const Color verdeEscuro = Color(0xFF2E7D32);
  static const Color laranja = Color(0xFFF47700);
  static const Color fundo = Color(0xFFF7F8F2);
  static const Color cinza = Color(0xFF929A91);
  static const Color textoEscuro = Color(0xFF20251F);
  static const Color fundoAviso = Color(0xFFE4F2E6);

  final TextEditingController _campoController = TextEditingController();
  final ScrollController _rolagemController = ScrollController();
  late final List<MensagemChat> _mensagens;

  @override
  void initState() {
    super.initState();
    _mensagens = List<MensagemChat>.of(widget.mensagensIniciais);
  }

  @override
  void dispose() {
    _campoController.dispose();
    _rolagemController.dispose();
    super.dispose();
  }

  String _horaAgora() {
    final agora = TimeOfDay.now();
    final minuto = agora.minute.toString().padLeft(2, '0');
    return '${agora.hour}:$minuto';
  }

  void _enviar() {
    final texto = _campoController.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add(MensagemChat(texto: texto, minha: true, hora: _horaAgora()));
    });
    _campoController.clear();
    widget.onEnviarMensagem?.call(texto);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_rolagemController.hasClients) return;
      _rolagemController.animateTo(
        _rolagemController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _cabecalho(BuildContext context) {
    final avaliacao = widget.avaliacaoOutro.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7EAE3))),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: fundo,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: textoEscuro),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: fundoAviso,
              shape: BoxShape.circle,
            ),
            child: Text(widget.emojiAvatar, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nomeOutro,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textoEscuro,
                  ),
                ),
                Text(
                  '${widget.papelOutro} · ★ $avaliacao',
                  style: const TextStyle(fontSize: 13, color: cinza),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _verOferta() {
    if (widget.onVerOferta != null) {
      widget.onVerOferta!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalheOfertaPage(
          produto: widget.produto,
          emojiProduto: widget.emojiProduto,
          nomeOfertante: widget.nomeOutro,
          emojiOfertante: widget.emojiAvatar,
          avaliacaoOfertante: widget.avaliacaoOutro,
          mostrarInteresse: false,
        ),
      ),
    );
  }

  Widget _cartaoOferta() {
    return InkWell(
      onTap: _verOferta,
      borderRadius: BorderRadius.circular(18),
      child: _conteudoCartaoOferta(),
    );
  }

  Widget _conteudoCartaoOferta() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(widget.emojiProduto, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.produto,
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
                  widget.detalheOferta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: cinza),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _verOferta,
            child: const Text(
              'Ver oferta ›',
              style: TextStyle(color: verde, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avisoConexao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fundoAviso,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        widget.avisoConexao,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: verdeEscuro,
        ),
      ),
    );
  }

  Widget _balao(MensagemChat mensagem) {
    final minha = mensagem.minha;
    final larguraMaxima = MediaQuery.of(context).size.width * 0.76;

    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: larguraMaxima),
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            color: minha ? verdeEscuro : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(minha ? 20 : 4),
              bottomRight: Radius.circular(minha ? 4 : 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  mensagem.texto,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: minha ? Colors.white : textoEscuro,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mensagem.hora,
                style: TextStyle(
                  fontSize: 12,
                  color: minha ? Colors.white70 : cinza,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoDeEnvio() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7EAE3))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _campoController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _enviar(),
              maxLength: 1000,
              maxLines: null,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Digite uma mensagem...',
                hintStyle: const TextStyle(color: cinza),
                filled: true,
                fillColor: fundo,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: laranja,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _enviar,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            _cabecalho(context),
            Expanded(
              child: ListView(
                controller: _rolagemController,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  _cartaoOferta(),
                  const SizedBox(height: 12),
                  _avisoConexao(),
                  for (final mensagem in _mensagens) _balao(mensagem),
                ],
              ),
            ),
            _campoDeEnvio(),
          ],
        ),
      ),
    );
  }
}
