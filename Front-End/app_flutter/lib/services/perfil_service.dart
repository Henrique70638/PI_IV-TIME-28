// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';
import 'sessao.dart';

class ErroPerfil implements Exception {
  final String mensagem;
  const ErroPerfil(this.mensagem);
  @override
  String toString() => mensagem;
}

class PerfilService {
  final http.Client? cliente;
  final Uri uri;
  PerfilService({this.cliente, Uri? uri})
    : uri = uri ?? Uri.parse('$enderecoApi/perfil');

  Future<Map<String, dynamic>> atualizar(Map<String, dynamic> dados) async {
    final token = Sessao.token;
    if (token == null || token.isEmpty) {
      throw const ErroPerfil('Entre na sua conta para alterar o perfil.');
    }
    final client = cliente ?? http.Client();
    try {
      final resposta = await client
          .patch(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(dados),
          )
          .timeout(const Duration(seconds: 10));
      final corpo = jsonDecode(resposta.body);
      if (corpo is! Map<String, dynamic>) {
        throw const ErroPerfil('Resposta inválida do servidor.');
      }
      if (resposta.statusCode != 200) {
        throw ErroPerfil(
          corpo['erro'] is String
              ? corpo['erro'] as String
              : 'Não foi possível atualizar o perfil.',
        );
      }
      for (final chave in [
        'id',
        'nome',
        'email',
        'perfil',
        'bairro',
        'cidade',
      ]) {
        if (corpo[chave] is! String) {
          throw const ErroPerfil('Perfil incompleto na resposta.');
        }
      }
      Sessao.usuario = corpo;
      return corpo;
    } on ErroPerfil {
      rethrow;
    } on FormatException {
      throw const ErroPerfil('Resposta inválida do servidor.');
    } catch (_) {
      throw const ErroPerfil('Não foi possível conectar ao servidor.');
    } finally {
      if (cliente == null) client.close();
    }
  }
}
