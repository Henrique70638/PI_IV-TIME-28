// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'dart:convert';

import 'package:app_flutter/services/conversas_service.dart';
import 'package:app_flutter/services/sessao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const exemplo = {
  'id': 'b20000000000000000000001',
  'outroNome': 'Laura',
  'papelDoOutro': 'ofertante',
  'status': 'conectado',
  'excedente': {
    'produto': 'Manga Tommy',
    'categoria': 'frutas',
    'modalidade': 'doacao',
    'quantidade': 5,
    'unidade': 'kg',
  },
  'ultimaMensagem': null,
};

void main() {
  tearDown(Sessao.sair);

  test('sem login não acessa nem lista mensagens de outras pessoas', () async {
    var chamadas = 0;
    final api = ConversasService(
      baseUrl: Uri.parse('http://localhost:3333/api/conversas'),
      cliente: MockClient((_) async {
        chamadas++;
        return http.Response('{}', 200);
      }),
    );
    await expectLater(api.listar(), throwsA(isA<ErroChat>()));
    expect(chamadas, 0);
  });

  test('lista matches do usuário autenticado e sem usuarioId na URL', () async {
    Sessao.token = 'token-teste';
    final api = ConversasService(
      baseUrl: Uri.parse('http://localhost:3333/api/conversas'),
      cliente: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/conversas');
        expect(request.url.query, isEmpty);
        expect(
          request.headers['authorization'] ?? request.headers['Authorization'],
          'Bearer token-teste',
        );
        return http.Response(
          jsonEncode({
            'conversas': [exemplo],
          }),
          200,
        );
      }),
    );
    final lista = await api.listar();
    expect(lista.single.outroNome, 'Laura');
    expect(lista.single.produto, 'Manga Tommy');
  });

  test('carrega somente mensagens do match autenticado', () async {
    Sessao.token = 'token-teste';
    final api = ConversasService(
      baseUrl: Uri.parse('http://localhost:3333/api/conversas'),
      cliente: MockClient((request) async {
        expect(request.url.path, '/api/conversas/b20000000000000000000001');
        return http.Response(
          jsonEncode({
            'conversa': exemplo,
            'mensagens': [
              {
                'id': 'c30000000000000000000001',
                'texto': 'Oi',
                'minha': true,
                'criadoEm': '2026-11-22T12:00:00.000Z',
              },
            ],
          }),
          200,
        );
      }),
    );
    final detalhe = await api.obter('b20000000000000000000001');
    expect(detalhe.mensagens.single.texto, 'Oi');
    expect(detalhe.mensagens.single.minha, true);
  });

  test('envio usa JWT e texto, sem autorId forjado', () async {
    Sessao.token = 'token-teste';
    final api = ConversasService(
      baseUrl: Uri.parse('http://localhost:3333/api/conversas'),
      cliente: MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.path,
          '/api/conversas/b20000000000000000000001/mensagens',
        );
        expect(jsonDecode(request.body), {'texto': 'Olá!'});
        return http.Response(
          jsonEncode({
            'id': 'c30000000000000000000002',
            'texto': 'Olá!',
            'minha': true,
            'criadoEm': '2026-11-22T12:05:00.000Z',
          }),
          201,
        );
      }),
    );
    final salva = await api.enviar('b20000000000000000000001', '  Olá! ');
    expect(salva.texto, 'Olá!');
  });

  test('falha HTTP não é confundida com mensagem salva', () async {
    Sessao.token = 'token-teste';
    final api = ConversasService(
      baseUrl: Uri.parse('http://localhost:3333/api/conversas'),
      cliente: MockClient(
        (_) async =>
            http.Response(jsonEncode({'erro': 'Conversa encerrada'}), 409),
      ),
    );
    await expectLater(
      api.enviar('b20000000000000000000001', 'Oi'),
      throwsA(isA<ErroChat>()),
    );
  });
}
