/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { MongoServerError } from 'mongodb';
import { getBanco } from '../../../shared/banco';
import { ErroApp } from '../../../shared/erros';
import { Usuario } from '../types/usuario';

function colecao() {
  return getBanco().collection<Usuario>('usuarios');
}

export async function inserirUsuario(usuario: Omit<Usuario, '_id'>): Promise<Usuario> {
  try {
    const { insertedId } = await colecao().insertOne(usuario as Usuario);
    return { ...usuario, _id: insertedId };
  } catch (erro) {
    if (erro instanceof MongoServerError && erro.code === 11000) {
      throw new ErroApp(409, 'Este e-mail já está cadastrado');
    }
    throw erro;
  }
}

export async function removerUsuario(email: string): Promise<void> {
  await colecao().deleteOne({ email });
}
