/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { ErroApp } from '../../../shared/erros';
import { inserirUsuario } from '../repositories/usuariosRepositorio';
import { DadosCadastro, Perfil, UsuarioPublico } from '../types/usuario';
import { verificarNoServidor } from '../../../shared/servidorVerificacao';

// perfis aceitos, os mesmos do $jsonSchema da colecao usuarios
const PERFIS: Perfil[] = ['ofertante', 'interessado', 'ambos'];
// formato simples: algo@dominio.ext, sem espacos
const REGEX_EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
// localizacao usada quando o app nao envia latitude e longitude
const CAMPINAS = { latitude: -22.9056, longitude: -47.0608 };

// devolve o texto sem espacos nas pontas, ou vazio se nao for string
function texto(valor: unknown): string {
  return typeof valor === 'string' ? valor.trim() : '';
}

// le o corpo da requisicao, aplica valores padrao e confere as regras;
// lanca erro 400 com o motivo na primeira regra que falhar
export function validarCadastro(corpo: Record<string, unknown>): DadosCadastro {
  const nome = texto(corpo.nome);
  // e-mail em minusculas para o indice unico nao aceitar o mesmo e-mail com outra caixa
  const email = texto(corpo.email).toLowerCase();
  const senha = typeof corpo.senha === 'string' ? corpo.senha : '';
  const perfil = (texto(corpo.perfil) || 'interessado') as Perfil;
  const local = texto(corpo.local);
  // se o bairro nao vier, usa o campo "local" como bairro
  const bairro = texto(corpo.bairro) || local;
  const cidade = texto(corpo.cidade) || 'Campinas';
  const latitude = corpo.latitude === undefined ? CAMPINAS.latitude : Number(corpo.latitude);
  const longitude = corpo.longitude === undefined ? CAMPINAS.longitude : Number(corpo.longitude);

  if (!nome || nome.length > 60) throw new ErroApp(400, 'Informe um nome com até 60 caracteres');
  if (!REGEX_EMAIL.test(email)) throw new ErroApp(400, 'E-mail inválido');
  // 72 e o limite do BCrypt: o que passa disso e ignorado no hash
  if (senha.length < 8 || senha.length > 72) throw new ErroApp(400, 'A senha deve ter de 8 a 72 caracteres');
  if (!PERFIS.includes(perfil)) throw new ErroApp(400, 'Perfil inválido');
  if (!bairro) throw new ErroApp(400, 'Informe seu bairro ou cidade');
  if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90) throw new ErroApp(400, 'Latitude inválida');
  if (!Number.isFinite(longitude) || longitude < -180 || longitude > 180) throw new ErroApp(400, 'Longitude inválida');

  return { nome, email, senha, perfil, bairro, cidade, latitude, longitude };
}

// POST /api/cadastro: valida, confere no servidor java, guarda o hash da senha
// e devolve o usuario criado (201)
export async function cadastrar(req: Request, res: Response) {
  const dados = validarCadastro(req.body ?? {});
  //Laura: confere os dados no servidor java de verificacao antes de salvar
  await verificarNoServidor(dados);
  // 10 rodadas de salt: equilibrio entre seguranca e tempo de resposta
  const senhaHash = await bcrypt.hash(dados.senha, 10);

  const usuario = await inserirUsuario({
    nome: dados.nome,
    email: dados.email,
    senhaHash,
    perfil: dados.perfil,
    bairro: dados.bairro,
    cidade: dados.cidade,
    // GeoJSON: [longitude, latitude]
    localizacao: { type: 'Point', coordinates: [dados.longitude, dados.latitude] },
    criadoEm: new Date(),
  });

  // monta a resposta sem senhaHash
  const resposta: UsuarioPublico = {
    id: usuario._id.toHexString(),
    nome: usuario.nome,
    email: usuario.email,
    perfil: usuario.perfil,
    bairro: usuario.bairro,
    cidade: usuario.cidade,
  };
  res.status(201).json(resposta);
}
