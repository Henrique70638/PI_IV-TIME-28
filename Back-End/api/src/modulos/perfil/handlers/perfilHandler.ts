//Autora: Emilly Morelatto

import { Request, Response, NextFunction } from 'express';
import { ErroApp } from '../../../shared/erros';
import { usuarioLogado } from '../../../shared/autenticacao';
import { buscarUsuarioPorId } from '../repositories/perfilRepository';
import { UsuarioPublico } from '../../cadastro/types/usuario';

// Busca os dados do usuario que esta logado
export async function buscarMeuPerfil(
    req: Request,
    res: Response,
    next: NextFunction
) {
    try {
        // Identifica o usuario pelo token
        const idUsuario = usuarioLogado(res);

        // Busca os dados no banco
        const usuario = await buscarUsuarioPorId(idUsuario);

        if (!usuario)
            throw new ErroApp(404, 'Usuario nao encontrado');

        // Dados publicos do usuario
        const dadosUsuario: UsuarioPublico = {
            id: usuario._id.toHexString(),
            nome: usuario.nome,
            email: usuario.email,
            perfil: usuario.perfil,
            bairro: usuario.bairro,
            cidade: usuario.cidade,
        };

        res.json(dadosUsuario);

    } catch (erro) {
        next(erro);
    }
}
