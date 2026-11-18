// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/screens/conexao_confirmada.dart';
import 'package:app_flutter/screens/conversas.dart';
import 'package:app_flutter/screens/inicio.dart';
import 'package:app_flutter/screens/perfil.dart';
import 'package:app_flutter/screens/publicar.dart';

void main() {
  testWidgets('Início abre Publicar pelo menu inferior', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InicioPage()));
    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();
    expect(find.byType(PublicarPage), findsOneWidget);
  });

  testWidgets('Início abre Conversas pelo menu inferior', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InicioPage()));
    await tester.tap(find.text('Conversas'));
    await tester.pumpAndSettle();
    expect(find.byType(ConversasPage), findsOneWidget);
  });

  testWidgets('Início abre Perfil de demonstração', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InicioPage()));
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.byType(PerfilPage), findsOneWidget);
    expect(find.text('Usuário de demonstração'), findsWidgets);
  });

  testWidgets('Conexão confirmada abre Conversas', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConexaoConfirmadaPage()),
    );
    await tester.tap(find.text('Abrir chat'));
    await tester.pumpAndSettle();
    expect(find.byType(ConversasPage), findsOneWidget);
  });

  testWidgets('Conexão confirmada volta para Início', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ConexaoConfirmadaPage()),
    );
    await tester.tap(find.text('Voltar à busca'));
    await tester.pumpAndSettle();
    expect(find.byType(InicioPage), findsOneWidget);
  });
}
