//Autora: Laura Lugli Fonseca Pereira RA:25000739
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api.dart';

//o endereço da api muda dependendo de onde o app roda
String get enderecoApi {
  //navegador roda no proprio computador
  if (kIsWeb) {
    return 'http://localhost:3333/api';
  }
  //no emulador android o computador fica no 10.0.2.2
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3333/api';
  }
  //simulador do iphone usa a rede do mac
  return 'http://localhost:3333/api';
}

class ExcedenteService {
  //manda o excedente pra api, devolve null se deu certo ou a mensagem de erro
  static Future<String?> publicar(Map<String, dynamic> dados) async {
    try {
      final resposta = await http.post(
        Uri.parse('$enderecoApi/publicar'),
        headers: {'Content-Type': 'application/json'},
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
