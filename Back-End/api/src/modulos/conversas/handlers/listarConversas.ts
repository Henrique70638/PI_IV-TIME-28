/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { Request, Response } from 'express';
import { listarMatchesDoUsuario } from '../repositories/conversasRepositorio';
import { resumirConversa } from './formatadores';
import { lerObjectId } from './validacoes';

export async function listarConversas(req: Request, res: Response) {
  const usuarioId = lerObjectId(req.query.usuarioId, 'usuarioId');
  const matches = await listarMatchesDoUsuario(usuarioId);
  const conversas = matches.map((match) => resumirConversa(match, usuarioId));
  res.json({ total: conversas.length, conversas });
}
