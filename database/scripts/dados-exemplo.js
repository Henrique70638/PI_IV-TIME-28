const { geohash, distanciaKm } = require('./geo');

const arredonda = (n, casas) => Number(n.toFixed(casas));
const geoPrivado = (lat, lng) => ({ geo: { lat, lng }, geohash: geohash(lat, lng) });
const geoAproximada = (lat, lng) => ({ lat: arredonda(lat, 3), lng: arredonda(lng, 3) });
const iso = (dia, hora, min = 0) => `2026-10-${dia}T${String(hora).padStart(2, '0')}:${String(min).padStart(2, '0')}:00Z`;

const usuarios = [
  { id: 'u_roberto', nome: 'Roberto C.', perfil: 'ofertante', bairro: 'Jardim das Flores', cidade: 'Campinas', lat: -22.9208, lng: -47.0651, criadoEm: iso(20, 14) },
  { id: 'u_marina', nome: 'Marina S.', perfil: 'interessado', bairro: 'Jardim das Flores', cidade: 'Campinas', lat: -22.91, lng: -47.065, criadoEm: iso(21, 13) },
  { id: 'u_carla', nome: 'Carla M.', perfil: 'ambos', bairro: 'Vila Esperança', cidade: 'Campinas', lat: -22.903, lng: -47.058, criadoEm: iso(22, 15) },
  { id: 'u_joao', nome: 'João P.', perfil: 'ofertante', bairro: 'Parque Verde', cidade: 'Campinas', lat: -22.888, lng: -47.065, criadoEm: iso(22, 16) },
].map((u) => ({
  id: u.id,
  publico: { nome: u.nome, perfil: u.perfil, bairro: u.bairro, cidade: u.cidade, criadoEm: u.criadoEm },
  privado: { localizacao: geoPrivado(u.lat, u.lng), atualizadoEm: u.criadoEm },
}));

const nomeDe = (uid) => usuarios.find((u) => u.id === uid).publico.nome;
const geoDe = (uid) => usuarios.find((u) => u.id === uid).privado.localizacao.geo;

const excedente = (id, ofertanteId, produto, descricao, categoria, quantidade, unidade, urgencia, modalidade, bairro, lat, lng, status, criadoEm) => {
  const geo = geoAproximada(lat, lng);
  return {
    id,
    ofertanteId,
    ofertanteNome: nomeDe(ofertanteId),
    produto,
    descricao,
    categoria,
    quantidade,
    unidade,
    urgencia,
    modalidade,
    localizacao: { bairro, cidade: 'Campinas', geoAproximada: geo, geohash: geohash(geo.lat, geo.lng) },
    fotos: [`excedentes/${id}/1.jpg`],
    status,
    criadoEm,
    atualizadoEm: criadoEm,
  };
};

const excedentes = [
  excedente('exc_manga_tommy', 'u_roberto', 'Manga Tommy', 'Mangas colhidas hoje, quintal com sombra parcial. Ideal para consumo imediato ou doces caseiros.', 'frutas', 5, 'kg', 'alguns_dias', 'doacao', 'Jardim das Flores', -22.9208, -47.065, 'disponivel', iso(29, 11)),
  excedente('exc_limao_taiti', 'u_joao', 'Limão Taiti', 'Limões do pé do quintal, sem agrotóxicos.', 'frutas', 3, 'kg', 'alguns_dias', 'doacao', 'Parque Verde', -22.888, -47.065, 'disponivel', iso(28, 10)),
  excedente('exc_banana_prata', 'u_carla', 'Banana prata', 'Dois cachos maduros.', 'frutas', 2, 'cacho', 'hoje', 'venda', 'Vila Esperança', -22.91, -47.036, 'disponivel', iso(28, 17)),
  excedente('exc_laranja_pera', 'u_joao', 'Laranja pera', 'Laranjas doces, boas para suco.', 'frutas', 8, 'kg', 'alguns_dias', 'venda', 'Parque Verde', -22.944, -47.065, 'disponivel', iso(27, 12)),
  excedente('exc_maca', 'u_carla', 'Maçã', 'Maçãs de uma árvore pequena.', 'frutas', 4, 'kg', 'sem_pressa', 'doacao', 'Vila Esperança', -22.91, -47.107, 'disponivel', iso(27, 18)),
  excedente('exc_alface_crespa', 'u_roberto', 'Alface crespa', 'Horta de casa, colhida na hora.', 'verduras', 12, 'maco', 'hoje', 'doacao', 'Jardim das Flores', -22.919, -47.067, 'concluido', iso(26, 9)),
  excedente('exc_mudas_manjericao', 'u_carla', 'Mudas de manjericão', 'Mudas prontas para replantio.', 'mudas', 8, 'muda', 'sem_pressa', 'doacao', 'Vila Esperança', -22.903, -47.058, 'disponivel', iso(25, 16)),
];

const excedenteDe = (id) => excedentes.find((e) => e.id === id);

const match = (excedenteId, interessadoId, status, criadoEm, mensagens, concluidoEm) => {
  const ex = excedenteDe(excedenteId);
  const g = geoDe(interessadoId);
  const msgs = mensagens.map((m, i) => ({ id: `msg_${String(i + 1).padStart(3, '0')}`, autorId: m[0], texto: m[1], criadoEm: m[2] }));
  const ultima = msgs[msgs.length - 1];
  const doc = {
    id: `${excedenteId}_${interessadoId}`,
    excedenteId,
    ofertanteId: ex.ofertanteId,
    interessadoId,
    ofertanteNome: ex.ofertanteNome,
    interessadoNome: nomeDe(interessadoId),
    participantes: [ex.ofertanteId, interessadoId],
    status,
    criterios: {
      localizacao: true,
      categoria: true,
      distanciaKm: arredonda(distanciaKm(g.lat, g.lng, ex.localizacao.geoAproximada.lat, ex.localizacao.geoAproximada.lng), 1),
    },
    excedenteResumo: { produto: ex.produto, categoria: ex.categoria, modalidade: ex.modalidade, quantidade: ex.quantidade, unidade: ex.unidade },
    ultimaMensagem: { texto: ultima.texto, autorId: ultima.autorId, criadoEm: ultima.criadoEm },
    criadoEm,
    atualizadoEm: concluidoEm || ultima.criadoEm,
    mensagens: msgs,
  };
  if (concluidoEm) doc.concluidoEm = concluidoEm;
  return doc;
};

const matches = [
  match('exc_manga_tommy', 'u_marina', 'conectado', iso(29, 12, 37), [
    ['u_marina', 'Oi, Roberto! Tenho interesse nas mangas 😊', iso(29, 12, 38)],
    ['u_roberto', 'Oi! Que bom! Colhi hoje cedo, ainda tem bastante.', iso(29, 12, 39)],
    ['u_marina', 'Posso retirar amanhã às 9h, aí na sua casa?', iso(29, 12, 40)],
    ['u_roberto', 'Pode sim! Te envio o endereço certinho por aqui.', iso(29, 12, 41)],
    ['u_marina', 'Combinado, obrigado! 🙌', iso(29, 12, 41)],
  ]),
  match('exc_alface_crespa', 'u_carla', 'concluido', iso(26, 11), [
    ['u_carla', 'Olá! Posso buscar as alfaces hoje à tarde?', iso(26, 11, 5)],
    ['u_roberto', 'Pode sim, estou em casa até as 18h.', iso(26, 11, 8)],
    ['u_carla', 'Retirei, muito obrigada!', iso(26, 20)],
  ], iso(26, 20, 10)),
];

module.exports = { usuarios, excedentes, matches };
