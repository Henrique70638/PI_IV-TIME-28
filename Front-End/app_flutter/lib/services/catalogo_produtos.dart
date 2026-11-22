// Autor: Rafaela Jacobsen Braga - RA: 25004280

import 'package:flutter/material.dart';

class ProdutoCatalogo {
  final String nome;
  final String categoria;
  final String emoji;

  const ProdutoCatalogo(this.nome, this.categoria, this.emoji);
}

/// Ilustrações disponíveis para apresentação; não representam fotos de estoque.
class CatalogoProdutos {
  static const opcoes = <ProdutoCatalogo>[
    ProdutoCatalogo('Manga', 'frutas', '🥭'),
    ProdutoCatalogo('Banana', 'frutas', '🍌'),
    ProdutoCatalogo('Laranja', 'frutas', '🍊'),
    ProdutoCatalogo('Limão', 'frutas', '🍋'),
    ProdutoCatalogo('Maçã', 'frutas', '🍎'),
    ProdutoCatalogo('Morango', 'frutas', '🍓'),
    ProdutoCatalogo('Uva', 'frutas', '🍇'),
    ProdutoCatalogo('Melancia', 'frutas', '🍉'),
    ProdutoCatalogo('Abacaxi', 'frutas', '🍍'),
    ProdutoCatalogo('Pera', 'frutas', '🍐'),
    ProdutoCatalogo('Alface', 'verduras', '🥬'),
    ProdutoCatalogo('Couve', 'verduras', '🥬'),
    ProdutoCatalogo('Brócolis', 'verduras', '🥦'),
    ProdutoCatalogo('Tomate', 'legumes', '🍅'),
    ProdutoCatalogo('Cenoura', 'legumes', '🥕'),
    ProdutoCatalogo('Pepino', 'legumes', '🥒'),
    ProdutoCatalogo('Batata', 'legumes', '🥔'),
    ProdutoCatalogo('Milho', 'legumes', '🌽'),
    ProdutoCatalogo('Pimentão', 'legumes', '🫑'),
    ProdutoCatalogo('Berinjela', 'legumes', '🍆'),
    ProdutoCatalogo('Muda de planta', 'mudas', '🪴'),
  ];

  static String ilustracao(String nome, String categoria) {
    final texto = nome.toLowerCase().trim();
    for (final produto in opcoes) {
      if (texto.contains(produto.nome.toLowerCase())) return produto.emoji;
    }
    // Alguns plurais e nomes populares não seguem a grafia do catálogo.
    if (texto.contains('muda') || categoria == 'mudas') return '🪴';
    if (texto.contains('mamao') || texto.contains('mamão')) return '🍈';
    if (texto.contains('abacate')) return '🥑';
    if (texto.contains('cebola')) return '🧅';
    if (texto.contains('alho')) return '🧄';
    if (texto.contains('rucula') || texto.contains('rúcula')) return '🥬';
    return switch (categoria.toLowerCase()) {
      'frutas' => '🍏',
      'verduras' => '🥬',
      'legumes' => '🥕',
      _ => '🌱',
    };
  }

  static Color fundo(String categoria) => switch (categoria.toLowerCase()) {
    'frutas' => const Color(0xFFFFE6AC),
    'verduras' => const Color(0xFFE0F2D5),
    'legumes' => const Color(0xFFFFE3C7),
    _ => const Color(0xFFE2EFDA),
  };
}
