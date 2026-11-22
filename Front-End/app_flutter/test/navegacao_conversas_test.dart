// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'package:app_flutter/screens/chat.dart';
import 'package:app_flutter/screens/conversas.dart';
import 'package:app_flutter/screens/inicio.dart';
import 'package:app_flutter/screens/perfil.dart';
import 'package:app_flutter/screens/publicar.dart';
import 'package:app_flutter/services/sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(Sessao.sair);

  testWidgets('Conversas mostra o menu inferior e volta para Início', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConversasPage(conversas: [])),
    );

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Publicar'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.byType(InicioPage), findsOneWidget);
  });

  testWidgets('Conversas abre Publicar pelo menu inferior', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConversasPage(conversas: [])),
    );
    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();
    expect(find.byType(PublicarPage), findsOneWidget);
  });

  testWidgets('Conversas abre Perfil usando a sessão atual', (tester) async {
    Sessao.usuario = {
      'nome': 'Pessoa Teste',
      'email': 'teste@example.com',
      'perfil': 'ambos',
      'bairro': 'Cambuí',
    };
    await tester.pumpWidget(
      const MaterialApp(home: ConversasPage(conversas: [])),
    );

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.byType(PerfilPage), findsOneWidget);
    expect(find.text('Pessoa Teste'), findsWidgets);
  });

  testWidgets('Conversas continua abrindo a conversa selecionada', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ConversasPage()));
    await tester.tap(find.text('Roberto C.'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatPage), findsOneWidget);
  });
}
