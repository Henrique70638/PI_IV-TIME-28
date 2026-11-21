// Autor: Rafaela Jacobsen Braga - RA: 25004280
// Cliente HTTP da busca de excedentes do CULT+ (iOS/Android/macOS).
import 'dart:convert';
import 'dart:io';

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

  Future<RespostaHttpBusca> _buscarHttp(Uri uri) async {
    final cliente = HttpClient()..connectionTimeout = tempoLimite;
    try {
      final requisicao = await cliente.getUrl(uri).timeout(tempoLimite);
      // A API obtém a localização cadastrada usando a sessão verificada.
      final token = Sessao.token;
      if (token != null && token.isNotEmpty) {
        requisicao.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      final resposta = await requisicao.close().timeout(tempoLimite);
      final corpo = await resposta.transform(utf8.decoder).join().timeout(tempoLimite);
      return RespostaHttpBusca(resposta.statusCode, corpo);
    } finally {
      cliente.close(force: true);
    }
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

      if (resposta.status != HttpStatus.ok) {
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
    } on SocketException {
      throw const ErroBuscaExcedentes('Sem conexão com a API do CULT+.');
    } on HttpException {
      throw const ErroBuscaExcedentes('Falha de comunicação com o servidor.');
    } on FormatException {
      throw const ErroBuscaExcedentes('O servidor retornou dados inválidos.');
    } on ErroBuscaExcedentes {
      rethrow;
    } catch (_) {
      throw const ErroBuscaExcedentes('Não foi possível buscar os excedentes.');
    }
  }
}
