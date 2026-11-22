// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api.dart';
import 'sessao.dart';

class ErroChat implements Exception {
  final String mensagem;
  const ErroChat(this.mensagem);

  @override
  String toString() => mensagem;
}

class MensagemRemota {
  final String id;
  final String texto;
  final bool minha;
  final DateTime criadoEm;

  const MensagemRemota({
    required this.id,
    required this.texto,
    required this.minha,
    required this.criadoEm,
  });

  factory MensagemRemota.fromJson(Map<String, dynamic> dados) {
    final id = dados['id'];
    final texto = dados['texto'];
    final minha = dados['minha'];
    final data = DateTime.tryParse((dados['criadoEm'] ?? '').toString());
    if (id is! String || texto is! String || minha is! bool || data == null) {
      throw const FormatException('Mensagem incompleta no servidor.');
    }
    return MensagemRemota(
      id: id,
      texto: texto,
      minha: minha,
      criadoEm: data.toLocal(),
    );
  }
}

class ConversaRemota {
  final String id;
  final String outroNome;
  final String papelDoOutro;
  final String status;
  final String produto;
  final String categoria;
  final String modalidade;
  final num quantidade;
  final String unidade;
  final String? ultimaMensagem;
  final DateTime? ultimaMensagemEm;

  const ConversaRemota({
    required this.id,
    required this.outroNome,
    required this.papelDoOutro,
    required this.status,
    required this.produto,
    required this.categoria,
    required this.modalidade,
    required this.quantidade,
    required this.unidade,
    this.ultimaMensagem,
    this.ultimaMensagemEm,
  });

  factory ConversaRemota.fromJson(Map<String, dynamic> dados) {
    final oferta = dados['excedente'];
    if (dados['id'] is! String ||
        dados['outroNome'] is! String ||
        dados['papelDoOutro'] is! String ||
        dados['status'] is! String ||
        oferta is! Map<String, dynamic> ||
        oferta['produto'] is! String ||
        oferta['categoria'] is! String ||
        oferta['modalidade'] is! String ||
        oferta['quantidade'] is! num ||
        oferta['unidade'] is! String) {
      throw const FormatException('Conversa incompleta no servidor.');
    }
    final ultima = dados['ultimaMensagem'];
    if (ultima != null && ultima is! Map<String, dynamic>) {
      throw const FormatException('Última mensagem inválida.');
    }
    return ConversaRemota(
      id: dados['id'] as String,
      outroNome: dados['outroNome'] as String,
      papelDoOutro: dados['papelDoOutro'] as String,
      status: dados['status'] as String,
      produto: oferta['produto'] as String,
      categoria: oferta['categoria'] as String,
      modalidade: oferta['modalidade'] as String,
      quantidade: oferta['quantidade'] as num,
      unidade: oferta['unidade'] as String,
      ultimaMensagem: ultima?['texto'] is String
          ? ultima!['texto'] as String
          : null,
      ultimaMensagemEm: DateTime.tryParse(
        (ultima?['criadoEm'] ?? '').toString(),
      )?.toLocal(),
    );
  }
}

class DetalheConversaRemota {
  final ConversaRemota conversa;
  final List<MensagemRemota> mensagens;

  const DetalheConversaRemota({
    required this.conversa,
    required this.mensagens,
  });
}

class ConversasService {
  final Uri baseUrl;
  final http.Client? cliente;
  final Duration tempoLimite;

  ConversasService({
    Uri? baseUrl,
    this.cliente,
    this.tempoLimite = const Duration(seconds: 8),
  }) : baseUrl = baseUrl ?? Uri.parse('$enderecoApi/conversas');

  Future<Map<String, dynamic>> _requisicao(
    String metodo,
    String caminho, {
    Map<String, dynamic>? dados,
  }) async {
    final token = Sessao.token;
    if (token == null || token.isEmpty) {
      throw const ErroChat('Faça login para acessar suas conversas.');
    }
    final clienteHttp = cliente ?? http.Client();
    try {
      final uri = baseUrl.replace(
        path: '${baseUrl.path.replaceFirst(RegExp(r'/$'), '')}$caminho',
      );
      final pedido = http.Request(metodo, uri)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });
      if (dados != null) pedido.body = jsonEncode(dados);
      final stream = await clienteHttp.send(pedido).timeout(tempoLimite);
      final resposta = await http.Response.fromStream(
        stream,
      ).timeout(tempoLimite);
      dynamic corpo;
      try {
        corpo = jsonDecode(resposta.body);
      } on FormatException {
        throw const ErroChat('O servidor retornou uma resposta inválida.');
      }
      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        final mensagem = corpo is Map<String, dynamic> ? corpo['erro'] : null;
        throw ErroChat(
          mensagem is String && mensagem.isNotEmpty
              ? mensagem
              : 'Falha na conversa (${resposta.statusCode}).',
        );
      }
      if (corpo is! Map<String, dynamic>) {
        throw const ErroChat('O servidor retornou dados inválidos.');
      }
      return corpo;
    } on ErroChat {
      rethrow;
    } on TimeoutException {
      throw const ErroChat('O servidor demorou para responder.');
    } on FormatException {
      throw const ErroChat('Os dados da conversa estão incompletos.');
    } catch (_) {
      throw const ErroChat('Não foi possível conectar ao servidor.');
    } finally {
      if (cliente == null) clienteHttp.close();
    }
  }

  Future<List<ConversaRemota>> listar() async {
    final dados = await _requisicao('GET', '');
    final lista = dados['conversas'];
    if (lista is! List) throw const ErroChat('Lista de conversas inválida.');
    try {
      return lista
          .map(
            (item) =>
                ConversaRemota.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList();
    } catch (_) {
      throw const ErroChat('O servidor retornou conversas incompletas.');
    }
  }

  Future<DetalheConversaRemota> obter(String matchId) async {
    final dados = await _requisicao('GET', '/${Uri.encodeComponent(matchId)}');
    if (dados['conversa'] is! Map || dados['mensagens'] is! List) {
      throw const ErroChat('Detalhes da conversa incompletos.');
    }
    try {
      return DetalheConversaRemota(
        conversa: ConversaRemota.fromJson(
          (dados['conversa'] as Map).cast<String, dynamic>(),
        ),
        mensagens: (dados['mensagens'] as List)
            .map(
              (item) => MensagemRemota.fromJson(
                (item as Map).cast<String, dynamic>(),
              ),
            )
            .toList(),
      );
    } catch (_) {
      throw const ErroChat('O servidor retornou mensagens inválidas.');
    }
  }

  Future<MensagemRemota> enviar(String matchId, String texto) async {
    final conteudo = texto.trim();
    if (conteudo.isEmpty || conteudo.length > 1000) {
      throw const ErroChat('A mensagem deve ter entre 1 e 1000 caracteres.');
    }
    final dados = await _requisicao(
      'POST',
      '/${Uri.encodeComponent(matchId)}/mensagens',
      dados: {'texto': conteudo},
    );
    try {
      return MensagemRemota.fromJson(dados);
    } catch (_) {
      throw const ErroChat('O servidor não confirmou a mensagem.');
    }
  }
}
