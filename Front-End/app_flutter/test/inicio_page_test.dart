// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/screens/inicio.dart';

void main() {
  testWidgets('tela inicial informa quando usa produtos de demonstração', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InicioPage()));
    expect(find.text('Excedentes disponíveis'), findsOneWidget);
    expect(find.text('Produtos de demonstração'), findsOneWidget);
  });
}
