//Autor:Emilly Morelatto
import 'package:flutter/material.dart';
import 'inicio.dart';
import 'publicar.dart';
import 'conversas.dart';

class UsuarioPerfil {
  final String nome;
  final String email;
  final String tipoUsuario;
  final String localizacao;

  const UsuarioPerfil({
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    required this.localizacao,
  });
}

class PerfilPage extends StatelessWidget {
  final UsuarioPerfil usuario;

  const PerfilPage({super.key, required this.usuario});

  static const Color verde = Color(0xFF267536);
  static const Color verdeEscuro = Color(0xFF206D31);
  static const Color fundo = Color(0xFFF7F8F2);
  static const Color cinza = Color(0xFF929A91);
  static const Color laranja = Color(0xFFF47700);

  String get tipoFormatado {
    switch (usuario.tipoUsuario.toLowerCase().trim()) {
      case 'ofertante':
        return 'Ofertante';
      case 'interessado':
      case 'interessada':
        return 'Interessado';
      case 'ambos':
        return 'Ambos';
      default:
        return usuario.tipoUsuario;
    }
  }

  bool get ehOfertante {
    return tipoFormatado.toLowerCase() == 'ofertante' ||
        tipoFormatado.toLowerCase() == 'ambos';
  }

  bool get ehInteressado {
    return tipoFormatado.toLowerCase() == 'interessado' ||
        tipoFormatado.toLowerCase() == 'ambos';
  }

  Widget linhaInformacao({
    required IconData icone,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE4EFDF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icone, color: verde, size: 29),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF183D36),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  valor.isEmpty ? 'Não informado' : valor,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF829398),
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF7F8B8B), size: 28),
        ],
      ),
    );
  }

  Widget seloTipo({
    required IconData icone,
    required String texto,
    required Color cor,
    required Color fundoSelo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fundoSelo,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 23),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: cor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.maybePop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: verde,
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Meu Perfil',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF17291E),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: verde,
                            size: 27,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 105,
                          height: 105,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD8E9D2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: verde,
                            size: 75,
                          ),
                        ),
                        const SizedBox(width: 17),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario.nome,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF17291E),
                                ),
                                softWrap: true,
                              ),
                              const SizedBox(height: 9),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.mail_outline,
                                    color: cinza,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      usuario.email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF829398),
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE4EFDF),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      color: verde,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        tipoFormatado,
                                        style: const TextStyle(
                                          color: verdeEscuro,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2E5),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seu perfil',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF17291E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Faça parte de uma comunidade que '
                            'compartilha alimentos e evita desperdícios.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF42664C),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (ehOfertante)
                                seloTipo(
                                  icone: Icons.volunteer_activism,
                                  texto: 'Ofertante',
                                  cor: verde,
                                  fundoSelo: const Color(0xFFD8E9D2),
                                ),
                              if (ehInteressado)
                                seloTipo(
                                  icone: Icons.favorite,
                                  texto: 'Interessado',
                                  cor: laranja,
                                  fundoSelo: const Color(0xFFFFE9D5),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.035),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          linhaInformacao(
                            icone: Icons.person_outline,
                            titulo: 'Nome',
                            valor: usuario.nome,
                          ),
                          const Divider(height: 1, color: Color(0xFFEDF0EB)),
                          linhaInformacao(
                            icone: Icons.mail_outline,
                            titulo: 'E-mail',
                            valor: usuario.email,
                          ),
                          const Divider(height: 1, color: Color(0xFFEDF0EB)),
                          linhaInformacao(
                            icone: Icons.people_outline,
                            titulo: 'Tipo de usuário',
                            valor: tipoFormatado,
                          ),
                          const Divider(height: 1, color: Color(0xFFEDF0EB)),
                          linhaInformacao(
                            icone: Icons.location_on_outlined,
                            titulo: 'Localização',
                            valor: usuario.localizacao,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE7EAE4))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  itemNavegacao(
                    icone: Icons.home_outlined,
                    texto: 'Início',
                    selecionado: false,
                    aoTocar: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InicioPage(),
                        ),
                      );
                    },
                  ),
                  itemNavegacao(
                    icone: Icons.add,
                    texto: 'Publicar',
                    selecionado: false,
                    aoTocar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PublicarPage(),
                        ),
                      );
                    },
                  ),
                  itemNavegacao(
                    icone: Icons.chat_bubble_outline,
                    texto: 'Conversas',
                    selecionado: false,
                    aoTocar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConversasPage(),
                        ),
                      );
                    },
                  ),
                  itemNavegacao(
                    icone: Icons.person,
                    texto: 'Perfil',
                    selecionado: true,
                    aoTocar: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemNavegacao({
    required IconData icone,
    required String texto,
    required bool selecionado,
    required VoidCallback aoTocar,
  }) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 28, color: selecionado ? verde : Colors.grey),
            const SizedBox(height: 5),
            Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                color: selecionado ? verde : Colors.grey,
              ),
            ),
            if (selecionado)
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: verde,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
