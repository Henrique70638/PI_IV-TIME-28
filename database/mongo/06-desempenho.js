/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * Mede o efeito dos índices. Gera ofertas sintéticas (marcadas com ofertante.nome = "SINTETICO"),
 * compara a consulta com índice e sem índice usando explain("executionStats") e remove os dados sintéticos no final.
 */

(() => {
  const bd = db.getSiblingDB('cultmais');
  const VOLUME = 20000;
  const MARCA = 'SINTETICO';
  const raioKm = 5;
  const centro = bd.usuarios.findOne({ email: 'marina@example.com' }).localizacao.coordinates;

  const categorias = ['frutas', 'verduras', 'legumes', 'mudas'];
  const unidades = { frutas: 'kg', verduras: 'maco', legumes: 'kg', mudas: 'muda' };
  const donos = Array.from({ length: 200 }, () => new ObjectId());
  const aleatorio = (a, b) => Number((a + Math.random() * (b - a)).toFixed(3));

  function sintetico(i) {
    const categoria = categorias[i % categorias.length];
    const agora = new Date();
    return {
      _id: new ObjectId(),
      ofertante: { _id: donos[i % donos.length], nome: MARCA },
      produto: 'Teste ' + i,
      categoria,
      quantidade: 1 + (i % 10),
      unidade: unidades[categoria],
      urgencia: 'sem_pressa',
      modalidade: i % 2 === 0 ? 'doacao' : 'venda',
      localizacao: { bairro: 'Teste', cidade: 'Campinas', ponto: { type: 'Point', coordinates: [aleatorio(-47.2, -46.95), aleatorio(-23.05, -22.8)] } },
      status: i % 10 === 0 ? 'concluido' : 'disponivel',
      criadoEm: agora,
      atualizadoEm: agora,
    };
  }

  function etapas(plano, lista = []) {
    if (!plano) return lista;
    if (plano.stage) lista.push(plano.stage);
    if (plano.inputStage) etapas(plano.inputStage, lista);
    (plano.inputStages || []).forEach((p) => etapas(p, lista));
    return lista;
  }

  function localizar(explicacao) {
    if (explicacao.queryPlanner) return explicacao;
    for (const etapa of explicacao.stages || []) {
      for (const valor of Object.values(etapa)) {
        if (valor && valor.queryPlanner) return valor;
      }
    }
    return null;
  }

  function resumo(titulo, explicacao) {
    const base = localizar(explicacao);
    print('\n' + titulo);
    if (!base) {
      print('  (plano não encontrado na saída do explain)');
      return;
    }
    const stats = base.executionStats || {};
    print('  Etapas do plano: ' + etapas(base.queryPlanner.winningPlan).join(' > '));
    print('  Documentos examinados: ' + stats.totalDocsExamined + ' | Chaves de índice examinadas: ' + stats.totalKeysExamined);
    print('  Documentos retornados: ' + stats.nReturned + ' | Tempo: ' + stats.executionTimeMillis + ' ms');
  }

  bd.excedentes.deleteMany({ 'ofertante.nome': MARCA });
  for (let inicio = 0; inicio < VOLUME; inicio += 1000) {
    bd.excedentes.insertMany(Array.from({ length: 1000 }, (_, k) => sintetico(inicio + k)));
  }
  print('Ofertas sintéticas inseridas: ' + bd.excedentes.countDocuments({ 'ofertante.nome': MARCA }));
  print('Total na coleção excedentes: ' + bd.excedentes.countDocuments());

  const filtroGeo = { status: 'disponivel', categoria: 'frutas', 'localizacao.ponto': { $geoWithin: { $centerSphere: [centro, raioKm / 6378.1] } } };
  resumo('A) Busca por proximidade e categoria, COM índice geo_status_categoria', bd.excedentes.find(filtroGeo).explain('executionStats'));
  resumo('B) Mesma busca SEM índice (varredura da coleção)', bd.excedentes.find(filtroGeo).hint({ $natural: 1 }).explain('executionStats'));

  resumo('C) $geoNear (consulta usada pelo servidor), ordenada pela distância', bd.excedentes.explain('executionStats').aggregate([
    { $geoNear: { near: { type: 'Point', coordinates: centro }, distanceField: 'distanciaM', maxDistance: raioKm * 1000, spherical: true, query: { status: 'disponivel', categoria: 'frutas' } } },
  ]));

  const filtroMeus = { 'ofertante._id': donos[0] };
  resumo('D) "Meus excedentes" COM índice ofertante_recentes', bd.excedentes.find(filtroMeus).sort({ criadoEm: -1 }).explain('executionStats'));
  resumo('E) "Meus excedentes" SEM índice', bd.excedentes.find(filtroMeus).sort({ criadoEm: -1 }).hint({ $natural: 1 }).explain('executionStats'));

  const apagadas = bd.excedentes.deleteMany({ 'ofertante.nome': MARCA }).deletedCount;
  print('\nDados sintéticos removidos: ' + apagadas);
})();
