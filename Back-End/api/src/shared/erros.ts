import { Request, Response, NextFunction } from 'express';

export class ErroApp extends Error {
  constructor(public status: number, mensagem: string) {
    super(mensagem);
  }
}

export function tratarErros(erro: Error, _req: Request, res: Response, _next: NextFunction) {
  if (erro instanceof ErroApp) {
    return res.status(erro.status).json({ erro: erro.message });
  }

  console.error(erro);
  return res.status(500).json({ erro: 'Erro interno no servidor' });
}