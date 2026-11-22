/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { ObjectId } from 'mongodb';
import { ConversaResumo, Match, Mensagem, MensagemPublica } from '../types/conversa';

// confere se o usuario e um dos dois participantes do match
export function participa(match: Match, usuarioId: ObjectId): boolean {
  return match.participantes.some((id) => id.equals(usuarioId));
}

// monta o item da lista de conversas do ponto de vista de quem esta logado
export function resumirConversa(match: Match, usuarioId: ObjectId): ConversaResumo {
  // o "outro" da conversa e quem nao e o usuario logado
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

// converte a mensagem do banco no formato da API; "minha" diz de que lado o balao aparece
export function mensagemPublica(mensagem: Mensagem, usuarioId: ObjectId): MensagemPublica {
  return {
    id: (mensagem._id as ObjectId).toHexString(),
    texto: mensagem.texto,
    minha: mensagem.autorId.equals(usuarioId),
    criadoEm: mensagem.criadoEm,
  };
}
