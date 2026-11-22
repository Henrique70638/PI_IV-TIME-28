// Autor: Rafaela Jacobsen Braga - RA: 25004280
import { Request, Response, NextFunction } from 'express';
import { ErroApp } from '../../../shared/erros';
import bcrypt from 'bcryptjs';
import { MongoServerError } from 'mongodb';
import { usuarioLogado } from '../../../shared/autenticacao';
import { atualizarPerfilNoBanco, buscarUsuarioPorId } from '../repositories/perfilRepository';
import { buscarUsuarioPorEmail } from '../../login/repositories/usuarioLoginRepository';

const perfis = ['ofertante', 'interessado', 'ambos'];

/// Apenas campos públicos e seguros podem ser alterados nesta rota.
export function validarAtualizacaoPerfil(entrada: unknown): Record<string, unknown> {
  if (!entrada || typeof entrada !== 'object' || Array.isArray(entrada)) {
    throw new ErroApp(400, 'Informe os dados do perfil.');
  }
  const dados = entrada as Record<string, unknown>;
  const permitidos = ['nome', 'email', 'senhaAtual', 'perfil', 'bairro', 'cidade', 'latitude', 'longitude'];
  if (Object.keys(dados).some((campo) => !permitidos.includes(campo))) {
    throw new ErroApp(400, 'Campo não permitido no perfil.');
  }
  const atualizacoes: Record<string, unknown> = {};
  if (dados.nome !== undefined) {
    if (typeof dados.nome !== 'string' || !dados.nome.trim() || dados.nome.trim().length > 60) {
      throw new ErroApp(400, 'Informe um nome com até 60 caracteres.');
    }
    atualizacoes.nome = dados.nome.trim();
  }
  if (dados.email !== undefined) {
    if (typeof dados.email !== 'string') throw new ErroApp(400, 'E-mail inválido.');
    const email = dados.email.trim().toLowerCase();
    if (email.length > 254 || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
      throw new ErroApp(400, 'E-mail inválido.');
    }
    if (typeof dados.senhaAtual !== 'string' || dados.senhaAtual.length === 0) {
      throw new ErroApp(400, 'Informe a senha atual para trocar o e-mail.');
    }
    atualizacoes.email = email;
  } else if (dados.senhaAtual !== undefined) {
    throw new ErroApp(400, 'A senha atual só é necessária ao alterar o e-mail.');
  }
  if (dados.perfil !== undefined) {
    if (typeof dados.perfil !== 'string' || !perfis.includes(dados.perfil)) {
      throw new ErroApp(400, 'Tipo de usuário inválido.');
    }
    atualizacoes.perfil = dados.perfil;
  }
  // Bairro, cidade e ponto geográfico são alterados como uma única operação.
  const local = ['bairro', 'cidade', 'latitude', 'longitude'];
  if (local.some((campo) => dados[campo] !== undefined)) {
    if (local.some((campo) => dados[campo] === undefined)) {
      throw new ErroApp(400, 'Informe bairro, cidade, latitude e longitude juntos.');
    }
    for (const campo of ['bairro', 'cidade']) {
      const valor = dados[campo];
      if (typeof valor !== 'string' || !valor.trim() || valor.trim().length > 80) {
        throw new ErroApp(400, `${campo} inválido.`);
      }
      atualizacoes[campo] = valor.trim();
    }
    const latitude = dados.latitude;
    const longitude = dados.longitude;
    if (typeof latitude !== 'number' || !Number.isFinite(latitude) || latitude < -90 || latitude > 90 ||
        typeof longitude !== 'number' || !Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
      throw new ErroApp(400, 'Coordenadas inválidas.');
    }
    atualizacoes.localizacao = { type: 'Point', coordinates: [longitude, latitude] };
  }
  if (Object.keys(atualizacoes).length === 0) {
    throw new ErroApp(400, 'Nenhuma alteração informada.');
  }
  return atualizacoes;
}

export async function atualizarMeuPerfil(req: Request, res: Response, next: NextFunction) {
  try {
    const id = usuarioLogado(res);
    const campos = validarAtualizacaoPerfil(req.body);
    if (campos.email !== undefined) {
      const atual = await buscarUsuarioPorId(id);
      if (!atual) throw new ErroApp(404, 'Usuário não encontrado.');
      if (!(await bcrypt.compare(req.body.senhaAtual, atual.senhaHash))) {
        throw new ErroApp(401, 'Senha atual incorreta.');
      }
      // Checa e-mail já utilizado; índice único no MongoDB protege concorrência.
      const existe = await buscarUsuarioPorEmail(campos.email as string);
      if (existe && !existe._id.equals(id)) {
        throw new ErroApp(409, 'Este e-mail já está cadastrado.');
      }
    }
    let usuario;
    try {
      usuario = await atualizarPerfilNoBanco(id, campos);
    } catch (erro) {
      if (erro instanceof MongoServerError && erro.code === 11000) {
        throw new ErroApp(409, 'Este e-mail já está cadastrado.');
      }
      throw erro;
    }
    if (!usuario) throw new ErroApp(404, 'Usuário não encontrado.');
    res.json({
      id: usuario._id.toHexString(),
      nome: usuario.nome,
      email: usuario.email,
      perfil: usuario.perfil,
      bairro: usuario.bairro,
      cidade: usuario.cidade,
    });
  } catch (erro) {
    next(erro);
  }
}
