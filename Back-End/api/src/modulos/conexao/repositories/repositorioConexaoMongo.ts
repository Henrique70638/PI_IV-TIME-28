// Autor: Rafaela Jacobsen Braga - RA: 25004280
import { ObjectId } from 'mongodb';
import { getBanco } from '../../../shared/banco';
import { ErroApp } from '../../../shared/erros';
import {
  MatchConexao, OfertaConexao, RepositorioConexao, UsuarioConexao,
} from '../types/modelosConexao';

// Uma conexão indisponível não deve ser tratada como sucesso.
function bancoDisponivel() {
  try {
    return getBanco();
  } catch {
    throw new ErroApp(503, 'Banco de dados temporariamente indisponível.');
  }
}

export const repositorioConexaoMongo: RepositorioConexao = {
  buscarUsuario(id: ObjectId) {
    return bancoDisponivel().collection<UsuarioConexao>('usuarios').findOne({ _id: id });
  },
  buscarOferta(id: ObjectId) {
    return bancoDisponivel().collection<OfertaConexao>('excedentes').findOne({ _id: id });
  },
  async buscarDuplicado(excedenteId: ObjectId, interessadoId: ObjectId) {
    const anterior = await bancoDisponivel().collection<MatchConexao>('matches')
      .findOne({ excedenteId, interessadoId }, { projection: { _id: 1 } });
    return anterior !== null;
  },
  async inserirMatch(match: MatchConexao) {
    await bancoDisponivel().collection<MatchConexao>('matches').insertOne(match);
  },
  buscarMatchAutorizado(matchId: ObjectId, usuarioId: ObjectId) {
    return bancoDisponivel().collection<MatchConexao>('matches')
      .findOne({ _id: matchId, participantes: usuarioId });
  },
};
