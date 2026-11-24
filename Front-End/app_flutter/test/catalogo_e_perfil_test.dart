// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'dart:convert';
import 'package:app_flutter/screens/editar_perfil.dart';
import 'package:app_flutter/screens/perfil.dart';
import 'package:app_flutter/screens/publicar.dart';
import 'package:app_flutter/services/catalogo_produtos.dart';
import 'package:app_flutter/services/perfil_service.dart';
import 'package:app_flutter/services/sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  tearDown(Sessao.sair);

  test('ilustrações seguem o nome real do produto', () {
    expect(CatalogoProdutos.ilustracao('Manga Tommy', 'frutas'), '🥭');
    expect(CatalogoProdutos.ilustracao('Limão Taiti', 'frutas'), '🍋');
    expect(CatalogoProdutos.ilustracao('Tomate italiano', 'legumes'), '🍅');
    expect(CatalogoProdutos.ilustracao('Alface crespa', 'verduras'), '🥬');
  });

  test(
    'perfil altera dados usando JWT sem permitir identidade no corpo',
    () async {
      Sessao.token = 'teste';
      final api = PerfilService(
        uri: Uri.parse('http://localhost:3333/api/perfil'),
        cliente: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(
            request.headers['authorization'] ??
                request.headers['Authorization'],
            'Bearer teste',
          );
          expect(jsonDecode(request.body), {
            'nome': 'Novo nome',
            'perfil': 'ambos',
          });
          return http.Response(
            jsonEncode({
              'id': 'a10000000000000000000001',
              'nome': 'Novo nome',
              'email': 'teste@example.com',
              'perfil': 'ambos',
              'bairro': 'Cambuí',
              'cidade': 'Campinas',
            }),
            200,
          );
        }),
      );
      await api.atualizar({'nome': 'Novo nome', 'perfil': 'ambos'});
      expect(Sessao.usuario?['nome'], 'Novo nome');
    },
  );

  testWidgets('engrenagem de Perfil abre a edição da conta', (tester) async {
    Sessao.usuario = {
      'nome': 'Laura',
      'email': 'laura@teste.com',
      'perfil': 'ambos',
      'bairro': 'Cambuí',
      'cidade': 'Campinas',
    };
    await tester.pumpWidget(
      const MaterialApp(
        home: PerfilPage(
          usuario: UsuarioPerfil(
            nome: 'Laura',
            email: 'laura@teste.com',
            tipoUsuario: 'ambos',
            localizacao: 'Cambuí',
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(EditarPerfilPage), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);
  });

  testWidgets('seta do e-mail abre o formulário de edição', (tester) async {
    Sessao.usuario = {
      'nome': 'Laura',
      'email': 'laura@teste.com',
      'perfil': 'ambos',
      'bairro': 'Cambuí',
      'cidade': 'Campinas',
    };
    await tester.pumpWidget(
      const MaterialApp(
        home: PerfilPage(
          usuario: UsuarioPerfil(
            nome: 'Laura',
            email: 'laura@teste.com',
            tipoUsuario: 'ambos',
            localizacao: 'Cambuí',
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('E-mail').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('E-mail').last);
    await tester.pumpAndSettle();
    expect(find.byType(EditarPerfilPage), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);
  });

  testWidgets('Publicar abre catálogo de ilustrações', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PublicarPage()));
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('Galeria de frutas e verduras'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Sem ilustração'), findsOneWidget);
  });
}
