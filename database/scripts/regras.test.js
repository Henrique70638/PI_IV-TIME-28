/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const fs = require('fs');
const path = require('path');
const { describe, it, before, after, beforeEach } = require('node:test');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, collection, getDoc, setDoc, updateDoc, deleteDoc, serverTimestamp, Timestamp, GeoPoint } = require('firebase/firestore');

let env;

const como = (uid) => env.authenticatedContext(uid).firestore();
const anonimo = () => env.unauthenticatedContext().firestore();

const localizacao = () => ({
  bairro: 'Jardim das Flores',
  cidade: 'Campinas',
  geoAproximada: new GeoPoint(-22.921, -47.065),
  geohash: '6gyt95276p',
});

const excedenteNovo = (uid, nome, extra = {}) => ({
  ofertanteId: uid,
  ofertanteNome: nome,
  produto: 'Manga Tommy',
  categoria: 'frutas',
  quantidade: 5,
  unidade: 'kg',
  urgencia: 'alguns_dias',
  modalidade: 'doacao',
  localizacao: localizacao(),
  fotos: [],
  status: 'disponivel',
  criadoEm: serverTimestamp(),
  atualizadoEm: serverTimestamp(),
  ...extra,
});

const matchNovo = (excedenteId, ofertanteId, interessadoId, extra = {}) => ({
  excedenteId,
  ofertanteId,
  interessadoId,
  ofertanteNome: 'Roberto C.',
  interessadoNome: 'Marina S.',
  participantes: [ofertanteId, interessadoId],
  status: 'conectado',
  criterios: { localizacao: true, categoria: true, distanciaKm: 1.2 },
  excedenteResumo: { produto: 'Manga Tommy', categoria: 'frutas', modalidade: 'doacao', quantidade: 5, unidade: 'kg' },
  criadoEm: serverTimestamp(),
  atualizadoEm: serverTimestamp(),
  ...extra,
});

const mensagemNova = (autorId, extra = {}) => ({ autorId, texto: 'Oi, tudo bem?', criadoEm: serverTimestamp(), ...extra });

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'cult-mais-dev',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore', 'firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (contexto) => {
    const db = contexto.firestore();
    const agora = Timestamp.now();
    const usuario = (id, nome, perfil) => setDoc(doc(db, 'usuarios', id), { nome, perfil, bairro: 'Jardim das Flores', cidade: 'Campinas', criadoEm: agora });

    await usuario('u_roberto', 'Roberto C.', 'ofertante');
    await usuario('u_marina', 'Marina S.', 'interessado');
    await usuario('u_carla', 'Carla M.', 'ambos');
    await usuario('u_estranho', 'Pessoa Estranha', 'interessado');
    await setDoc(doc(db, 'usuarios/u_marina/privado/perfil'), { localizacao: { geo: new GeoPoint(-22.91, -47.065), geohash: '6gyt9fwqkz' }, atualizadoEm: agora });

    await setDoc(doc(db, 'excedentes/exc_1'), excedenteNovo('u_roberto', 'Roberto C.', { criadoEm: agora, atualizadoEm: agora }));
    await setDoc(doc(db, 'matches/exc_1_u_marina'), matchNovo('exc_1', 'u_roberto', 'u_marina', { criadoEm: agora, atualizadoEm: agora }));
  });
});

describe('usuarios', () => {
  it('visitante sem login não lê perfis', async () => {
    await assertFails(getDoc(doc(anonimo(), 'usuarios/u_roberto')));
  });

  it('usuário logado lê o perfil público de outro', async () => {
    await assertSucceeds(getDoc(doc(como('u_marina'), 'usuarios/u_roberto')));
  });

  it('usuário cria o próprio perfil', async () => {
    const dados = { nome: 'Novo Usuário', perfil: 'ambos', bairro: 'Centro', cidade: 'Campinas', criadoEm: serverTimestamp() };
    await assertSucceeds(setDoc(doc(como('u_novo'), 'usuarios/u_novo'), dados));
  });

  it('usuário não cria perfil em nome de outro', async () => {
    const dados = { nome: 'Intruso', perfil: 'ambos', bairro: 'Centro', cidade: 'Campinas', criadoEm: serverTimestamp() };
    await assertFails(setDoc(doc(como('u_estranho'), 'usuarios/u_outro'), dados));
  });

  it('perfil com valor inválido é recusado', async () => {
    const dados = { nome: 'Novo', perfil: 'administrador', bairro: 'Centro', cidade: 'Campinas', criadoEm: serverTimestamp() };
    await assertFails(setDoc(doc(como('u_novo'), 'usuarios/u_novo'), dados));
  });

  it('usuário não grava a própria avaliação média', async () => {
    await assertFails(updateDoc(doc(como('u_roberto'), 'usuarios/u_roberto'), { avaliacaoMedia: 5 }));
  });

  it('dados privados só são lidos pelo dono', async () => {
    await assertSucceeds(getDoc(doc(como('u_marina'), 'usuarios/u_marina/privado/perfil')));
    await assertFails(getDoc(doc(como('u_roberto'), 'usuarios/u_marina/privado/perfil')));
  });
});

describe('excedentes', () => {
  it('visitante sem login não lê ofertas', async () => {
    await assertFails(getDoc(doc(anonimo(), 'excedentes/exc_1')));
  });

  it('usuário logado lê ofertas', async () => {
    await assertSucceeds(getDoc(doc(como('u_marina'), 'excedentes/exc_1')));
  });

  it('ofertante publica uma oferta válida', async () => {
    await assertSucceeds(setDoc(doc(como('u_roberto'), 'excedentes/exc_2'), excedenteNovo('u_roberto', 'Roberto C.')));
  });

  it('usuário com perfil só de interessado não publica', async () => {
    await assertFails(setDoc(doc(como('u_marina'), 'excedentes/exc_2'), excedenteNovo('u_marina', 'Marina S.')));
  });

  it('ofertante não publica em nome de outro usuário', async () => {
    await assertFails(setDoc(doc(como('u_roberto'), 'excedentes/exc_2'), excedenteNovo('u_carla', 'Carla M.')));
  });

  it('categoria fora da lista é recusada', async () => {
    await assertFails(setDoc(doc(como('u_roberto'), 'excedentes/exc_2'), excedenteNovo('u_roberto', 'Roberto C.', { categoria: 'carnes' })));
  });

  it('quantidade zero é recusada', async () => {
    await assertFails(setDoc(doc(como('u_roberto'), 'excedentes/exc_2'), excedenteNovo('u_roberto', 'Roberto C.', { quantidade: 0 })));
  });

  it('mais de 3 fotos é recusado', async () => {
    await assertFails(setDoc(doc(como('u_roberto'), 'excedentes/exc_2'), excedenteNovo('u_roberto', 'Roberto C.', { fotos: ['a', 'b', 'c', 'd'] })));
  });

  it('oferta nova precisa nascer como disponível', async () => {
    await assertFails(setDoc(doc(como('u_roberto'), 'excedentes/exc_2'), excedenteNovo('u_roberto', 'Roberto C.', { status: 'concluido' })));
  });

  it('só o ofertante altera a própria oferta', async () => {
    await assertSucceeds(updateDoc(doc(como('u_roberto'), 'excedentes/exc_1'), { status: 'removido', atualizadoEm: serverTimestamp() }));
    await assertFails(updateDoc(doc(como('u_marina'), 'excedentes/exc_1'), { status: 'removido', atualizadoEm: serverTimestamp() }));
  });

  it('ninguém apaga uma oferta', async () => {
    await assertFails(deleteDoc(doc(como('u_roberto'), 'excedentes/exc_1')));
  });
});

describe('matches', () => {
  it('interessado cria um match válido', async () => {
    await assertSucceeds(setDoc(doc(como('u_carla'), 'matches/exc_1_u_carla'), matchNovo('exc_1', 'u_roberto', 'u_carla', { interessadoNome: 'Carla M.' })));
  });

  it('ID do match diferente de excedenteId_interessadoId é recusado', async () => {
    await assertFails(setDoc(doc(como('u_carla'), 'matches/qualquer_id'), matchNovo('exc_1', 'u_roberto', 'u_carla')));
  });

  it('match sem os critérios de localização e categoria é recusado', async () => {
    const criterios = { localizacao: true, categoria: false, distanciaKm: 1.2 };
    await assertFails(setDoc(doc(como('u_carla'), 'matches/exc_1_u_carla'), matchNovo('exc_1', 'u_roberto', 'u_carla', { criterios })));
  });

  it('ofertante não cria match na própria oferta', async () => {
    await assertFails(setDoc(doc(como('u_roberto'), 'matches/exc_1_u_roberto'), matchNovo('exc_1', 'u_roberto', 'u_roberto')));
  });

  it('usuário não cria match em nome de outro interessado', async () => {
    await assertFails(setDoc(doc(como('u_estranho'), 'matches/exc_1_u_carla'), matchNovo('exc_1', 'u_roberto', 'u_carla')));
  });

  it('não há match em oferta que não está disponível', async () => {
    await env.withSecurityRulesDisabled(async (contexto) => {
      await updateDoc(doc(contexto.firestore(), 'excedentes/exc_1'), { status: 'concluido' });
    });
    await assertFails(setDoc(doc(como('u_carla'), 'matches/exc_1_u_carla'), matchNovo('exc_1', 'u_roberto', 'u_carla')));
  });

  it('só os dois participantes leem o match', async () => {
    await assertSucceeds(getDoc(doc(como('u_marina'), 'matches/exc_1_u_marina')));
    await assertSucceeds(getDoc(doc(como('u_roberto'), 'matches/exc_1_u_marina')));
    await assertFails(getDoc(doc(como('u_estranho'), 'matches/exc_1_u_marina')));
  });

  it('só o ofertante conclui a negociação', async () => {
    const conclusao = () => ({ status: 'concluido', concluidoEm: serverTimestamp(), atualizadoEm: serverTimestamp() });
    await assertFails(updateDoc(doc(como('u_marina'), 'matches/exc_1_u_marina'), conclusao()));
    await assertSucceeds(updateDoc(doc(como('u_roberto'), 'matches/exc_1_u_marina'), conclusao()));
  });

  it('qualquer participante pode cancelar', async () => {
    await assertSucceeds(updateDoc(doc(como('u_marina'), 'matches/exc_1_u_marina'), { status: 'cancelado', atualizadoEm: serverTimestamp() }));
  });

  it('participante não altera campos protegidos do match', async () => {
    await assertFails(updateDoc(doc(como('u_marina'), 'matches/exc_1_u_marina'), { ofertanteId: 'u_marina' }));
    await assertFails(updateDoc(doc(como('u_marina'), 'matches/exc_1_u_marina'), { criterios: { localizacao: false, categoria: false, distanciaKm: 99 } }));
  });

  it('ninguém apaga um match', async () => {
    await assertFails(deleteDoc(doc(como('u_roberto'), 'matches/exc_1_u_marina')));
  });
});

describe('mensagens', () => {
  const caminho = 'matches/exc_1_u_marina/mensagens';

  it('participante envia mensagem', async () => {
    await assertSucceeds(setDoc(doc(collection(como('u_marina'), caminho)), mensagemNova('u_marina')));
  });

  it('quem não participa não envia nem lê mensagens', async () => {
    await assertFails(setDoc(doc(collection(como('u_estranho'), caminho)), mensagemNova('u_estranho')));
    await env.withSecurityRulesDisabled(async (contexto) => {
      await setDoc(doc(contexto.firestore(), `${caminho}/m1`), { autorId: 'u_marina', texto: 'Oi', criadoEm: Timestamp.now() });
    });
    await assertFails(getDoc(doc(como('u_estranho'), `${caminho}/m1`)));
    await assertSucceeds(getDoc(doc(como('u_roberto'), `${caminho}/m1`)));
  });

  it('não é possível enviar mensagem em nome de outra pessoa', async () => {
    await assertFails(setDoc(doc(collection(como('u_marina'), caminho)), mensagemNova('u_roberto')));
  });

  it('mensagem vazia ou longa demais é recusada', async () => {
    await assertFails(setDoc(doc(collection(como('u_marina'), caminho)), mensagemNova('u_marina', { texto: '' })));
    await assertFails(setDoc(doc(collection(como('u_marina'), caminho)), mensagemNova('u_marina', { texto: 'a'.repeat(1001) })));
  });

  it('mensagem enviada não pode ser editada nem apagada', async () => {
    await env.withSecurityRulesDisabled(async (contexto) => {
      await setDoc(doc(contexto.firestore(), `${caminho}/m1`), { autorId: 'u_marina', texto: 'Oi', criadoEm: Timestamp.now() });
    });
    await assertFails(updateDoc(doc(como('u_marina'), `${caminho}/m1`), { texto: 'Editada' }));
    await assertFails(deleteDoc(doc(como('u_marina'), `${caminho}/m1`)));
  });
});

describe('caminhos não previstos', () => {
  it('coleções futuras e desconhecidas ficam bloqueadas', async () => {
    await assertFails(setDoc(doc(como('u_roberto'), 'avaliacoes/a1'), { nota: 5 }));
    await assertFails(getDoc(doc(como('u_roberto'), 'qualquer_colecao/x')));
  });
});
