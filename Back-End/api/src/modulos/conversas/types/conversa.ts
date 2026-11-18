/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { ObjectId } from 'mongodb';

export type StatusMatch = 'conectado' | 'concluido' | 'cancelado';

export interface ExcedenteResumo {
  produto: string;
  categoria: string;
  modalidade: string;
  quantidade: number;
  unidade: string;
}

export interface UltimaMensagem {
  texto: string;
  autorId: ObjectId;
  criadoEm: Date;
}

export interface Match {
  _id: ObjectId;
  excedenteId: ObjectId;
  ofertanteId: ObjectId;
  interessadoId: ObjectId;
  ofertanteNome: string;
  interessadoNome: string;
  participantes: ObjectId[];
  status: StatusMatch;
  criterios: { localizacao: boolean; categoria: boolean; distanciaKm: number };
  excedenteResumo: ExcedenteResumo;
  ultimaMensagem?: UltimaMensagem;
  criadoEm: Date;
  atualizadoEm: Date;
}

export interface Mensagem {
  _id?: ObjectId;
  matchId: ObjectId;
  autorId: ObjectId;
  texto: string;
  criadoEm: Date;
}

export interface ConversaResumo {
  id: string;
  outroNome: string;
  papelDoOutro: 'ofertante' | 'interessado';
  status: StatusMatch;
  excedente: ExcedenteResumo;
  ultimaMensagem: { texto: string; minha: boolean; criadoEm: Date } | null;
  atualizadoEm: Date;
}

export interface MensagemPublica {
  id: string;
  texto: string;
  minha: boolean;
  criadoEm: Date;
}
