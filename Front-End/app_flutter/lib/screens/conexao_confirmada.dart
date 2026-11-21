// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'package:flutter/material.dart';

import 'conversas.dart';
import 'inicio.dart';

class ConexaoConfirmadaPage extends StatelessWidget {
  final String nomeOfertante;
  final String nomeProduto;
  final String quantidade;
  final String localizacao;
  final double distanciaKm;
  final bool ehDoacao;
  final String emojiProduto;
  final double? avaliacaoOfertante;
  final int? totalAvaliacoes;

  // Callbacks opcionais para integrar futuramente o chat específico do match
  // e a navegação do aplicativo, sem alterar a aparência desta tela.
  final VoidCallback? onAbrirChat;
  final VoidCallback? onVoltarBusca;

  const ConexaoConfirmadaPage({
    super.key,
    this.nomeOfertante = 'Roberto C.',
    this.nomeProduto = 'Manga Tommy',
    this.quantidade = '~5 kg',
    this.localizacao = 'Jardim das Flores',
    this.distanciaKm = 1.2,
    this.ehDoacao = true,
    this.emojiProduto = '🥭',
    this.avaliacaoOfertante = 4.8,
    this.totalAvaliacoes = 12,
    this.onAbrirChat,
    this.onVoltarBusca,
  });

  // Mesma identidade visual já utilizada pelas telas do grupo.
  static const Color verde = Color(0xFF267536);
  static const Color verdeEscuro = Color(0xFF206D31);
  static const Color laranja = Color(0xFFF47700);
  static const Color fundo = Color(0xFFF7F8F2);
  static const Color cinza = Color(0xFF929A91);
  static const Color textoEscuro = Color(0xFF20251F);
  static const Color fundoContato = Color(0xFFE4F2E6);

  String get distanciaFormatada =>
      distanciaKm.toStringAsFixed(1).replaceAll('.', ',');

  void abrirChat(BuildContext context) {
    if (onAbrirChat != null) {
      onAbrirChat!();
      return;
    }

    // Integração provisória: abre a tela de conversas já prevista pelo grupo.
    // O chat direto com este ofertante exigirá um ID de conversa do backend.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConversasPage()),
    );
  }

  void voltarBusca(BuildContext context) {
    if (onVoltarBusca != null) {
      onVoltarBusca!();
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const InicioPage()),
      (route) => false,
    );
  }

  Widget avatarCircular({required String emoji, required double tamanho}) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2F2E7), width: 5),
        boxShadow: [
          BoxShadow(
            color: verde.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Text(emoji, style: TextStyle(fontSize: tamanho * 0.49)),
    );
  }

  Widget ilustracaoConexao() {
    return SizedBox(
      height: 140,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth;
          final tamanhoLateral = (largura * 0.28).clamp(72.0, 102.0).toDouble();
          final tamanhoCentral = (largura * 0.30).clamp(78.0, 108.0).toDouble();

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: tamanhoLateral * 0.6,
                right: tamanhoLateral * 0.6,
                top: 68,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    17,
                    (_) => Container(
                      width: 7,
                      height: 4,
                      decoration: BoxDecoration(
                        color: verde,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  avatarCircular(emoji: '🧑🏽‍🌾', tamanho: tamanhoLateral),
                  Container(
                    width: tamanhoCentral,
                    height: tamanhoCentral,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF249E53),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4ECDD),
                        width: 10,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: verde.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      '🤝',
                      style: TextStyle(fontSize: tamanhoCentral * 0.43),
                    ),
                  ),
                  avatarCircular(emoji: '🙋🏻‍♀️', tamanho: tamanhoLateral),
                ],
              ),
              Positioned(
                left: tamanhoLateral * 0.02,
                top: 3,
                child: const Text('✨', style: TextStyle(fontSize: 28)),
              ),
              Positioned(
                right: tamanhoLateral * 0.03,
                top: 1,
                child: const Text('🎉', style: TextStyle(fontSize: 28)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget imagemProduto() {
    return Container(
      width: 78,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBDD88), Color(0xFFF5AF49)],
        ),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Text(emojiProduto, style: const TextStyle(fontSize: 43)),
    );
  }

  Widget cardProduto() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          imagemProduto(),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeProduto,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textoEscuro,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${ehDoacao ? '🎁 Doação' : '💰 Venda'} · $quantidade',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: cinza, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '📍 $localizacao · $distanciaFormatada km',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: cinza, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cardContato() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
      decoration: BoxDecoration(
        color: fundoContato,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Container(
            width: 61,
            height: 61,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🧑🏽‍🌾', style: TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interesse registrado',
                  style: TextStyle(
                    color: verdeEscuro,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  nomeOfertante,
                  style: const TextStyle(
                    color: textoEscuro,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                if (avaliacaoOfertante != null && totalAvaliacoes != null)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 7,
                    runSpacing: 3,
                    children: [
                      const Text('★★★★★',
                          style: TextStyle(fontSize: 16, color: Color(0xFFF5A623))),
                      Text('${avaliacaoOfertante?.toStringAsFixed(1)} · '
                          '$totalAvaliacoes avaliações',
                          style: const TextStyle(fontSize: 13, color: cinza)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget barraAcoes(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton.icon(
                onPressed: () => abrirChat(context),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24),
                label: const Text(
                  'Abrir chat',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: laranja,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: laranja.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 9),
            SizedBox(
              height: 42,
              child: TextButton(
                onPressed: () => voltarBusca(context),
                style: TextButton.styleFrom(foregroundColor: verdeEscuro),
                child: const Text(
                  'Voltar à busca',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),
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
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
          child: Column(
            children: [
              const SizedBox(height: 21),
              ilustracaoConexao(),
              const SizedBox(height: 31),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Conexão confirmada!',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color: textoEscuro,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Você e $nomeOfertante foram conectados. '
                'O interesse foi registrado no sistema.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7B827A),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 37),
              cardProduto(),
              const SizedBox(height: 16),
              cardContato(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: barraAcoes(context),
    );
  }
}
