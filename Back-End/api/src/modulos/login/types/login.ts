//Autora: Laura Lugli Fonseca Pereira RA:25000739

import { UsuarioPublico } from '../../cadastro/types/usuario';

//o que o app manda pra fazer login
export interface DadosLogin {
    email: string;
    senha: string;
}

//o que a api devolve quando o login da certo
export interface RespostaLogin {
    token: string;
    usuario: UsuarioPublico;
}
