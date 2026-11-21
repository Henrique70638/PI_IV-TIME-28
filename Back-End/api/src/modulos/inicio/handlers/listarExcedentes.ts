// Autor: Rafaela Jacobsen Braga - RA: 25004280

import type { RequestHandler } from 'express';
import { ObjectId } from 'mongodb';
import { getBanco } from '../../../shared/banco';
import { ErroApp } from '../../../shared/erros';
import { buscarExcedentes } from '../repositories/buscarExcedentes';
import { validarFiltrosBusca } from '../types/filtrosBusca';

export const listarExcedentes: RequestHandler = async (req, res, next) => {
  try {
    // Na sessão autenticada, a localização vem do cadastro no banco.
    // A consulta com coordenadas explícitas continua disponível para testes.
    let entrada = req.query;
    if (req.query.latitude === undefined && req.query.longitude === undefined) {
      const id = res.locals.usuarioId as unknown;
      if (typeof id !== 'string' || !/^[a-f0-9]{24}$/i.test(id)) {
        throw new ErroApp(401, 'Faça login para buscar ofertas próximas.');
      }
      const usuario = await getBanco().collection('usuarios').findOne(
        { _id: new ObjectId(id) },
        { projection: { localizacao: 1 } },
      );
      const ponto = usuario?.localizacao?.coordinates;
      if (!Array.isArray(ponto) || ponto.length !== 2 ||
          !ponto.every((n: unknown) => typeof n === 'number' && Number.isFinite(n))) {
        throw new ErroApp(422, 'Localização do cadastro indisponível.');
      }
      entrada = {
        ...req.query,
        longitude: String(ponto[0]),
        latitude: String(ponto[1]),
      };
    }
    const filtros = validarFiltrosBusca(entrada);
    const excedentes = await buscarExcedentes(filtros);
    res.json({ total: excedentes.length, excedentes });
  } catch (erro) {
    next(erro);
  }
};
