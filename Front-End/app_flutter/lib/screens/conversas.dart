/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */
import 'package:flutter/material.dart';

import 'chat.dart';

class ConversaItem {
  final String nome;
  final String papel;
  final String emojiAvatar;
  final String emojiProduto;
  final String produto;
  final String detalheOferta;
  final double avaliacao;
  final String ultimaMensagem;
  final String hora;

  const ConversaItem({
    required this.nome,
    required this.papel,
    required this.emojiAvatar,
    required this.emojiProduto,
    required this.produto,
    required this.detalheOferta,
    required this.avaliacao,
    required this.ultimaMensagem,
    required this.hora,
  });
}

class ConversasPage extends StatelessWidget {
  final List<ConversaItem> conversas;

  const ConversasPage({
    super.key,
    this.conversas = const [
      ConversaItem(
        nome: 'Roberto C.',
        papel: 'Ofertante',
        emojiAvatar: '🧑🏽‍🌾',
        emojiProduto: '🥭',
        produto: 'Manga Tommy',
        detalheOferta: '🎁 Doação · ~5 kg · 1,2 km',
        avaliacao: 4.8,
        ultimaMensagem: 'Combinado, obrigado! 🙌',
        hora: '9:41',
      ),
    ],
  });

  static const Color verde = Color(0xFF267536);
  static const Color fundo = Color(0xFFF7F8F2);
  static const Color cinza = Color(0xFF929A91);
  static const Color textoEscuro = Color(0xFF20251F);
  static const Color fundoAvatar = Color(0xFFE4F2E6);

  void _abrirChat(BuildContext context, ConversaItem conversa) {
    Navigator.push(
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
        ),
      ),
    );
  }

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
              child: Text(conversa.emojiAvatar, style: const TextStyle(fontSize: 26)),
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
            Text(conversa.hora, style: const TextStyle(fontSize: 12, color: cinza)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
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
                child: conversas.isEmpty
                    ? const Center(
                        child: Text(
                          'Você ainda não tem conversas.\nConecte-se a uma oferta para começar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: cinza),
                        ),
                      )
                    : ListView.separated(
                        itemCount: conversas.length,
                        separatorBuilder: (context, indice) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, indice) =>
                            _item(context, conversas[indice]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
