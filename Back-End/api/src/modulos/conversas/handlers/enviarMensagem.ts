/*
 * Autores:
 * Henrique Leite de Camargo - RA: 25005997
 * Rafaela Jacobsen Braga - RA: 25004280
 * Data original: 18/11/2026
 */

import { Request, Response } from 'express';
import { ErroApp } from '../../../shared/erros';
import {
  buscarMatch,
  inserirMensagem,
  registrarUltimaMensagem,
} from '../repositories/conversasRepositorio';
import { mensagemPublica, participa } from './formatadores';
import { lerObjectId, lerTextoMensagem } from './validacoes';
import { usuarioLogado } from '../../../shared/autenticacao';

// envia uma mensagem na conversa; erros: 404 conversa nao existe,
// 403 usuario nao participa, 409 conversa ja encerrada
export async function enviarMensagem(req: Request, res: Response) {
  // Nunca aceitar autorId informado no corpo da mensagem.
  const autorId = usuarioLogado(res);
  const matchId = lerObjectId(req.params.matchId, 'matchId');
  const texto = lerTextoMensagem(req.body?.texto);

  const match = await buscarMatch(matchId);
  if (!match) throw new ErroApp(404, 'Conversa não encontrada');
  if (!participa(match, autorId)) throw new ErroApp(403, 'Você não participa desta conversa');
  if (match.status !== 'conectado') throw new ErroApp(409, 'Esta conversa foi encerrada');

  // a mesma data vale para a mensagem e para o resumo na lista de conversas
  const criadoEm = new Date();
  const salva = await inserirMensagem({ matchId, autorId, texto, criadoEm });
  // atualiza a ultima mensagem do match para a lista de conversas nao precisar consultar as mensagens
  await registrarUltimaMensagem(matchId, { texto, autorId, criadoEm });

  res.status(201).json(mensagemPublica(salva, autorId));
}
