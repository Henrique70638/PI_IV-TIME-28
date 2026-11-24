// Autor: Rafaela Jacobsen Braga - RA: 25004280
import { ObjectId } from 'mongodb';
import { ErroApp } from '../../../shared/erros';
import { CriarMatchEntrada, Categoria } from './modelosConexao';

const categorias: Categoria[] = ['frutas', 'verduras', 'legumes', 'mudas'];

export function objectIdObrigatorio(valor: unknown, campo: string): ObjectId {
  // ObjectId.isValid aceita outros formatos; a API só aceita a representação hexadecimal.
  if (typeof valor !== 'string' || !/^[a-f0-9]{24}$/i.test(valor)) {
    throw new ErroApp(400, `${campo} deve ser um identificador válido.`);
  }
  return new ObjectId(valor);
}

export function validarCriacaoMatch(corpo: unknown): CriarMatchEntrada {
  if (corpo === null || typeof corpo !== 'object' || Array.isArray(corpo)) {
    throw new ErroApp(400, 'Informe os dados da conexão em JSON.');
  }
  const dados = corpo as Record<string, unknown>;
  const permitidos = ['excedenteId', 'raioKm', 'categoria'];
  if (Object.keys(dados).some((chave) => !permitidos.includes(chave))) {
    throw new ErroApp(400, 'A requisição contém campos não permitidos.');
  }

  const excedenteId = objectIdObrigatorio(dados.excedenteId, 'excedenteId');
  const raioKm = dados.raioKm === undefined ? 5 : dados.raioKm;
  if (typeof raioKm !== 'number' || !Number.isFinite(raioKm) || raioKm < 0.1 || raioKm > 50) {
    throw new ErroApp(400, 'raioKm deve ser um número entre 0,1 e 50.');
  }
  let categoria: Categoria | undefined;
  if (dados.categoria !== undefined) {
    if (typeof dados.categoria !== 'string') throw new ErroApp(400, 'Categoria inválida.');
    const normalizada = dados.categoria === 'plantas' ? 'mudas' : dados.categoria;
    if (!categorias.includes(normalizada as Categoria)) {
      throw new ErroApp(400, 'Categoria inválida.');
    }
    categoria = normalizada as Categoria;
  }
  return { excedenteId, raioKm, ...(categoria && { categoria }) };
}
