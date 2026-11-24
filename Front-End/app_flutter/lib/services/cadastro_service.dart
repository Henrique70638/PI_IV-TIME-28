//Autora: Laura Lugli Fonseca Pereira RA:25000739
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api.dart';

class CadastroService {
  //manda o cadastro pra api, null quer dizer que deu certo
  static Future<String?> cadastrar(Map<String, dynamic> dados) async {
    try {
      final resposta = await http.post(
        Uri.parse('$enderecoApi/cadastro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dados),
      );

      //201 quer dizer que a conta foi criada
      if (resposta.statusCode == 201) return null;

      //se nao deu certo a api manda o motivo, pode vir do servidor java
      final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
      return corpo['erro']?.toString() ?? 'Não foi possível criar a conta';
    } catch (_) {
      return 'Não foi possível conectar ao servidor';
    }
  }
}