//Autora: Laura Lugli Fonseca Pereira RA:25000739

import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { env } from './env';

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