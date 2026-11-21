// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'dart:convert';

import 'package:app_flutter/services/conexao_service.dart';
import 'package:app_flutter/services/sessao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    Sessao.token = 'jwt-de-teste';
    Sessao.usuario = {'id': '507f1f77bcf86cd799439011'};
  });
  tearDown(Sessao.sair);

  test('POST exige JWT e usa identificador da oferta sem forjar usuario', () async {
    final cliente = MockClient((requisicao) async {
      expect(requisicao.url.path, '/api/conexao/matches');
      expect(requisicao.headers['Authorization'], 'Bearer jwt-de-teste');
      final dados = jsonDecode(requisicao.body) as Map<String, dynamic>;
      expect(dados['excedenteId'], '507f1f77bcf86cd799439012');
      expect(dados['categoria'], 'mudas');
      expect(dados.containsKey('interessadoId'), isFalse);
      return http.Response(jsonEncode({
        'conexao': {
          'id': '507f1f77bcf86cd799439013',
          'nomeOfertante': 'Maria',
          'nomeProduto': 'Alecrim',
          'quantidade': 2,
          'unidade': 'muda',
          'modalidade': 'doacao',
          'localizacao': 'Centro',
          'distanciaKm': 1.6,
        },
      }), 201);
    });
    final conexao = await ConexaoService.criar(
      excedenteId: '507f1f77bcf86cd799439012',
      raioKm: 5,
      categoria: 'Plantas',
      cliente: cliente,
      url: Uri.parse('http://localhost:3333/api/conexao/matches'),
    );
    expect(conexao.nomeOfertante, 'Maria');
    expect(conexao.quantidadeFormatada, '~2 mudas');
    expect(conexao.avaliacaoOfertante, isNull);
  });

  test('não confirma quando o servidor recusa a conexão', () async {
    final cliente = MockClient((_) async => http.Response(
      jsonEncode({'erro': 'Este excedente não está disponível.'}), 409,
    ));
    await expectLater(
      ConexaoService.criar(
        excedenteId: '507f1f77bcf86cd799439012',
        raioKm: 5,
        cliente: cliente,
      ),
      throwsA(isA<ErroConexao>()),
    );
  });

  test('sem JWT não executa solicitação', () async {
    Sessao.sair();
    await expectLater(
      ConexaoService.criar(excedenteId: '507f1f77bcf86cd799439012', raioKm: 5),
      throwsA(isA<ErroConexao>()),
    );
  });
}
