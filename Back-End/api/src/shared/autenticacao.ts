//Autora: Laura Lugli Fonseca Pereira RA:25000739

import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { ObjectId } from 'mongodb';
import { env } from './env';
import { ErroApp } from './erros';

//pega o segredo do .env e avisa se esqueceram de configurar
function segredo(): string {
    if (!env.jwtSegredo) throw new Error('JWT_SEGREDO não configurado no .env');
    return env.jwtSegredo;
}

//cria o token com o id do usuario, vale por 7 dias
export function gerarToken(usuarioId: string): string {
    return jwt.sign({ sub: usuarioId }, segredo(), { expiresIn: '7d' });
}

//confere o token de todo pedido e, se for valido, guarda quem e o usuario
export function lerToken(req: Request, res: Response, next: NextFunction) {
    const cabecalho = req.headers.authorization;

    //o app manda o token assim: Authorization: Bearer <token>
    if (cabecalho && cabecalho.startsWith('Bearer ')) {
        const token = cabecalho.slice(7);

        try {
            const dados = jwt.verify(token, segredo());
            if (typeof dados === 'object' && typeof dados.sub === 'string') {
                res.locals.usuarioId = dados.sub;
            }
        } catch {
            //token falso ou vencido: segue sem usuario
        }
    }

    next();
}

//usado nas rotas que exigem login, devolve o id de quem esta logado
export function usuarioLogado(res: Response): ObjectId {
    const id = res.locals.usuarioId;

    if (typeof id !== 'string' || !ObjectId.isValid(id))
        throw new ErroApp(401, 'Faça login para continuar');

    return new ObjectId(id);
}