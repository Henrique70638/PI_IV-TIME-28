//Autora: Laura Lugli Fonseca Pereira RA: 25000739

import { ObjectId } from 'mongodb';
import { getBanco } from '../../../shared/banco';
import { Excedente } from '../types/excedente';
import { Usuario } from '../../cadastro/types/usuario';

//pega a coleção de excedentes só na hora de usar
function colecao() {
    return getBanco().collection<Excedente>('excedentes');
}

//salva o excedente e devolve ele com id gerado pelo banco
export async function inserirExcedente(excedente: Excedente): Promise<Excedente> {
    const resultado = await colecao().insertOne(excedente);
    return { ...excedente, _id: resultado.insertedId };
}

//busca os excedentes do usuário sem os removidos (do mais novo pro mais antigo)
export async function listarExcedentesDoOfertante(ofertanteId: ObjectId): Promise<Excedente[]> {
    return colecao()
        .find({ 'ofertante._id': ofertanteId, status: { $ne: 'removido' } })
        .sort({ criadoEm: -1 })
        .toArray();
}

//busca quem esta publicando pra copiar o nome e a localizacao
export async function buscarOfertante(id: ObjectId): Promise<Usuario | null> {
    return getBanco().collection<Usuario>('usuarios').findOne({ _id: id });
}