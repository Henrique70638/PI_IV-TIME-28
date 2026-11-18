import { Request, Response, NextFunction } from 'express';
import { ObjectId } from 'mongodb';
import { ErroApp } from '../../../shared/erros';
import { listarExcedentesDoOfertante } from '../repositories/excedenteRepository';

export async function listarExcedentes(req: Request, res: Response, next: NextFunction) {
    try {
        const ofertanteId = req.query.ofertanteId;

        if (typeof ofertanteId !== 'string' || !ObjectId.isValid(ofertanteId))
            throw new ErroApp(400, 'Ofertante inválido');

        const excedentes = await listarExcedentesDoOfertante(new ObjectId(ofertanteId));
        res.json(excedentes);
    } catch (erro) {
        next(erro);
    }
}