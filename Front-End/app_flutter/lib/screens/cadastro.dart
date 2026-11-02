import 'package:flutter/material.dart';

// Cores da identidade visual do CULT+
const corVerde = Color(0xFF2E7D32);
const corVerdeClaro = Color(0xFFE6F1E3);
const corLaranja = Color(0xFFEF6C00);
const corFundo = Color(0xFFF7F6F1);
const corTexto = Color(0xFF1F2A1F);
const corCinza = Color(0xFF8A8F87);
const corBorda = Color(0xFFE6E6E0);

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Text('Cadastro'),
            ],
          ),
        ),
      ),
    );
  }
}