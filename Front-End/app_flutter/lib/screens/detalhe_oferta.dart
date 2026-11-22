/*
 * Autores:
 * Henrique Leite de Camargo - RA: 25005997
 * Rafaela Jacobsen Braga - RA: 25004280
 * Data: 18/11/2026
 */
import 'package:flutter/material.dart';

import 'conexao_confirmada.dart';

class DetalheOfertaPage extends StatelessWidget {
  final String produto;
  final String emojiProduto;
  final String categoria;
  final String emojiCategoria;
  final String quantidade;
  final String bairro;
  final double distanciaKm;
  final String descricao;
  final bool ehDoacao;
  final String nomeOfertante;
  final String emojiOfertante;
  final double? avaliacaoOfertante;
  final int totalAvaliacoes;
  final bool mostrarInteresse;
  final VoidCallback? onTenhoInteresse;

  const DetalheOfertaPage({
    super.key,
    this.produto = 'Manga Tommy',
    this.emojiProduto = '🥭',
    this.categoria = 'Frutas',
    this.emojiCategoria = '🍎',
    this.quantidade = '~5 kg',
    this.bairro = 'Jardim das Flores',
    this.distanciaKm = 1.2,
    this.descricao =
        'Mangas colhidas hoje, quintal com sombra parcial. Ideal para consumo imediato ou doces caseiros.',
    this.ehDoacao = true,
    this.nomeOfertante = 'Roberto C.',
    this.emojiOfertante = '🧑🏽‍🌾',
    this.avaliacaoOfertante = 4.8,
    this.totalAvaliacoes = 12,
    this.mostrarInteresse = true,
    this.onTenhoInteresse,
  });

  static const Color verde = Color(0xFF267536);
  static const Color verdeEscuro = Color(0xFF2E7D32);
  static const Color laranja = Color(0xFFF47700);
  static const Color fundo = Color(0xFFF7F8F2);
  static const Color cinza = Color(0xFF929A91);
  static const Color textoEscuro = Color(0xFF20251F);
  static const Color fundoClaro = Color(0xFFE4F2E6);

  static const double alturaHero = 300;
  static const double sobreposicao = 30;

  String get distanciaFormatada =>
      distanciaKm.toStringAsFixed(1).replaceAll('.', ',');

  String get avaliacaoFormatada =>
      avaliacaoOfertante?.toStringAsFixed(1).replaceAll('.', ',') ?? '';

  void _tenhoInteresse(BuildContext context) {
    if (onTenhoInteresse != null) {
      onTenhoInteresse!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConexaoConfirmadaPage(
          nomeOfertante: nomeOfertante,
          nomeProduto: produto,
          quantidade: quantidade,
          localizacao: bairro,
          distanciaKm: distanciaKm,
          ehDoacao: ehDoacao,
          emojiProduto: emojiProduto,
          avaliacaoOfertante: avaliacaoOfertante,
          totalAvaliacoes: totalAvaliacoes,
        ),
      ),
    );
  }

  Widget _botaoCircular({
    required IconData icone,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: fundo,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icone, size: 20, color: textoEscuro),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      height: alturaHero,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA3D2A6), Color(0xFF5DA063)],
        ),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(emojiProduto, style: const TextStyle(fontSize: 130)),
    );
  }

  Widget _selo() {
    final texto = ehDoacao ? '🎁 Doação' : '💰 Venda';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: verdeEscuro,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _informacoes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  produto,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: textoEscuro,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: fundoClaro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$emojiCategoria $categoria',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: verdeEscuro,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text('⚖️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                quantidade,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textoEscuro,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'disponíveis',
                style: TextStyle(fontSize: 16, color: cinza),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  bairro,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, color: cinza),
                ),
              ),
              Text(
                ' · $distanciaFormatada km',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textoEscuro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            descricao,
            style: const TextStyle(fontSize: 16, height: 1.45, color: cinza),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFE7EAE3), height: 1),
          const SizedBox(height: 16),
          _ofertante(),
        ],
      ),
    );
  }

  Widget _ofertante() {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: fundoClaro,
            shape: BoxShape.circle,
          ),
          child: Text(emojiOfertante, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nomeOfertante,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textoEscuro,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (avaliacaoOfertante != null)
                    const Text(
                      '★★★★★',
                      style: TextStyle(fontSize: 15, color: Color(0xFFF5A623)),
                    ),
                  if (avaliacaoOfertante != null) const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      avaliacaoOfertante == null
                          ? 'Sem avaliações'
                          : '$avaliacaoFormatada · $totalAvaliacoes avaliações',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: cinza),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: cinza),
      ],
    );
  }

  Widget _rodape(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7EAE3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _tenhoInteresse(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: laranja,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                '🤝 Tenho interesse',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Você será conectado ao ofertante após manifestar interesse.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cinza),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(top: 0, left: 0, right: 0, child: _hero(context)),
          Positioned(
            top: alturaHero - sobreposicao,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Column(
                  children: [
                    Expanded(child: _informacoes()),
                    if (mostrarInteresse) _rodape(context),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: alturaHero - sobreposicao - 26,
            left: 20,
            child: _selo(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _botaoCircular(
                      icone: Icons.arrow_back,
                      onTap: () => Navigator.maybePop(context),
                    ),
                    _botaoCircular(icone: Icons.ios_share, onTap: null),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
