/*import 'package:flutter/material.dart';
import 'screens/login.dart';

void main() {
  runApp(const CultMaisApp());
}

class CultMaisApp extends StatelessWidget {
  const CultMaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cult+',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F2),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF267536)),
      ),
      home: const LoginPage(),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'screens/perfil.dart';

void main() {
  runApp(const CultMaisApp());
}

class CultMaisApp extends StatelessWidget {
  const CultMaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cult+',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F2),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF267536)),
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return const PerfilPage(
      usuario: UsuarioPerfil(
        nome: 'Emilly Morelatto',
        email: 'emilly@email.com',
        tipoUsuario: 'Interessado',
        localizacao: 'Jardim das Flores',
      ),
    );
  }
}
