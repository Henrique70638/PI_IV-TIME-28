// Autores: Emilly Morelatto
// Rafaela Jacobsen Braga - RA: 25004280

import { ObjectId } from 'mongodb';
import { getBanco } from '../../../shared/banco';

// Busca um usuario pelo ID
export async function buscarUsuarioPorId(id: ObjectId) {
    const usuario = await getBanco().collection('usuarios').findOne({
        _id: id
    });

    return usuario;
}

// Atualiza somente os dados públicos autorizados pelo validador.
export async function atualizarPerfilNoBanco(id: ObjectId, campos: Record<string, unknown>) {
    return getBanco().collection('usuarios').findOneAndUpdate(
        { _id: id }, { $set: campos }, { returnDocument: 'after' }
    );
}
