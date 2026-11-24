//Autora: Laura Lugli Fonseca Pereira RA:25000739

import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { ErroApp } from '../../../shared/erros';
import { gerarToken } from '../../../shared/autenticacao';
import { buscarUsuarioPorEmail } from '../repositories/usuarioLoginRepository';
import { UsuarioPublico } from '../../cadastro/types/usuario';
import { RespostaLogin } from '../types/login';

//confere o e-mail e a senha e devolve o token
export async function fazerLogin(req: Request, res: Response, next: NextFunction) {
    try {
        //o cadastro salva o e-mail em minusculo, entao aqui tambem
        const email = typeof req.body?.email === 'string' ? req.body.email.trim().toLowerCase() : '';
        const senha = typeof req.body?.senha === 'string' ? req.body.senha : '';

        if (!email || !senha)
            throw new ErroApp(400, 'Informe o e-mail e a senha');

        const usuario = await buscarUsuarioPorEmail(email);

        //compara a senha digitada com a senha criptografada do banco
        const senhaCerta = usuario ? await bcrypt.compare(senha, usuario.senhaHash) : false;

        //mesma mensagem nos dois casos pra nao entregar quais e-mails existem
        if (!usuario || !senhaCerta)
            throw new ErroApp(401, 'E-mail ou senha incorretos');

        //dados do usuario sem a senha
        const dadosUsuario: UsuarioPublico = {
            id: usuario._id.toHexString(),
            nome: usuario.nome,
            email: usuario.email,
            perfil: usuario.perfil,
            bairro: usuario.bairro,
            cidade: usuario.cidade,
        };

        //monta a resposta no formato combinado
        const resposta: RespostaLogin = {
            token: gerarToken(dadosUsuario.id),
            usuario: dadosUsuario,
        };

        res.json(resposta);

    } catch (erro) {
        next(erro);
    }


}