/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const { colecoes, jsonSchemaDe } = require('./schema');
const { validarDocumento } = require('./validador-schema');
const dados = require('./dados-exemplo');

const { idDe } = dados;
const erros = [];
const erro = (onde, msg) => erros.push(`${onde}: ${msg}`);

for (const nome of Object.keys(colecoes)) {
  const esquema = jsonSchemaDe(nome);
  for (const doc of dados[nome]) {
    for (const e of validarDocumento(doc, esquema, `${nome}/${idDe(doc)}`)) erros.push(e);
  }
}

const coordenadasValidas = (p) => p.coordinates[0] >= -180 && p.coordinates[0] <= 180 && p.coordinates[1] >= -90 && p.coordinates[1] <= 90;
const emails = new Set();
const mesmo = (a, b) => JSON.stringify(a) === JSON.stringify(b);

for (const u of dados.usuarios) {
  const onde = `usuarios/${idDe(u)}`;
  if (emails.has(u.email)) erro(onde, 'e-mail repetido');
  emails.add(u.email);
  if (!coordenadasValidas(u.localizacao)) erro(onde, 'coordenadas fora do intervalo');
}

for (const e of dados.excedentes) {
  const onde = `excedentes/${idDe(e)}`;
  const dono = dados.usuarioPorId(e.ofertante._id.$oid);
  if (!dono) erro(onde, 'ofertante não existe');
  else {
    if (!['ofertante', 'ambos'].includes(dono.perfil)) erro(onde, 'usuário não tem perfil de ofertante');
    if (dono.nome !== e.ofertante.nome) erro(onde, 'ofertante.nome diverge de usuarios');
  }
  if (!coordenadasValidas(e.localizacao.ponto)) erro(onde, 'coordenadas fora do intervalo');
}

const paresDeMatch = new Set();
for (const m of dados.matches) {
  const onde = `matches/${idDe(m)}`;
  const ex = dados.excedentePorId(m.excedenteId.$oid);
  const interessado = dados.usuarioPorId(m.interessadoId.$oid);
  const ofertante = dados.usuarioPorId(m.ofertanteId.$oid);
  if (!ex || !interessado || !ofertante) { erro(onde, 'referência inexistente'); continue; }

  const par = `${m.excedenteId.$oid}_${m.interessadoId.$oid}`;
  if (paresDeMatch.has(par)) erro(onde, 'par oferta/interessado repetido');
  paresDeMatch.add(par);

  if (m.ofertanteId.$oid !== ex.ofertante._id.$oid) erro(onde, 'ofertanteId diverge da oferta');
  if (m.ofertanteId.$oid === m.interessadoId.$oid) erro(onde, 'ofertante e interessado são o mesmo usuário');
  if (!['interessado', 'ambos'].includes(interessado.perfil)) erro(onde, 'usuário não tem perfil de interessado');
  if (!mesmo(m.participantes, [m.ofertanteId, m.interessadoId])) erro(onde, 'participantes inconsistente');
  if (m.ofertanteNome !== ofertante.nome || m.interessadoNome !== interessado.nome) erro(onde, 'nomes divergem de usuarios');
  const r = m.excedenteResumo;
  if (r.produto !== ex.produto || r.categoria !== ex.categoria || r.modalidade !== ex.modalidade || r.quantidade !== ex.quantidade || r.unidade !== ex.unidade) erro(onde, 'excedenteResumo diverge da oferta');
  if (m.status === 'concluido' && !m.concluidoEm) erro(onde, 'status concluido sem concluidoEm');
  if (m.status !== 'concluido' && m.concluidoEm) erro(onde, 'concluidoEm preenchido sem status concluido');
  if (m.status === 'concluido' && ex.status !== 'concluido') erro(onde, 'match concluído, mas a oferta não está concluída');

  const doMatch = dados.mensagens.filter((x) => x.matchId.$oid === m._id.$oid);
  if (!doMatch.length) erro(onde, 'match sem mensagens');
  else if (!mesmo(m.ultimaMensagem.criadoEm, doMatch[doMatch.length - 1].criadoEm) || m.ultimaMensagem.texto !== doMatch[doMatch.length - 1].texto) erro(onde, 'ultimaMensagem diverge da última mensagem');
}

for (const msg of dados.mensagens) {
  const onde = `mensagens/${idDe(msg)}`;
  const m = dados.matches.find((x) => x._id.$oid === msg.matchId.$oid);
  if (!m) erro(onde, 'matchId inexistente');
  else if (!m.participantes.some((p) => p.$oid === msg.autorId.$oid)) erro(onde, 'autor não participa do match');
}

if (erros.length) {
  console.error(`${erros.length} problema(s) encontrado(s):\n- ${erros.join('\n- ')}`);
  process.exit(1);
}
console.log(`validar-dados.js: ok (${dados.usuarios.length} usuários, ${dados.excedentes.length} excedentes, ${dados.matches.length} matches, ${dados.mensagens.length} mensagens)`);
