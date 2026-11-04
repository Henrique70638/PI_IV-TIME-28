/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * Indicadores do MVP: excedentes cadastrados, matches gerados, negociações concluídas e distância média.
 */

(() => {
  const bd = db.getSiblingDB('cultmais');

  const contagem = (colecao, campo) => bd.getCollection(colecao).aggregate([
    { $group: { _id: '$' + campo, total: { $sum: 1 } } },
    { $sort: { _id: 1 } },
  ]).toArray().map((l) => '  ' + l._id + ': ' + l.total).join('\n');

  print('Usuários por perfil\n' + contagem('usuarios', 'perfil'));
  print('\nExcedentes cadastrados: ' + bd.excedentes.countDocuments());
  print(contagem('excedentes', 'categoria'));
  print('Excedentes por status\n' + contagem('excedentes', 'status'));

  const totalMatches = bd.matches.countDocuments();
  const concluidos = bd.matches.countDocuments({ status: 'concluido' });
  print('\nMatches gerados: ' + totalMatches);
  print('Negociações concluídas: ' + concluidos);
  if (totalMatches > 0) print('Taxa de conclusão: ' + Math.round((concluidos / totalMatches) * 100) + '%');

  const media = bd.matches.aggregate([{ $group: { _id: null, distanciaMediaKm: { $avg: '$criterios.distanciaKm' } } }]).toArray();
  if (media.length) print('Distância média dos matches: ' + media[0].distanciaMediaKm.toFixed(1) + ' km');
})();
