import { ObjectId } from 'mongodb';
import { getBanco } from '../../../shared/banco';
import { Excedente } from '../types/excedente';


function colecao() {
  return getBanco().collection<Excedente>('excedentes');
}

export async function inserirExcedente(excedente: Excedente): Promise<Excedente> {
  const resultado = await colecao().insertOne(excedente);
  return { ...excedente, _id: resultado.insertedId };
}

export async function listarExcedentesDoOfertante(ofertanteId: ObjectId): Promise<Excedente[]> {
  return colecao()
    .find({ 'ofertante._id': ofertanteId, status: { $ne: 'removido' } })
    .sort({ criadoEm: -1 })
    .toArray();
}