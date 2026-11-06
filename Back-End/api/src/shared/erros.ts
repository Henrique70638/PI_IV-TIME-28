//Autora: Laura Lugli Fonseca Pereira RA:25000739
import { Request, Response, NextFunction } from 'express';

//erro com o status http junto, usado nas telas com throw
export class ErroApp extends Error {
    constructor(public status: number, mensagem: string) {
        super(mensagem);
    }
}

//todo erro das rotas cai aqui
export function tratarErros(erro: Error, _req: Request, res: Response, _next: NextFunction) {
    //erro esperado, devolve o status e a mensagem
    if (erro instanceof ErroApp) {
        return res.status(erro.status).json({ erro: erro.message });
    }

    //erro inesperado, mostra no terminal e nao manda os detalhes pro app
    console.error(erro);
    return res.status(500).json({ erro: 'Erro interno no servidor' });
}