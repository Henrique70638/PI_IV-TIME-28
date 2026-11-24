/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * Consultas principais do MVP, executadas sobre os dados de exemplo.
 */

(() => {
  const bd = db.getSiblingDB('cultmais');

  function mostrar(titulo, resultado) {
    print('\n=== ' + titulo + ' ===');
    printjson(resultado);
  }

  const marina = bd.usuarios.findOne({ email: 'marina@example.com' });
  const roberto = bd.usuarios.findOne({ email: 'roberto@example.com' });
  const raioKm = 5;

  const buscaProxima = (filtros) => bd.excedentes.aggregate([
    {
      $geoNear: {
        near: marina.localizacao,
        distanceField: 'distanciaM',
        maxDistance: raioKm * 1000,
        spherical: true,
        query: { status: 'disponivel', ...filtros },
      },
    },
    { $addFields: { distanciaKm: { $round: [{ $divide: ['$distanciaM', 1000] }, 1] } } },
    { $project: { produto: 1, quantidade: 1, unidade: 1, modalidade: 1, 'ofertante.nome': 1, 'localizacao.bairro': 1, distanciaKm: 1 } },
  ]).toArray();

  mostrar('1. Busca por proximidade e categoria (Home/Busca com filtros): frutas até 5 km', buscaProxima({ categoria: 'frutas' }));
  mostrar('2. Busca por proximidade, todas as categorias', buscaProxima({}));

  const manga = bd.excedentes.findOne({ produto: 'Manga Tommy' });
  mostrar('3. Detalhe da oferta, com dados públicos do ofertante', bd.excedentes.aggregate([
    { $match: { _id: manga._id } },
    { $lookup: { from: 'usuarios', localField: 'ofertante._id', foreignField: '_id', as: 'ofertanteDetalhe' } },
    {
      $project: {
        produto: 1,
        descricao: 1,
        categoria: 1,
        quantidade: 1,
        unidade: 1,
        urgencia: 1,
        modalidade: 1,
        fotos: 1,
        'localizacao.bairro': 1,
        'localizacao.cidade': 1,
        'ofertanteDetalhe.nome': 1,
        'ofertanteDetalhe.bairro': 1,
      },
    },
  ]).toArray());

  mostrar('4. Lista de conversas da Marina (mais recente primeiro)', bd.matches.find(
    { participantes: marina._id },
    { ofertanteNome: 1, interessadoNome: 1, status: 1, excedenteResumo: 1, ultimaMensagem: 1, atualizadoEm: 1 }
  ).sort({ atualizadoEm: -1 }).toArray());

  const conversa = bd.matches.findOne({ interessadoId: marina._id });
  mostrar('5. Mensagens do chat em ordem cronológica', bd.mensagens.find({ matchId: conversa._id }, { autorId: 1, texto: 1, criadoEm: 1 }).sort({ criadoEm: 1 }).toArray());

  mostrar('6. Meus excedentes (Roberto), mais recentes primeiro', bd.excedentes.find(
    { 'ofertante._id': roberto._id },
    { produto: 1, status: 1, criadoEm: 1 }
  ).sort({ criadoEm: -1 }).toArray());
})();
