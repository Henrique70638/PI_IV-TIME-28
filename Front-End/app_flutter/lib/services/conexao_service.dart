// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api.dart';
import 'sessao.dart';

class ErroConexao implements Exception {
  final String mensagem;
  const ErroConexao(this.mensagem);

  @override
  String toString() => mensagem;
}

class DadosConexao {
  final String id;
  final String nomeOfertante;
  final String nomeProduto;
  final num quantidade;
  final String unidade;
  final String modalidade;
  final String localizacao;
  final double distanciaKm;
  final double? avaliacaoOfertante;
  final int? totalAvaliacoes;

  const DadosConexao({
    required this.id,
    required this.nomeOfertante,
    required this.nomeProduto,
    required this.quantidade,
    required this.unidade,
    required this.modalidade,
    required this.localizacao,
    required this.distanciaKm,
    this.avaliacaoOfertante,
    this.totalAvaliacoes,
  });

  bool get ehDoacao => modalidade == 'doacao';

  String get quantidadeFormatada {
    final valor = quantidade.toDouble() == quantidade.toInt()
        ? quantidade.toInt().toString()
        : quantidade.toString();
    final unidadeVisivel = switch (unidade) {
      'un' => 'unidades',
      'maco' => 'maços',
      'cacho' => 'cachos',
      'muda' => 'mudas',
      _ => unidade,
    };
    return '~$valor $unidadeVisivel';
  }

  factory DadosConexao.fromApi(Map<String, dynamic> dados) {
    if (dados['id'] is! String || dados['nomeOfertante'] is! String ||
        dados['nomeProduto'] is! String || dados['quantidade'] is! num ||
        dados['unidade'] is! String || dados['modalidade'] is! String ||
        dados['localizacao'] is! String || dados['distanciaKm'] is! num) {
      throw const FormatException('Resposta de conexão inválida.');
    }
    return DadosConexao(
      id: dados['id'] as String,
      nomeOfertante: dados['nomeOfertante'] as String,
      nomeProduto: dados['nomeProduto'] as String,
      quantidade: dados['quantidade'] as num,
      unidade: dados['unidade'] as String,
      modalidade: dados['modalidade'] as String,
      localizacao: dados['localizacao'] as String,
      distanciaKm: (dados['distanciaKm'] as num).toDouble(),
      avaliacaoOfertante: dados['avaliacaoOfertante'] is num
          ? (dados['avaliacaoOfertante'] as num).toDouble()
          : null,
      totalAvaliacoes: dados['totalAvaliacoes'] is int
          ? dados['totalAvaliacoes'] as int
          : null,
    );
  }
}

class ConexaoService {
  // A identidade é obtida exclusivamente do JWT, nunca do corpo enviado.
  static Future<DadosConexao> criar({
    required String excedenteId,
    required double raioKm,
    String? categoria,
    Uri? url,
    http.Client? cliente,
  }) async {
    final token = Sessao.token;
    if (token == null || token.isEmpty) {
      throw const ErroConexao('Faça login para demonstrar interesse.');
    }

    final clienteHttp = cliente ?? http.Client();
    try {
      final resposta = await clienteHttp.post(
        url ?? Uri.parse('$enderecoApi/conexao/matches'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'excedenteId': excedenteId,
          'raioKm': raioKm,
          if (categoria != null && categoria != 'Todas')
            'categoria': categoria == 'Plantas'
                ? 'mudas'
                : categoria.toLowerCase(),
        }),
      ).timeout(const Duration(seconds: 8));

      dynamic corpo;
      try {
        corpo = jsonDecode(resposta.body);
      } on FormatException {
        throw const ErroConexao('Resposta inválida do servidor.');
      }
      if (resposta.statusCode != 201) {
        final erro = corpo is Map<String, dynamic> ? corpo['erro'] : null;
        throw ErroConexao(erro is String && erro.isNotEmpty
            ? erro
            : 'Não foi possível criar a conexão (${resposta.statusCode}).');
      }
      if (corpo is! Map<String, dynamic> ||
          corpo['conexao'] is! Map<String, dynamic>) {
        throw const ErroConexao('Confirmação inválida do servidor.');
      }
      try {
        return DadosConexao.fromApi(corpo['conexao'] as Map<String, dynamic>);
      } on FormatException {
        throw const ErroConexao('Dados incompletos na confirmação.');
      }
    } on ErroConexao {
      rethrow;
    } on TimeoutException {
      throw const ErroConexao('O servidor demorou para responder.');
    } catch (_) {
      throw const ErroConexao('Não foi possível conectar ao servidor.');
    } finally {
      if (cliente == null) clienteHttp.close();
    }
  }
}
