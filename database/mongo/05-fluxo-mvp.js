/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * Percorre o fluxo principal do MVP (interesse, match, chat e conclusão) com um cenário temporário.
 * Tudo o que o script cria é removido no final e a oferta volta ao estado original.
 */

(() => {
  const bd = db.getSiblingDB('cultmais');

  const carla = bd.usuarios.findOne({ email: 'carla@example.com' });
  const oferta = bd.excedentes.findOne({ produto: 'Manga Tommy' });
  const estadoOriginal = { status: oferta.status, atualizadoEm: oferta.atualizadoEm };

  function distanciaKm(a, b) {
    const rad = (g) => (g * Math.PI) / 180;
    const dLat = rad(b[1] - a[1]);
    const dLng = rad(b[0] - a[0]);
    const h = Math.sin(dLat / 2) ** 2 + Math.cos(rad(a[1])) * Math.cos(rad(b[1])) * Math.sin(dLng / 2) ** 2;
    return 2 * 6371.0088 * Math.asin(Math.sqrt(h));
  }

  function limpar() {
    const antigo = bd.matches.findOne({ excedenteId: oferta._id, interessadoId: carla._id });
    if (antigo) {
      bd.mensagens.deleteMany({ matchId: antigo._id });
      bd.matches.deleteOne({ _id: antigo._id });
    }
    bd.excedentes.updateOne({ _id: oferta._id }, { $set: estadoOriginal });
  }

  function tentar(descricao, acao) {
    try {
      acao();
      print('FALHOU em bloquear: ' + descricao);
    } catch (e) {
      print('Bloqueado como esperado (' + descricao + '), código ' + e.code);
    }
  }

  limpar();

  const agora = new Date();
  const match = {
    _id: new ObjectId(),
    excedenteId: oferta._id,
    ofertanteId: oferta.ofertante._id,
    interessadoId: carla._id,
    ofertanteNome: oferta.ofertante.nome,
    interessadoNome: carla.nome,
    participantes: [oferta.ofertante._id, carla._id],
    status: 'conectado',
    criterios: {
      localizacao: true,
      categoria: true,
      distanciaKm: Math.round(distanciaKm(carla.localizacao.coordinates, oferta.localizacao.ponto.coordinates) * 10) / 10,
    },
    excedenteResumo: {
      produto: oferta.produto,
      categoria: oferta.categoria,
      modalidade: oferta.modalidade,
      quantidade: oferta.quantidade,
      unidade: oferta.unidade,
    },
    criadoEm: agora,
    atualizadoEm: agora,
  };

  bd.matches.insertOne(match);
  print('1. Match criado: ' + match._id + ' (distância ' + match.criterios.distanciaKm + ' km)');

  tentar('segundo match do mesmo interessado na mesma oferta', () => bd.matches.insertOne({ ...match, _id: new ObjectId() }));

  const texto = 'Oi! Tenho interesse nas mangas.';
  const envio = new Date();
  bd.mensagens.insertOne({ _id: new ObjectId(), matchId: match._id, autorId: carla._id, texto, criadoEm: envio });
  bd.matches.updateOne({ _id: match._id }, { $set: { ultimaMensagem: { texto, autorId: carla._id, criadoEm: envio }, atualizadoEm: envio } });
  print('2. Mensagem enviada e última mensagem atualizada no match');

  tentar('mensagem vazia', () => bd.mensagens.insertOne({ _id: new ObjectId(), matchId: match._id, autorId: carla._id, texto: '', criadoEm: new Date() }));
  tentar('oferta com quantidade zero', () => bd.excedentes.insertOne({ ...oferta, _id: new ObjectId(), quantidade: 0 }));

  const fim = new Date();
  bd.matches.updateOne({ _id: match._id }, { $set: { status: 'concluido', concluidoEm: fim, atualizadoEm: fim } });
  bd.excedentes.updateOne({ _id: oferta._id }, { $set: { status: 'concluido', atualizadoEm: fim } });
  print('3. Negociação concluída: match e oferta marcados como concluídos');
  printjson(bd.matches.findOne({ _id: match._id }, { status: 1, ultimaMensagem: 1, concluidoEm: 1 }));

  limpar();
  print('4. Cenário removido; a oferta voltou ao estado original (' + estadoOriginal.status + ').');
})();
