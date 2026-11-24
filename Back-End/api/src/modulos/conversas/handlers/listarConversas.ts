/*
 * Autores:
 * Henrique Leite de Camargo - RA: 25005997
 * Rafaela Jacobsen Braga - RA: 25004280
 * Data original: 18/11/2026
 */

import { Request, Response } from 'express';
import { listarMatchesDoUsuario } from '../repositories/conversasRepositorio';
import { resumirConversa } from './formatadores';
import { usuarioLogado } from '../../../shared/autenticacao';

// lista as conversas do usuario, da mais recente para a mais antiga
export async function listarConversas(_req: Request, res: Response) {
  // A identidade vem exclusivamente do JWT validado pelo middleware.
  const usuarioId = usuarioLogado(res);
  const matches = await listarMatchesDoUsuario(usuarioId);
  const conversas = matches.map((match) => resumirConversa(match, usuarioId));
  res.json({ total: conversas.length, conversas });
}
