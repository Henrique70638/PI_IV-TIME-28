// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'dart:convert';
import 'package:app_flutter/screens/chat.dart';
import 'package:app_flutter/services/conversas_service.dart';
import 'package:app_flutter/services/sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  tearDown(Sessao.sair);

  testWidgets(
    'chat autenticado carrega mensagens sem reinicializar campo late',
    (tester) async {
      Sessao.token = 'token-teste';
      final api = ConversasService(
        baseUrl: Uri.parse('http://localhost:3333/api/conversas'),
        cliente: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'conversa': {
                'id': 'a10000000000000000000001',
                'outroNome': 'Laura',
                'papelDoOutro': 'ofertante',
                'status': 'conectado',
                'excedente': {
                  'produto': 'Manga',
                  'categoria': 'frutas',
                  'modalidade': 'doacao',
                  'quantidade': 5,
                  'unidade': 'kg',
                },
                'ultimaMensagem': null,
              },
              'mensagens': [
                {
                  'id': 'b10000000000000000000001',
                  'texto': 'Oi, tudo bem?',
                  'minha': false,
                  'criadoEm': '2026-11-22T12:00:00.000Z',
                },
              ],
            }),
            200,
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ChatPage(
            matchId: 'a10000000000000000000001',
            nomeOutro: 'Laura',
            api: api,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Oi, tudo bem?'), findsOneWidget);
      expect(find.textContaining('LateInitializationError'), findsNothing);
    },
  );
}
