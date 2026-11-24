//Autora: Laura Lugli Fonseca Pereira RA:25000739
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';
import 'sessao.dart';

class LoginService {
  //faz login e guarda o token na sessao, devolve null se deu certo ou a mensagem de erro
  static Future<String?> entrar(String email, String senha) async {
    try {
      final resposta = await http.post(
        Uri.parse('$enderecoApi/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      final corpo = jsonDecode(resposta.body);

      //200 é login certo, guarda o crachá no bolso
      if (resposta.statusCode == 200) {
        Sessao.token = corpo['token'];
        Sessao.usuario = corpo['usuario'];
        return null;
      }

      return corpo['erro'] ?? 'Erro ao entrar';
    } catch (erro) {
      return 'Não foi possível conectar ao servidor';
    }
  }
}