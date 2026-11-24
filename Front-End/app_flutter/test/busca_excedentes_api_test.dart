// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'dart:convert';

import 'package:app_flutter/services/busca_excedentes_api.dart';
import 'package:app_flutter/screens/inicio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monta filtros aceitos pelo backend', () {
    const filtros = FiltrosExcedentesApi(
      latitude: -22.9,
      longitude: -47.05,
      raioKm: 5,
      categoria: 'Plantas',
      modalidade: 'Doação',
      busca: ' manjericão ',
    );
    final query = filtros.toQueryParameters();
    expect(query['categoria'], 'mudas');
    expect(query['modalidade'], 'doacao');
    expect(query['busca'], 'manjericão');
    expect(query['raioKm'], '5.0');
  });

  test('busca autenticada não envia localização arbitrária do cliente', () {
    const filtros = FiltrosExcedentesApi(raioKm: 5, categoria: 'Todas');
    final parametros = filtros.toQueryParameters();
    expect(parametros.containsKey('latitude'), isFalse);
    expect(parametros.containsKey('longitude'), isFalse);
    expect(parametros.containsKey('categoria'), isFalse);
  });

  test('converte produto da API em card do CULT+', () {
    final produto = ExcedenteCult.fromApi({
      'id': 'abc123',
      'produto': 'Manga Tommy',
      'categoria': 'frutas',
      'quantidade': 5,
      'unidade': 'kg',
      'modalidade': 'doacao',
      'distanciaKm': 1.2,
    });
    expect(produto.id, 'abc123');
    expect(produto.nome, 'Manga Tommy');
    expect(produto.quantidade, '~5 kg');
    expect(produto.distanciaKm, 1.2);
    expect(produto.tipo, TipoOferta.doacao);
  });

  test('busca faz GET com os filtros e lê a resposta', () async {
    Uri? ultimaUri;
    final api = BuscaExcedentesApi(
      transporte: (uri) async {
        ultimaUri = uri;
        return RespostaHttpBusca(200, jsonEncode({
          'total': 1,
          'excedentes': [
            {
              'id': 'x1',
              'produto': 'Banana',
              'categoria': 'frutas',
              'quantidade': 2,
              'unidade': 'cacho',
              'modalidade': 'venda',
              'distanciaKm': 3.1,
            },
          ],
        }));
      },
    );
    final produtos = await api.buscar(const FiltrosExcedentesApi(
      latitude: -22.9,
      longitude: -47.05,
      raioKm: 5,
      categoria: 'Frutas',
    ));
    expect(ultimaUri!.path, '/api/inicio/excedentes');
    expect(ultimaUri!.queryParameters['categoria'], 'frutas');
    expect(produtos, hasLength(1));
    expect(produtos.first['produto'], 'Banana');
  });

  test('erro HTTP 500 não expõe conteúdo interno do servidor', () async {
    final api = BuscaExcedentesApi(
      transporte: (_) async => const RespostaHttpBusca(500, 'falha interna'),
    );
    await expectLater(
      api.buscar(const FiltrosExcedentesApi(
        latitude: -22.9,
        longitude: -47.05,
        raioKm: 5,
      )),
      throwsA(isA<ErroBuscaExcedentes>()),
    );
  });

  test('resposta JSON inválida produz erro seguro', () async {
    final api = BuscaExcedentesApi(
      transporte: (_) async => const RespostaHttpBusca(200, '{invalido'),
    );
    await expectLater(
      api.buscar(const FiltrosExcedentesApi(
        latitude: -22.9,
        longitude: -47.05,
        raioKm: 5,
      )),
      throwsA(isA<ErroBuscaExcedentes>()),
    );
  });
}
