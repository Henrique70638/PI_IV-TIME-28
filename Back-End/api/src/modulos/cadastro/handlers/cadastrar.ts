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

const PERFIS: Perfil[] = ['ofertante', 'interessado', 'ambos'];
const REGEX_EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
const CAMPINAS = { latitude: -22.9056, longitude: -47.0608 };

function texto(valor: unknown): string {
  return typeof valor === 'string' ? valor.trim() : '';
}

export function validarCadastro(corpo: Record<string, unknown>): DadosCadastro {
  const nome = texto(corpo.nome);
  const email = texto(corpo.email).toLowerCase();
  const senha = typeof corpo.senha === 'string' ? corpo.senha : '';
  const perfil = (texto(corpo.perfil) || 'interessado') as Perfil;
  const local = texto(corpo.local);
  const bairro = texto(corpo.bairro) || local;
  const cidade = texto(corpo.cidade) || 'Campinas';
  const latitude = corpo.latitude === undefined ? CAMPINAS.latitude : Number(corpo.latitude);
  const longitude = corpo.longitude === undefined ? CAMPINAS.longitude : Number(corpo.longitude);

  if (!nome || nome.length > 60) throw new ErroApp(400, 'Informe um nome com até 60 caracteres');
  if (!REGEX_EMAIL.test(email)) throw new ErroApp(400, 'E-mail inválido');
  if (senha.length < 8 || senha.length > 72) throw new ErroApp(400, 'A senha deve ter de 8 a 72 caracteres');
  if (!PERFIS.includes(perfil)) throw new ErroApp(400, 'Perfil inválido');
  if (!bairro) throw new ErroApp(400, 'Informe seu bairro ou cidade');
  if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90) throw new ErroApp(400, 'Latitude inválida');
  if (!Number.isFinite(longitude) || longitude < -180 || longitude > 180) throw new ErroApp(400, 'Longitude inválida');

  return { nome, email, senha, perfil, bairro, cidade, latitude, longitude };
}

export async function cadastrar(req: Request, res: Response) {
  const dados = validarCadastro(req.body ?? {});
  const senhaHash = await bcrypt.hash(dados.senha, 10);

  const usuario = await inserirUsuario({
    nome: dados.nome,
    email: dados.email,
    senhaHash,
    perfil: dados.perfil,
    bairro: dados.bairro,
    cidade: dados.cidade,
    localizacao: { type: 'Point', coordinates: [dados.longitude, dados.latitude] },
    criadoEm: new Date(),
  });

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
