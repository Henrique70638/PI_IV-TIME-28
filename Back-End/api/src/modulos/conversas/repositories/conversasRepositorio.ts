/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { ObjectId } from 'mongodb';
import { getBanco } from '../../../shared/banco';
import { Match, Mensagem, UltimaMensagem } from '../types/conversa';

function matches() {
  return getBanco().collection<Match>('matches');
}

function mensagens() {
  return getBanco().collection<Mensagem>('mensagens');
}

export async function listarMatchesDoUsuario(usuarioId: ObjectId): Promise<Match[]> {
  return matches().find({ participantes: usuarioId }).sort({ atualizadoEm: -1 }).toArray();
}

export async function buscarMatch(matchId: ObjectId): Promise<Match | null> {
  return matches().findOne({ _id: matchId });
}

export async function listarMensagensDoMatch(matchId: ObjectId, limite = 200): Promise<Mensagem[]> {
  return mensagens().find({ matchId }).sort({ criadoEm: 1 }).limit(limite).toArray();
}

export async function inserirMensagem(mensagem: Mensagem): Promise<Mensagem> {
  const { insertedId } = await mensagens().insertOne(mensagem);
  return { ...mensagem, _id: insertedId };
}

export async function registrarUltimaMensagem(matchId: ObjectId, ultima: UltimaMensagem): Promise<void> {
  await matches().updateOne(
    { _id: matchId },
    { $set: { ultimaMensagem: ultima, atualizadoEm: ultima.criadoEm } },
  );
}
