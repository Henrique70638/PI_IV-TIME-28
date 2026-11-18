/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { ObjectId } from 'mongodb';
import { ConversaResumo, Match, Mensagem, MensagemPublica } from '../types/conversa';

export function participa(match: Match, usuarioId: ObjectId): boolean {
  return match.participantes.some((id) => id.equals(usuarioId));
}

export function resumirConversa(match: Match, usuarioId: ObjectId): ConversaResumo {
  const souOfertante = match.ofertanteId.equals(usuarioId);
  return {
    id: match._id.toHexString(),
    outroNome: souOfertante ? match.interessadoNome : match.ofertanteNome,
    papelDoOutro: souOfertante ? 'interessado' : 'ofertante',
    status: match.status,
    excedente: match.excedenteResumo,
    ultimaMensagem: match.ultimaMensagem
      ? {
          texto: match.ultimaMensagem.texto,
          minha: match.ultimaMensagem.autorId.equals(usuarioId),
          criadoEm: match.ultimaMensagem.criadoEm,
        }
      : null,
    atualizadoEm: match.atualizadoEm,
  };
}

export function mensagemPublica(mensagem: Mensagem, usuarioId: ObjectId): MensagemPublica {
  return {
    id: (mensagem._id as ObjectId).toHexString(),
    texto: mensagem.texto,
    minha: mensagem.autorId.equals(usuarioId),
    criadoEm: mensagem.criadoEm,
  };
}
