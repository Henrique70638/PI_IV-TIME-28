import 'package:flutter/material.dart';

const corVerde = Color(0xFF2E7D32);
const corVerdeClaro = Color(0xFFE6F1E3);
const corLaranja = Color(0xFFEF6C00);
const corFundo = Color(0xFFF7F6F1);
const corTexto = Color(0xFF1F2A1F);
const corCinza = Color(0xFF8A8F87);
const corBorda = Color(0xFFE6E6E0);

class PublicarPage extends StatefulWidget {
  const PublicarPage({super.key});

  @override
  State<PublicarPage> createState() => _PublicarPageState();
}

class _PublicarPageState extends State<PublicarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        child: Column(
          children: [
            _topo(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    SizedBox(height: 18),
                    Text('Conteúdo da tela'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: corTexto, size: 20),
            ),
          ),
          const Expanded(
            child: Text(
              'Novo excedente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: corTexto,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
