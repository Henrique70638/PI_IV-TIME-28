/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { ObjectId } from 'mongodb';

// situacao da conexao entre ofertante e interessado
export type StatusMatch = 'conectado' | 'concluido' | 'cancelado';

// copia dos dados da oferta no momento do match (cabecalho do chat)
export interface ExcedenteResumo {
  produto: string;
  categoria: string;
  modalidade: string;
  quantidade: number;
  unidade: string;
}

// resumo da ultima mensagem, guardado dentro do match
export interface UltimaMensagem {
  texto: string;
  autorId: ObjectId;
  criadoEm: Date;
}

// documento da colecao matches: a conexao entre uma oferta e um interessado
export interface Match {
  _id: ObjectId;
  excedenteId: ObjectId;
  ofertanteId: ObjectId;
  interessadoId: ObjectId;
  ofertanteNome: string;
  interessadoNome: string;
  // os dois usuarios juntos, para achar "minhas conversas" com um unico indice
  participantes: ObjectId[];
  status: StatusMatch;
  criterios: { localizacao: boolean; categoria: boolean; distanciaKm: number };
  excedenteResumo: ExcedenteResumo;
  ultimaMensagem?: UltimaMensagem;
  criadoEm: Date;
  atualizadoEm: Date;
}

// documento da colecao mensagens
export interface Mensagem {
  _id?: ObjectId;
  matchId: ObjectId;
  autorId: ObjectId;
  texto: string;
  criadoEm: Date;
}

// item da lista de conversas, ja do ponto de vista do usuario logado
export interface ConversaResumo {
  id: string;
  outroNome: string;
  papelDoOutro: 'ofertante' | 'interessado';
  status: StatusMatch;
  excedente: ExcedenteResumo;
  ultimaMensagem: { texto: string; minha: boolean; criadoEm: Date } | null;
  atualizadoEm: Date;
}

// mensagem como o app recebe; "minha" indica se foi enviada por quem esta logado
export interface MensagemPublica {
  id: string;
  texto: string;
  minha: boolean;
  criadoEm: Date;
}
