//Autora: Emilly Morelatto

import { ObjectId } from 'mongodb';
import { db } from '../../../shared/bancoDados';

// Busca um usuario pelo ID
export async function buscarUsuarioPorId(id: ObjectId) {
    const usuario = await db.collection('usuarios').findOne({
        _id: id
    });

    return usuario;
}
