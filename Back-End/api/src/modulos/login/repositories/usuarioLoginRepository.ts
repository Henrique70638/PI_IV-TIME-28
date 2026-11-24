//Autora: Laura Lugli Fonseca Pereira RA:25000739

import { getBanco } from '../../../shared/banco';
import { Usuario } from '../../cadastro/types/usuario';

//pega a colecao de usuarios so na hora de usar
function colecao() {
  return getBanco().collection<Usuario>('usuarios');
}

//busca o usuario pelo e-mail, devolve null se nao existir
export async function buscarUsuarioPorEmail(email: string): Promise<Usuario | null> {
  return colecao().findOne({ email });
}