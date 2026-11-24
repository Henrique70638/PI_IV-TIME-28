/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { ObjectId } from 'mongodb';

// como a pessoa usa o CULT+ (mesmos valores aceitos pelo $jsonSchema do banco)
export type Perfil = 'ofertante' | 'interessado' | 'ambos';

// formato GeoJSON do Mongo: coordinates e [longitude, latitude], nessa ordem
export interface PontoGeo {
  type: 'Point';
  coordinates: [number, number];
}

// documento da colecao usuarios; senhaHash guarda o hash BCrypt,
// a senha em texto nunca vai para o banco
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

// dados do cadastro ja lidos e normalizados, ainda com a senha em texto
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

// o que a API devolve depois do cadastro (sem senha e sem hash)
export interface UsuarioPublico {
  id: string;
  nome: string;
  email: string;
  perfil: Perfil;
  bairro: string;
  cidade: string;
}
