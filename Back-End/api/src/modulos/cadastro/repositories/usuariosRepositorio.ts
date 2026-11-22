/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { MongoServerError } from 'mongodb';
import { getBanco } from '../../../shared/banco';
import { ErroApp } from '../../../shared/erros';
import { Usuario } from '../types/usuario';

// atalho para a colecao usuarios do banco
function colecao() {
  return getBanco().collection<Usuario>('usuarios');
}

// grava o usuario novo; se o e-mail ja existir o indice unico do Mongo
// dispara o erro 11000, que vira um 409 para o app mostrar a mensagem
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

// apaga pelo e-mail; usado para limpar usuarios criados em testes
export async function removerUsuario(email: string): Promise<void> {
  await colecao().deleteOne({ email });
}
