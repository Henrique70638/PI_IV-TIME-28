// Atualiza o teste padrão do contador para um teste real do CULT+.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/main.dart';

void main() {
  testWidgets('o aplicativo CULT+ inicializa corretamente', (tester) async {
    await tester.pumpWidget(const CultMaisApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
