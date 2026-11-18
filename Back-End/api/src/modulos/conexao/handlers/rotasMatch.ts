// Autor: Rafaela Jacobsen Braga - RA: 25004280
import type { RequestHandler, Response } from 'express';
import { ObjectId } from 'mongodb';
import { ErroApp } from '../../../shared/erros';
import { criarMatch, consultarMatch } from '../services/gerenciarMatch';
import { objectIdObrigatorio, validarCriacaoMatch } from '../types/validarConexao';

// Deve receber a identidade APENAS de um middleware que verificou a sessão/token.
// Nunca confiar em interessadoId informado no corpo da requisição ou em um header simples.
export function usuarioAutenticado(res: Response): ObjectId {
  const id = res.locals.usuarioId as unknown;
  if (typeof id !== 'string' || !/^[a-f0-9]{24}$/i.test(id)) {
    throw new ErroApp(401, 'Autenticação necessária para acessar conexões.');
  }
  return new ObjectId(id);
}

export const criarConexao: RequestHandler = async (req, res, next) => {
  try {
    const usuarioId = usuarioAutenticado(res);
    const entrada = validarCriacaoMatch(req.body);
    const conexao = await criarMatch(entrada, usuarioId);
    res.status(201).json({ conexao });
  } catch (erro) {
    next(erro);
  }
};

export const obterConexao: RequestHandler = async (req, res, next) => {
  try {
    const usuarioId = usuarioAutenticado(res);
    const parametro = req.params.matchId;
    const matchId = objectIdObrigatorio(parametro, 'matchId');
    const conexao = await consultarMatch(matchId, usuarioId);
    res.json({ conexao });
  } catch (erro) {
    next(erro);
  }
};
