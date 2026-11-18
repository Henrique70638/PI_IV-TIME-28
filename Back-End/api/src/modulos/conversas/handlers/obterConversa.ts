/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { Request, Response } from 'express';
import { ErroApp } from '../../../shared/erros';
import { buscarMatch, listarMensagensDoMatch } from '../repositories/conversasRepositorio';
import { mensagemPublica, participa, resumirConversa } from './formatadores';
import { lerObjectId } from './validacoes';

export async function obterConversa(req: Request, res: Response) {
  const matchId = lerObjectId(req.params.matchId, 'matchId');
  const usuarioId = lerObjectId(req.query.usuarioId, 'usuarioId');

  const match = await buscarMatch(matchId);
  if (!match) throw new ErroApp(404, 'Conversa não encontrada');
  if (!participa(match, usuarioId)) throw new ErroApp(403, 'Você não participa desta conversa');

  const mensagens = await listarMensagensDoMatch(matchId);
  res.json({
    conversa: { ...resumirConversa(match, usuarioId), distanciaKm: match.criterios.distanciaKm },
    mensagens: mensagens.map((mensagem) => mensagemPublica(mensagem, usuarioId)),
  });
}
