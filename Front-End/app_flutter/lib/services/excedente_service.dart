//Autora: Laura Lugli Fonseca Pereira RA:25000739
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';
import 'sessao.dart';

class ExcedenteService {
  //manda o excedente pra api, devolve null se deu certo ou a mensagem de erro
  static Future<String?> publicar(Map<String, dynamic> dados) async {
    try {
      final resposta = await http.post(
        Uri.parse('$enderecoApi/publicar'),
        //manda o crachá de login junto
        headers: {
          'Content-Type': 'application/json',
          if (Sessao.token != null) 'Authorization': 'Bearer ${Sessao.token}',
        },
        body: jsonEncode(dados),
      );

      //201 é criado com sucesso
      if (resposta.statusCode == 201) return null;

      //a api devolve o erro no formato {"erro": "..."}
      final corpo = jsonDecode(resposta.body);
      return corpo['erro'] ?? 'Erro ao publicar';
    } catch (erro) {
      //cai aqui quando nem consegue falar com a api
      return 'Não foi possível conectar ao servidor';
    }
  }
}
