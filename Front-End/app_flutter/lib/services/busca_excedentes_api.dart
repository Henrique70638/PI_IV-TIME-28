// Autor: Rafaela Jacobsen Braga - RA: 25004280
//Autora: Laura Lugli Fonseca Pereira RA:25000739
// Cliente HTTP da busca de excedentes do CULT+ (iOS/Android/macOS).
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api.dart';
import 'sessao.dart';

class ErroBuscaExcedentes implements Exception {
  final String mensagem;
  const ErroBuscaExcedentes(this.mensagem);

  @override
  String toString() => mensagem;
}

class FiltrosExcedentesApi {
  final double? latitude;
  final double? longitude;
  final double raioKm;
  final String? categoria;
  final String? modalidade;
  final String? busca;

  const FiltrosExcedentesApi({
    this.latitude,
    this.longitude,
    required this.raioKm,
    this.categoria,
    this.modalidade,
    this.busca,
  });

  Map<String, String> toQueryParameters() => {
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        'raioKm': raioKm.toString(),
        if (categoria != null && categoria != 'Todas')
          'categoria': categoria == 'Plantas'
              ? 'mudas'
              : categoria!.toLowerCase(),
        if (modalidade != null && modalidade != 'Todos')
          'modalidade': modalidade == 'Doação' ? 'doacao' : 'venda',
        if (busca != null && busca!.trim().isNotEmpty)
          'busca': busca!.trim(),
      };
}

class RespostaHttpBusca {
  final int status;
  final String corpo;
  const RespostaHttpBusca(this.status, this.corpo);
}

class BuscaExcedentesApi {
  final Uri baseUrl;
  final Duration tempoLimite;
  final Future<RespostaHttpBusca> Function(Uri)? _transporte;

  BuscaExcedentesApi({
    Uri? baseUrl,
    this.tempoLimite = const Duration(seconds: 8),
    Future<RespostaHttpBusca> Function(Uri)? transporte,
  })  : _transporte = transporte,
        baseUrl = baseUrl ?? Uri.parse(
          const String.fromEnvironment('CULT_API_URL') == ''
              ? enderecoApi
              : const String.fromEnvironment('CULT_API_URL'),
        );

    //usa o pacote http que funciona no celular, no computador e no navegador
  Future<RespostaHttpBusca> _buscarHttp(Uri uri) async {
    final token = Sessao.token;
    final resposta = await http.get(
      uri,
      headers: {
        //a api acha a localizacao de quem esta logado pelo token
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    ).timeout(tempoLimite);
    //bodyBytes com utf8 pra nao estragar os acentos
    return RespostaHttpBusca(resposta.statusCode, utf8.decode(resposta.bodyBytes));
  }

  Future<List<Map<String, dynamic>>> buscar(FiltrosExcedentesApi filtros) async {
    final uri = baseUrl.replace(
      path: '/api/inicio/excedentes',
      queryParameters: filtros.toQueryParameters(),
    );
    try {
      final transporte = _transporte;
      final resposta = await (transporte == null
              ? _buscarHttp(uri)
              : transporte(uri))
          .timeout(tempoLimite);

      //200 e o codigo de deu certo
      if (resposta.status != 200) {
        throw ErroBuscaExcedentes(
          resposta.status == 401
              ? 'Faça login para consultar ofertas próximas.'
              : resposta.status >= 500
                  ? 'O servidor está indisponível. Tente novamente.'
                  : 'Não foi possível carregar os excedentes (${resposta.status}).',
        );
      }
      final dados = jsonDecode(resposta.corpo);
      if (dados is! Map<String, dynamic> || dados['excedentes'] is! List) {
        throw const FormatException('Formato de resposta inválido.');
      }
      return (dados['excedentes'] as List).map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Produto inválido na resposta.');
        }
        return item;
      }).toList();
        //erro de conexao do pacote http
    } on http.ClientException {
      throw const ErroBuscaExcedentes('Sem conexão com a API do CULT+.');
    } on FormatException {
      throw const ErroBuscaExcedentes('O servidor retornou dados inválidos.');
    } on ErroBuscaExcedentes {
      rethrow;
    } catch (_) {
      throw const ErroBuscaExcedentes('Não foi possível buscar os excedentes.');
    }
  }
}
