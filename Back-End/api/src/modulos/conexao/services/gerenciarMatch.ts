// Autor: Rafaela Jacobsen Braga - RA: 25004280
import { MongoServerError, ObjectId } from 'mongodb';
import { ErroApp } from '../../../shared/erros';
import {
  CriarMatchEntrada, ConfirmacaoMatch, MatchConexao, OfertaConexao,
  RepositorioConexao, UsuarioConexao,
} from '../types/modelosConexao';
import { repositorioConexaoMongo } from '../repositories/repositorioConexaoMongo';

// As coordenadas são usadas apenas no servidor; nunca são retornadas ao Flutter.
export function distanciaEmKm(a: number[], b: number[]): number {
  if (a.length !== 2 || b.length !== 2 || [...a, ...b].some((n) => !Number.isFinite(n))) {
    throw new ErroApp(422, 'Coordenadas indisponíveis para calcular a distância.');
  }
  const rad = (graus: number) => graus * Math.PI / 180;
  const dLat = rad(b[1] - a[1]);
  const dLon = rad(b[0] - a[0]);
  const h = Math.sin(dLat / 2) ** 2
    + Math.cos(rad(a[1])) * Math.cos(rad(b[1])) * Math.sin(dLon / 2) ** 2;
  return 2 * 6371.0088 * Math.asin(Math.min(1, Math.sqrt(h)));
}

function respostaConfirmacao(
  match: MatchConexao, oferta: OfertaConexao, perfil: UsuarioConexao | null,
): ConfirmacaoMatch {
  return {
    id: match._id.toHexString(),
    status: match.status,
    nomeOfertante: match.ofertanteNome,
    nomeProduto: match.excedenteResumo.produto,
    quantidade: match.excedenteResumo.quantidade,
    unidade: match.excedenteResumo.unidade,
    modalidade: match.excedenteResumo.modalidade,
    localizacao: oferta.localizacao.bairro,
    cidade: oferta.localizacao.cidade,
    distanciaKm: match.criterios.distanciaKm,
    ...(typeof perfil?.avaliacaoMedia === 'number' && { avaliacaoOfertante: perfil.avaliacaoMedia }),
    ...(typeof perfil?.totalAvaliacoes === 'number' && { totalAvaliacoes: perfil.totalAvaliacoes }),
  };
}

export async function criarMatch(
  entrada: CriarMatchEntrada, interessadoId: ObjectId,
  repo: RepositorioConexao = repositorioConexaoMongo,
): Promise<ConfirmacaoMatch> {
  const [interessado, oferta] = await Promise.all([
    repo.buscarUsuario(interessadoId), repo.buscarOferta(entrada.excedenteId),
  ]);
  if (!interessado) throw new ErroApp(404, 'Usuário não encontrado.');
  if (interessado.perfil === 'ofertante') {
    throw new ErroApp(403, 'Este perfil não está habilitado para solicitar produtos.');
  }
  if (!oferta) throw new ErroApp(404, 'Excedente não encontrado.');
  if (oferta.status !== 'disponivel') throw new ErroApp(409, 'Este excedente não está disponível.');
  if (oferta.ofertante._id.equals(interessadoId)) {
    throw new ErroApp(403, 'Você não pode criar conexão com sua própria oferta.');
  }
  if (entrada.categoria && oferta.categoria !== entrada.categoria) {
    throw new ErroApp(422, 'O excedente não corresponde à categoria selecionada.');
  }

  const distancia = distanciaEmKm(
    interessado.localizacao.coordinates, oferta.localizacao.ponto.coordinates,
  );
  if (distancia > entrada.raioKm) {
    throw new ErroApp(422, 'O excedente está fora do raio de busca.');
  }
  if (await repo.buscarDuplicado(oferta._id, interessadoId)) {
    throw new ErroApp(409, 'Você já possui uma conexão para este excedente.');
  }

  const data = new Date();
  const match: MatchConexao = {
    _id: new ObjectId(),
    excedenteId: oferta._id,
    ofertanteId: oferta.ofertante._id,
    interessadoId,
    ofertanteNome: oferta.ofertante.nome,
    interessadoNome: interessado.nome,
    participantes: [oferta.ofertante._id, interessadoId],
    status: 'conectado',
    criterios: {
      localizacao: true,
      categoria: true,
      distanciaKm: Math.round(distancia * 10) / 10,
    },
    excedenteResumo: {
      produto: oferta.produto,
      categoria: oferta.categoria,
      modalidade: oferta.modalidade,
      quantidade: oferta.quantidade,
      unidade: oferta.unidade,
    },
    criadoEm: data,
    atualizadoEm: data,
  };

  try {
    await repo.inserirMatch(match);
  } catch (erro) {
    // O índice unique do banco evita duplicação mesmo em requisições simultâneas.
    if (erro instanceof MongoServerError && erro.code === 11000) {
      throw new ErroApp(409, 'Você já possui uma conexão para este excedente.');
    }
    throw erro;
  }
  const ofertante = await repo.buscarUsuario(oferta.ofertante._id);
  return respostaConfirmacao(match, oferta, ofertante);
}

export async function consultarMatch(
  matchId: ObjectId, usuarioId: ObjectId,
  repo: RepositorioConexao = repositorioConexaoMongo,
): Promise<ConfirmacaoMatch> {
  const match = await repo.buscarMatchAutorizado(matchId, usuarioId);
  // Não revelar se a conexão existe quando o usuário não participa dela.
  if (!match) throw new ErroApp(404, 'Conexão não encontrada.');
  const [oferta, ofertante] = await Promise.all([
    repo.buscarOferta(match.excedenteId), repo.buscarUsuario(match.ofertanteId),
  ]);
  if (!oferta) throw new ErroApp(404, 'Excedente associado não encontrado.');
  return respostaConfirmacao(match, oferta, ofertante);
}
