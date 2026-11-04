import { MongoClient, Db } from 'mongodb';
import { env } from './env';

const cliente = new MongoClient(env.mongoUri, { serverSelectionTimeoutMS: 5000 });
let banco: Db | null = null;

export async function conectarBanco(): Promise<Db> {
  if (!banco) {
    await cliente.connect();
    banco = cliente.db(env.mongoBanco);
    console.log(`MongoDB conectado no banco ${env.mongoBanco}`);
  }
  return banco;
}

export function getBanco(): Db {
  if (!banco) throw new Error('Banco ainda não conectado');
  return banco;
}