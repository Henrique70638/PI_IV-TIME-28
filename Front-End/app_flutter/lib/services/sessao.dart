//Autora: Laura Lugli Fonseca Pereira RA:25000739

//guarda quem esta logado enquanto o app esta aberto
class Sessao {
  //token que a api devolveu no login
  static String? token;

  //dados do usuario logado (id, nome, email, perfil, bairro, cidade)
  static Map<String, dynamic>? usuario;

  //true se tem alguem logado
  static bool get logado => token != null;

  //id do usuario logado, ou null se ninguem entrou
  static String? get usuarioId => usuario?['id'];

  //nome do usuario logado
  static String? get usuarioNome => usuario?['nome'];

  //apaga tudo quando a pessoa sai da conta
  static void sair() {
    token = null;
    usuario = null;
  }
}