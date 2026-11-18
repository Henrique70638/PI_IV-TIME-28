// Autor: Rafaela Jacobsen Braga - RA: 25004280
import test from 'node:test';
import assert from 'node:assert/strict';
import type { Response } from 'express';
import { ObjectId, MongoServerError } from 'mongodb';
import { ErroApp } from '../src/shared/erros';
import { usuarioAutenticado } from '../src/modulos/conexao/handlers/rotasMatch';
import { validarCriacaoMatch } from '../src/modulos/conexao/types/validarConexao';
import {
  MatchConexao, OfertaConexao, RepositorioConexao, UsuarioConexao,
} from '../src/modulos/conexao/types/modelosConexao';
import { criarMatch, consultarMatch, distanciaEmKm } from '../src/modulos/conexao/services/gerenciarMatch';

const idOferta = new ObjectId('b20000000000000000000001');
const idOfertante = new ObjectId('a10000000000000000000001');
const idInteressado = new ObjectId('a10000000000000000000002');
const idEstranho = new ObjectId('a10000000000000000000004');

const ofertante: UsuarioConexao = {
  _id: idOfertante, nome: 'Roberto C.', perfil: 'ofertante',
  localizacao: { type: 'Point', coordinates: [-47.067, -22.919] },
  avaliacaoMedia: 4.8, totalAvaliacoes: 12,
};
const interessado: UsuarioConexao = {
  _id: idInteressado, nome: 'Marina S.', perfil: 'interessado',
  localizacao: { type: 'Point', coordinates: [-47.065, -22.91] },
};
const oferta: OfertaConexao = {
  _id: idOferta,
  ofertante: { _id: idOfertante, nome: 'Roberto C.' },
  produto: 'Manga Tommy', categoria: 'frutas', modalidade: 'doacao',
  quantidade: 5, unidade: 'kg', status: 'disponivel',
  localizacao: {
    bairro: 'Jardim das Flores', cidade: 'Campinas',
    ponto: { type: 'Point', coordinates: [-47.067, -22.919] },
  },
};
const dados = validarCriacaoMatch({ excedenteId: idOferta.toHexString() });

function repositorioFalso(alteracoes: {
  oferta?: OfertaConexao | null;
  interessado?: UsuarioConexao | null;
  duplicado?: boolean;
  erroInsercao?: Error;
} = {}) {
  const gravados: MatchConexao[] = [];
  const ofertaAtual = alteracoes.oferta === undefined ? oferta : alteracoes.oferta;
  const interessadoAtual = alteracoes.interessado === undefined ? interessado : alteracoes.interessado;
  const repo: RepositorioConexao = {
    async buscarUsuario(id) {
      if (id.equals(idOfertante)) return ofertante;
      if (id.equals(idInteressado)) return interessadoAtual;
      return null;
    },
    async buscarOferta(id) { return id.equals(idOferta) ? ofertaAtual : null; },
    async buscarDuplicado() { return alteracoes.duplicado ?? false; },
    async inserirMatch(match) {
      if (alteracoes.erroInsercao) throw alteracoes.erroInsercao;
      gravados.push(match);
    },
    async buscarMatchAutorizado(id, usuario) {
      return gravados.find((m) => m._id.equals(id) && m.participantes.some((p) => p.equals(usuario))) ?? null;
    },
  };
  return { repo, gravados };
}

async function erroDeStatus(acao: () => Promise<unknown>, status: number) {
  await assert.rejects(acao, (erro: unknown) => erro instanceof ErroApp && erro.status === status);
}

test('rejeita identificador inválido e campos que tentam forjar outro usuário', () => {
  assert.throws(() => validarCriacaoMatch({ excedenteId: 'abc' }), /excedenteId/);
  assert.throws(() => validarCriacaoMatch({ excedenteId: idOferta.toHexString(), interessadoId: idEstranho.toHexString() }), /campos não permitidos/);
});

test('valida o raio e normaliza plantas em mudas', () => {
  assert.equal(validarCriacaoMatch({ excedenteId: idOferta.toHexString() }).raioKm, 5);
  assert.equal(validarCriacaoMatch({ excedenteId: idOferta.toHexString(), categoria: 'plantas' }).categoria, 'mudas');
  assert.throws(() => validarCriacaoMatch({ excedenteId: idOferta.toHexString(), raioKm: 0 }), /raioKm/);
  assert.throws(() => validarCriacaoMatch({ excedenteId: idOferta.toHexString(), categoria: 'inexistente' }), /Categoria/);
});

test('calcula distância em km com coordenadas [longitude, latitude]', () => {
  const dist = distanciaEmKm(interessado.localizacao.coordinates, oferta.localizacao.ponto.coordinates);
  assert.ok(dist > 0.9 && dist < 1.1);
  assert.throws(() => distanciaEmKm([NaN, 0], [1, 2]), /Coordenadas/);
});

test('cria um match com o modelo do banco e retorna apenas dados públicos', async () => {
  const { repo, gravados } = repositorioFalso();
  const resultado = await criarMatch(dados, idInteressado, repo);
  assert.equal(gravados.length, 1);
  assert.equal(gravados[0].status, 'conectado');
  assert.deepEqual(gravados[0].participantes.map((id) => id.toHexString()), [idOfertante.toHexString(), idInteressado.toHexString()]);
  assert.equal(gravados[0].criterios.localizacao, true);
  assert.equal(gravados[0].excedenteResumo.produto, 'Manga Tommy');
  assert.equal(resultado.nomeOfertante, 'Roberto C.');
  assert.equal(resultado.avaliacaoOfertante, 4.8);
  assert.equal(resultado.totalAvaliacoes, 12);
  assert.equal(resultado.localizacao, 'Jardim das Flores');
  assert.ok(!JSON.stringify(resultado).includes('coordinates'));
  assert.ok(!JSON.stringify(resultado).includes('senhaHash'));
});

test('impede duplicidade de conexão', async () => {
  await erroDeStatus(() => criarMatch(dados, idInteressado, repositorioFalso({ duplicado: true }).repo), 409);
});

test('trata índice único do MongoDB em requisições concorrentes', async () => {
  const erro = new MongoServerError({ code: 11000, errmsg: 'E11000 duplicate key' });
  await erroDeStatus(() => criarMatch(dados, idInteressado, repositorioFalso({ erroInsercao: erro }).repo), 409);
});

test('não permite conectar com a própria oferta', async () => {
  const proprio = { ...interessado, _id: idInteressado, perfil: 'ambos' as const };
  const propriaOferta = { ...oferta, ofertante: { _id: idInteressado, nome: proprio.nome } };
  await erroDeStatus(() => criarMatch(dados, idInteressado, repositorioFalso({ oferta: propriaOferta, interessado: proprio }).repo), 403);
});

test('não permite perfis apenas ofertantes solicitarem produtos', async () => {
  const usuario = { ...interessado, perfil: 'ofertante' as const };
  await erroDeStatus(() => criarMatch(dados, idInteressado, repositorioFalso({ interessado: usuario }).repo), 403);
});

test('recusa oferta indisponível e não cadastrada', async () => {
  await erroDeStatus(() => criarMatch(dados, idInteressado, repositorioFalso({ oferta: { ...oferta, status: 'concluido' } }).repo), 409);
  await erroDeStatus(() => criarMatch(dados, idInteressado, repositorioFalso({ oferta: null }).repo), 404);
});

test('recusa ofertas fora do raio e categoria diferente', async () => {
  await erroDeStatus(() => criarMatch({ ...dados, raioKm: 0.1 }, idInteressado, repositorioFalso().repo), 422);
  await erroDeStatus(() => criarMatch({ ...dados, categoria: 'verduras' }, idInteressado, repositorioFalso().repo), 422);
});

test('apenas participantes podem consultar uma conexão', async () => {
  const { repo } = repositorioFalso();
  const resultado = await criarMatch(dados, idInteressado, repo);
  const id = new ObjectId(resultado.id);
  const consulta = await consultarMatch(id, idInteressado, repo);
  assert.equal(consulta.nomeProduto, 'Manga Tommy');
  await erroDeStatus(() => consultarMatch(id, idEstranho, repo), 404);
});

test('rotas não confiam em ids do cliente enquanto o middleware de autenticação não existir', () => {
  assert.throws(() => usuarioAutenticado({ locals: {} } as Response), (erro: unknown) => erro instanceof ErroApp && erro.status === 401);
  assert.equal(usuarioAutenticado({ locals: { usuarioId: idInteressado.toHexString() } } as Response).toHexString(), idInteressado.toHexString());
});
