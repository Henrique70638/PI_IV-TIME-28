/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { ObjectId } from 'mongodb';

export type Perfil = 'ofertante' | 'interessado' | 'ambos';

export interface PontoGeo {
  type: 'Point';
  coordinates: [number, number];
}

export interface Usuario {
  _id: ObjectId;
  nome: string;
  email: string;
  senhaHash: string;
  perfil: Perfil;
  bairro: string;
  cidade: string;
  localizacao: PontoGeo;
  criadoEm: Date;
}

export interface DadosCadastro {
  nome: string;
  email: string;
  senha: string;
  perfil: Perfil;
  bairro: string;
  cidade: string;
  latitude: number;
  longitude: number;
}

export interface UsuarioPublico {
  id: string;
  nome: string;
  email: string;
  perfil: Perfil;
  bairro: string;
  cidade: string;
}
