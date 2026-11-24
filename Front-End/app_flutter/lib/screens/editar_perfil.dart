// Autor: Rafaela Jacobsen Braga - RA: 25004280
import 'package:flutter/material.dart';
import '../services/perfil_service.dart';
import '../services/sessao.dart';

/// Edita a conta autenticada. Coordenadas só são enviadas quando a região muda.
class EditarPerfilPage extends StatefulWidget {
  final bool editarLocalizacao;
  const EditarPerfilPage({super.key, this.editarLocalizacao = false});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  static const verde = Color(0xFF267536);
  static const fundo = Color(0xFFF7F8F2);
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _email;
  final _senhaAtual = TextEditingController();
  late final TextEditingController _bairro;
  late final TextEditingController _cidade;
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  late String _perfil;
  late bool _mudarRegiao;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final usuario = Sessao.usuario ?? {};
    _nome = TextEditingController(text: usuario['nome']?.toString() ?? '');
    _email = TextEditingController(text: usuario['email']?.toString() ?? '');
    _bairro = TextEditingController(text: usuario['bairro']?.toString() ?? '');
    _cidade = TextEditingController(
      text: usuario['cidade']?.toString() ?? 'Campinas',
    );
    final atual = usuario['perfil']?.toString() ?? 'interessado';
    _perfil = ['ofertante', 'interessado', 'ambos'].contains(atual)
        ? atual
        : 'interessado';
    _mudarRegiao = widget.editarLocalizacao;
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senhaAtual.dispose();
    _bairro.dispose();
    _cidade.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Preencha este campo' : null;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _salvando) return;
    final dados = <String, dynamic>{
      'nome': _nome.text.trim(),
      'perfil': _perfil,
    };
    final emailNovo = _email.text.trim().toLowerCase();
    final emailAnterior = (Sessao.usuario?['email'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (emailNovo != emailAnterior) {
      // A API só aceita a troca do e-mail depois de confirmar a senha atual.
      dados['email'] = emailNovo;
      dados['senhaAtual'] = _senhaAtual.text;
    }
    if (_mudarRegiao) {
      final lat = double.tryParse(_latitude.text.trim().replaceAll(',', '.'));
      final lon = double.tryParse(_longitude.text.trim().replaceAll(',', '.'));
      if (lat == null ||
          lon == null ||
          lat < -90 ||
          lat > 90 ||
          lon < -180 ||
          lon > 180) {
        setState(
          () => _erro = 'Informe latitude e longitude válidas para a região.',
        );
        return;
      }
      dados.addAll({
        'bairro': _bairro.text.trim(),
        'cidade': _cidade.text.trim(),
        'latitude': lat,
        'longitude': lon,
      });
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await PerfilService().atualizar(dados);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: fundo,
        title: const Text('Configurações da conta'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
            children: [
              const Text(
                'Seus dados',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nome,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (valor) {
                  final email = valor?.trim() ?? '';
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                      ? null
                      : 'Informe um e-mail válido';
                },
              ),
              if (_email.text.trim().toLowerCase() !=
                  (Sessao.usuario?['email'] ?? '')
                      .toString()
                      .trim()
                      .toLowerCase()) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _senhaAtual,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha atual para confirmar a troca de e-mail',
                    border: OutlineInputBorder(),
                  ),
                  validator: _obrigatorio,
                ),
                const SizedBox(height: 8),
                const Text(
                  'A troca de e-mail exige sua senha atual. Confira o novo endereço antes de salvar.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: _perfil,
                decoration: const InputDecoration(
                  labelText: 'Tipo de usuário',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'ofertante',
                    child: Text('Ofertante'),
                  ),
                  DropdownMenuItem(
                    value: 'interessado',
                    child: Text('Interessado'),
                  ),
                  DropdownMenuItem(value: 'ambos', child: Text('Ambos')),
                ],
                onChanged: (valor) {
                  if (valor != null) setState(() => _perfil = valor);
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alterar minha localização'),
                subtitle: const Text(
                  'Atualiza a região usada para buscar e publicar excedentes.',
                ),
                activeThumbColor: verde,
                value: _mudarRegiao,
                onChanged: (valor) => setState(() => _mudarRegiao = valor),
              ),
              if (_mudarRegiao) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bairro,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    border: OutlineInputBorder(),
                  ),
                  validator: _obrigatorio,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cidade,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Cidade',
                    border: OutlineInputBorder(),
                  ),
                  validator: _obrigatorio,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Informe coordenadas aproximadas da região, não o endereço da sua casa.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          hintText: '-22.90',
                          border: OutlineInputBorder(),
                        ),
                        validator: _obrigatorio,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _longitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          hintText: '-47.06',
                          border: OutlineInputBorder(),
                        ),
                        validator: _obrigatorio,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _erro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 15),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Salvar alterações',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
