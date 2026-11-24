/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { ObjectId } from 'mongodb';
import { ErroApp } from '../../../shared/erros';

// mesmo limite do $jsonSchema da colecao mensagens
export const TAMANHO_MAXIMO_MENSAGEM = 1000;

// confere se o id tem 24 caracteres hexadecimais antes de virar ObjectId,
// para um id mal formado dar erro 400 e nao quebrar a consulta
export function lerObjectId(valor: unknown, campo: string): ObjectId {
  if (typeof valor !== 'string' || !/^[0-9a-fA-F]{24}$/.test(valor)) {
    throw new ErroApp(400, `${campo} inválido`);
  }
  return new ObjectId(valor);
}

// tira os espacos das pontas e recusa mensagem vazia ou acima do limite
export function lerTextoMensagem(valor: unknown): string {
  const texto = typeof valor === 'string' ? valor.trim() : '';
  if (!texto) throw new ErroApp(400, 'Digite uma mensagem');
  if (texto.length > TAMANHO_MAXIMO_MENSAGEM) {
    throw new ErroApp(400, `A mensagem pode ter no máximo ${TAMANHO_MAXIMO_MENSAGEM} caracteres`);
  }
  return texto;
}
