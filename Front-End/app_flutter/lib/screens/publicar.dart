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
  final List<String> _fotos = ['🥭'];

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

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
                  children: [_rotulo('Fotos'), _fotosProduto()],
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

  Widget _rotulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: corTexto,
        ),
      ),
    );
  }

  Widget _fotosProduto() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (int i = 0; i < _fotos.length; i++) _foto(i),
        _botaoAdicionarFoto(),
      ],
    );
  }

  Widget _foto(int indice) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD36B), Color(0xFFF5A623)],
            ),
          ),
          alignment: Alignment.center,
          child: Text(_fotos[indice], style: const TextStyle(fontSize: 52)),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () => setState(() => _fotos.removeAt(indice)),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: corTexto,
                shape: BoxShape.circle,
                border: Border.all(color: corFundo, width: 2),
              ),
              child: const Icon(Icons.close, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _botaoAdicionarFoto() {
    return GestureDetector(
      onTap: () => _mostrarMensagem('Seleção de fotos ainda não implementada.'),
      child: CustomPaint(
        painter: _BordaTracejada(),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: corVerdeClaro,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📷', style: TextStyle(fontSize: 26)),
              SizedBox(height: 4),
              Text(
                'Adicionar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: corVerde,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = corVerde
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final caminho = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          const Radius.circular(18),
        ),
      );

    for (final medida in caminho.computeMetrics()) {
      double distancia = 0;
      while (distancia < medida.length) {
        canvas.drawPath(medida.extractPath(distancia, distancia + 6), pincel);
        distancia += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
