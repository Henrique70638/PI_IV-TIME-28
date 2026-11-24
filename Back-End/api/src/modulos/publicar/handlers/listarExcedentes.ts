//Autora: Laura Lugli Fonseca Pereira RA:25000739

import { Request, Response, NextFunction } from 'express';
import { usuarioLogado } from '../../../shared/autenticacao';
import { listarExcedentesDoOfertante } from '../repositories/excedenteRepository';

//devolve os excedentes publicados pelo usuario logado
export async function listarExcedentes(_req: Request, res: Response, next: NextFunction) {
    try {
        //o usuario vem do token, nao mais do endereco
        const ofertanteId = usuarioLogado(res);

        const excedentes = await listarExcedentesDoOfertante(ofertanteId);
        res.json(excedentes);
    } catch (erro) {
        next(erro);
    }
}