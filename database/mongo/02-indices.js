/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * ARQUIVO GERADO por scripts/gerar-mongo.js. Não editar à mão.
 */

(() => {
  const bd = db.getSiblingDB('cultmais');

  // usuarios
  bd.usuarios.createIndex({ email: 1 }, { unique: true, name: "email_unico" });

  // excedentes
  bd.excedentes.createIndex({ "localizacao.ponto": "2dsphere", status: 1, categoria: 1 }, { name: "geo_status_categoria" });
  bd.excedentes.createIndex({ "ofertante._id": 1, criadoEm: -1 }, { name: "ofertante_recentes" });

  // matches
  bd.matches.createIndex({ excedenteId: 1, interessadoId: 1 }, { unique: true, name: "match_unico" });
  bd.matches.createIndex({ participantes: 1, atualizadoEm: -1 }, { name: "conversas_do_usuario" });

  // mensagens
  bd.mensagens.createIndex({ matchId: 1, criadoEm: 1 }, { name: "mensagens_do_match" });

  for (const nome of ["usuarios", "excedentes", "matches", "mensagens"]) {
    print('Índices de ' + nome + ': ' + bd.getCollection(nome).getIndexes().map((i) => i.name).join(', '));
  }

})();
