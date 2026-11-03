/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const { distanciaKm } = require('./geo');

const oid = (prefixo, n) => ({ $oid: prefixo + String(n).padStart(22, '0') });
const data = (dia, hora, min = 0) => ({ $date: `2026-10-${String(dia).padStart(2, '0')}T${String(hora).padStart(2, '0')}:${String(min).padStart(2, '0')}:00.000Z` });
const ponto = (lat, lng) => ({ type: 'Point', coordinates: [lng, lat] });
const arredonda = (n, casas) => Number(n.toFixed(casas));
const pontoAproximado = (lat, lng) => ponto(arredonda(lat, 3), arredonda(lng, 3));
const idDe = (documento) => documento._id.$oid;
const latLngDe = (p) => ({ lat: p.coordinates[1], lng: p.coordinates[0] });

const SENHA_HASH_EXEMPLO = '$2a$10$' + 'x'.repeat(53);

const usuario = (n, nome, email, perfil, bairro, lat, lng, dia, hora) => ({
  _id: oid('a1', n),
  nome,
  email,
  senhaHash: SENHA_HASH_EXEMPLO,
  perfil,
  bairro,
  cidade: 'Campinas',
  localizacao: ponto(lat, lng),
  criadoEm: data(dia, hora),
});

const usuarios = [
  usuario(1, 'Roberto C.', 'roberto@example.com', 'ofertante', 'Jardim das Flores', -22.9208, -47.0651, 20, 14),
  usuario(2, 'Marina S.', 'marina@example.com', 'interessado', 'Jardim das Flores', -22.91, -47.065, 21, 13),
  usuario(3, 'Carla M.', 'carla@example.com', 'ambos', 'Vila Esperança', -22.903, -47.058, 22, 15),
  usuario(4, 'João P.', 'joao@example.com', 'ofertante', 'Parque Verde', -22.888, -47.065, 22, 16),
];

const usuarioPorId = (idHex) => usuarios.find((u) => idDe(u) === idHex);

const excedente = (n, ofertanteN, produto, descricao, categoria, quantidade, unidade, urgencia, modalidade, bairro, lat, lng, status, criadoEm) => {
  const dono = usuarios[ofertanteN - 1];
  return {
    _id: oid('b2', n),
    ofertante: { _id: dono._id, nome: dono.nome },
    produto,
    descricao,
    categoria,
    quantidade,
    unidade,
    urgencia,
    modalidade,
    localizacao: { bairro, cidade: 'Campinas', ponto: pontoAproximado(lat, lng) },
    fotos: [`excedentes/${n}/1.jpg`],
    status,
    criadoEm,
    atualizadoEm: criadoEm,
  };
};

const excedentes = [
  excedente(1, 1, 'Manga Tommy', 'Mangas colhidas hoje, quintal com sombra parcial. Ideal para consumo imediato ou doces caseiros.', 'frutas', 5, 'kg', 'alguns_dias', 'doacao', 'Jardim das Flores', -22.9208, -47.065, 'disponivel', data(29, 11)),
  excedente(2, 4, 'Limão Taiti', 'Limões do pé do quintal, sem agrotóxicos.', 'frutas', 3, 'kg', 'alguns_dias', 'doacao', 'Parque Verde', -22.888, -47.065, 'disponivel', data(28, 10)),
  excedente(3, 3, 'Banana prata', 'Dois cachos maduros.', 'frutas', 2, 'cacho', 'hoje', 'venda', 'Vila Esperança', -22.91, -47.036, 'disponivel', data(28, 17)),
  excedente(4, 4, 'Laranja pera', 'Laranjas doces, boas para suco.', 'frutas', 8, 'kg', 'alguns_dias', 'venda', 'Parque Verde', -22.944, -47.065, 'disponivel', data(27, 12)),
  excedente(5, 3, 'Maçã', 'Maçãs de uma árvore pequena.', 'frutas', 4, 'kg', 'sem_pressa', 'doacao', 'Vila Esperança', -22.91, -47.107, 'disponivel', data(27, 18)),
  excedente(6, 1, 'Alface crespa', 'Horta de casa, colhida na hora.', 'verduras', 12, 'maco', 'hoje', 'doacao', 'Jardim das Flores', -22.919, -47.067, 'concluido', data(26, 9)),
  excedente(7, 3, 'Mudas de manjericão', 'Mudas prontas para replantio.', 'mudas', 8, 'muda', 'sem_pressa', 'doacao', 'Vila Esperança', -22.903, -47.058, 'disponivel', data(25, 16)),
];

const excedentePorId = (idHex) => excedentes.find((e) => idDe(e) === idHex);

const match = (n, excedenteN, interessadoN, status, criadoEm, concluidoEm) => {
  const ex = excedentes[excedenteN - 1];
  const interessado = usuarios[interessadoN - 1];
  const a = latLngDe(interessado.localizacao);
  const b = latLngDe(ex.localizacao.ponto);
  const doc = {
    _id: oid('c3', n),
    excedenteId: ex._id,
    ofertanteId: ex.ofertante._id,
    interessadoId: interessado._id,
    ofertanteNome: ex.ofertante.nome,
    interessadoNome: interessado.nome,
    participantes: [ex.ofertante._id, interessado._id],
    status,
    criterios: { localizacao: true, categoria: true, distanciaKm: arredonda(distanciaKm(a.lat, a.lng, b.lat, b.lng), 1) },
    excedenteResumo: { produto: ex.produto, categoria: ex.categoria, modalidade: ex.modalidade, quantidade: ex.quantidade, unidade: ex.unidade },
    criadoEm,
    atualizadoEm: criadoEm,
  };
  if (concluidoEm) doc.concluidoEm = concluidoEm;
  return doc;
};

const matches = [
  match(1, 1, 2, 'conectado', data(29, 12, 37)),
  match(2, 6, 3, 'concluido', data(26, 11), data(26, 20, 10)),
];

const mensagem = (n, matchN, autorN, texto, criadoEm) => ({
  _id: oid('d4', n),
  matchId: matches[matchN - 1]._id,
  autorId: usuarios[autorN - 1]._id,
  texto,
  criadoEm,
});

const mensagens = [
  mensagem(1, 1, 2, 'Oi, Roberto! Tenho interesse nas mangas 😊', data(29, 12, 38)),
  mensagem(2, 1, 1, 'Oi! Que bom! Colhi hoje cedo, ainda tem bastante.', data(29, 12, 39)),
  mensagem(3, 1, 2, 'Posso retirar amanhã às 9h, aí na sua casa?', data(29, 12, 40)),
  mensagem(4, 1, 1, 'Pode sim! Te envio o endereço certinho por aqui.', data(29, 12, 41)),
  mensagem(5, 1, 2, 'Combinado, obrigado! 🙌', data(29, 12, 41)),
  mensagem(6, 2, 3, 'Olá! Posso buscar as alfaces hoje à tarde?', data(26, 11, 5)),
  mensagem(7, 2, 1, 'Pode sim, estou em casa até as 18h.', data(26, 11, 8)),
  mensagem(8, 2, 3, 'Retirei, muito obrigada!', data(26, 20)),
];

for (const m of matches) {
  const ultimas = mensagens.filter((x) => x.matchId.$oid === m._id.$oid);
  const ultima = ultimas[ultimas.length - 1];
  m.ultimaMensagem = { texto: ultima.texto, autorId: ultima.autorId, criadoEm: ultima.criadoEm };
  m.atualizadoEm = m.concluidoEm || ultima.criadoEm;
}

module.exports = { usuarios, excedentes, matches, mensagens, usuarioPorId, excedentePorId, idDe };
