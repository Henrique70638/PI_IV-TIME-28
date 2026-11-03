const { colecoes } = require('./schema');
const { geohash } = require('./geo');
const dados = require('./dados-exemplo');

const erros = [];
const erro = (onde, msg) => erros.push(`${onde}: ${msg}`);

function tipoOk(tipo, v) {
  switch (tipo) {
    case 'string': return typeof v === 'string' && v.length > 0;
    case 'number': return typeof v === 'number' && Number.isFinite(v);
    case 'boolean': return typeof v === 'boolean';
    case 'timestamp': return typeof v === 'string' && !Number.isNaN(Date.parse(v));
    case 'geopoint': return v && Math.abs(v.lat) <= 90 && Math.abs(v.lng) <= 180;
    case 'array<string>': return Array.isArray(v) && v.every((x) => typeof x === 'string');
    case 'map': return v && typeof v === 'object' && !Array.isArray(v);
    default: return false;
  }
}

function validaCampos(onde, campos, doc) {
  for (const chave of Object.keys(doc)) {
    if (!campos[chave]) erro(onde, `campo "${chave}" não existe no esquema`);
  }
  for (const [nome, def] of Object.entries(campos)) {
    const v = doc[nome];
    if (v === undefined) {
      if (def.obrigatorio) erro(onde, `campo obrigatório "${nome}" ausente`);
      continue;
    }
    if (!tipoOk(def.tipo, v)) { erro(onde, `"${nome}" deveria ser ${def.tipo}`); continue; }
    if (def.valores) {
      const lista = Array.isArray(v) ? v : [v];
      for (const item of lista) if (!def.valores.includes(item)) erro(onde, `"${nome}" com valor inválido "${item}"`);
    }
    if (def.tipo === 'map' && def.campos) validaCampos(`${onde}.${nome}`, def.campos, v);
  }
}

const idsUsuarios = new Set(dados.usuarios.map((u) => u.id));
const idsExcedentes = new Map(dados.excedentes.map((e) => [e.id, e]));
const perfilDe = (uid) => dados.usuarios.find((u) => u.id === uid).publico.perfil;

for (const u of dados.usuarios) {
  validaCampos(`usuarios/${u.id}`, colecoes.usuarios.campos, u.publico);
  validaCampos(`usuarios/${u.id}/privado/perfil`, colecoes['usuarios/{uid}/privado'].campos, u.privado);
  const { geo, geohash: gh } = u.privado.localizacao;
  if (gh !== geohash(geo.lat, geo.lng)) erro(`usuarios/${u.id}`, 'geohash não corresponde às coordenadas');
}

for (const e of dados.excedentes) {
  const { id, ...doc } = e;
  validaCampos(`excedentes/${id}`, colecoes.excedentes.campos, doc);
  if (!idsUsuarios.has(e.ofertanteId)) erro(`excedentes/${id}`, 'ofertanteId não existe');
  else if (!['ofertante', 'ambos'].includes(perfilDe(e.ofertanteId))) erro(`excedentes/${id}`, 'usuário não tem perfil de ofertante');
  const nome = dados.usuarios.find((u) => u.id === e.ofertanteId)?.publico.nome;
  if (e.ofertanteNome !== nome) erro(`excedentes/${id}`, 'ofertanteNome diverge de usuarios');
  const { geoAproximada: g, geohash: gh } = e.localizacao;
  if (gh !== geohash(g.lat, g.lng)) erro(`excedentes/${id}`, 'geohash não corresponde às coordenadas');
  if (e.fotos.length > 3) erro(`excedentes/${id}`, 'mais de 3 fotos');
  if (e.quantidade <= 0) erro(`excedentes/${id}`, 'quantidade deve ser maior que 0');
}

for (const m of dados.matches) {
  const { id, mensagens, ...doc } = m;
  const onde = `matches/${id}`;
  validaCampos(onde, colecoes.matches.campos, doc);
  const ex = idsExcedentes.get(m.excedenteId);
  if (!ex) { erro(onde, 'excedenteId não existe'); continue; }
  if (id !== `${m.excedenteId}_${m.interessadoId}`) erro(onde, 'ID diferente de excedenteId_interessadoId');
  if (m.ofertanteId !== ex.ofertanteId) erro(onde, 'ofertanteId diverge do excedente');
  if (m.ofertanteId === m.interessadoId) erro(onde, 'ofertante e interessado são o mesmo usuário');
  if (!['interessado', 'ambos'].includes(perfilDe(m.interessadoId))) erro(onde, 'usuário não tem perfil de interessado');
  if (JSON.stringify(m.participantes) !== JSON.stringify([m.ofertanteId, m.interessadoId])) erro(onde, 'participantes inconsistente');
  if (m.excedenteResumo.categoria !== ex.categoria || m.excedenteResumo.produto !== ex.produto) erro(onde, 'excedenteResumo diverge do excedente');
  if (m.ofertanteNome !== ex.ofertanteNome) erro(onde, 'ofertanteNome diverge');
  if (m.status === 'concluido' && !m.concluidoEm) erro(onde, 'status concluido sem concluidoEm');
  if (m.status !== 'concluido' && m.concluidoEm) erro(onde, 'concluidoEm preenchido sem status concluido');
  if (m.status === 'concluido' && ex.status !== 'concluido') erro(onde, 'match concluído, mas excedente não está concluído');
  mensagens.forEach((msg) => {
    const { id: mid, ...mdoc } = msg;
    validaCampos(`${onde}/mensagens/${mid}`, colecoes['matches/{matchId}/mensagens'].campos, mdoc);
    if (!m.participantes.includes(msg.autorId)) erro(`${onde}/mensagens/${mid}`, 'autor não participa do match');
  });
  const ultima = mensagens[mensagens.length - 1];
  if (m.ultimaMensagem.texto !== ultima.texto || m.ultimaMensagem.criadoEm !== ultima.criadoEm) erro(onde, 'ultimaMensagem diverge da última mensagem');
}

if (erros.length) {
  console.error(`${erros.length} problema(s) encontrado(s):\n- ${erros.join('\n- ')}`);
  process.exit(1);
}
console.log(`validar-dados.js: ok (${dados.usuarios.length} usuários, ${dados.excedentes.length} excedentes, ${dados.matches.length} matches, ${dados.matches.reduce((n, m) => n + m.mensagens.length, 0)} mensagens)`);
