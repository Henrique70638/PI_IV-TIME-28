//Autora: Emilly Morelatto

import { ObjectId } from 'mongodb';
import { getBanco } from '../../../shared/banco';

// Busca um usuario pelo ID
export async function buscarUsuarioPorId(id: ObjectId) {
    const usuario = await getBanco().collection('usuarios').findOne({
        _id: id
    });

    return usuario;
}
