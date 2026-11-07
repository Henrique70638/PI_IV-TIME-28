//Autora: Laura Lugli Fonseca Pereira RA:25000739
import { MongoClient, Db } from 'mongodb';
import { env } from './env';

//cliente do mongo, desiste de conectar depois de 5 segundos
const cliente = new MongoClient(env.mongoUri, { serverSelectionTimeoutMS: 5000 });

//guarda a conexao pra todo mundo usar a mesma
let banco: Db | null = null;

//conecta no banco so na primeira vez
export async function conectarBanco(): Promise<Db> {
    if (!banco) {
        await cliente.connect();
        banco = cliente.db(env.mongoBanco);
        console.log(`MongoDB conectado no banco ${env.mongoBanco}`);
    }
    return banco;
}

//usado pelos repositories pra pegar o banco
export function getBanco(): Db {
    if (!banco) throw new Error('Banco ainda não conectado');
    return banco;
}