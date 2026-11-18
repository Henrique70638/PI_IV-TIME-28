// Autor: Rafaela Jacobsen Braga - RA: 25004280

import type { RequestHandler } from 'express';
import { buscarExcedentes } from '../repositories/buscarExcedentes';
import { validarFiltrosBusca } from '../types/filtrosBusca';

export const listarExcedentes: RequestHandler = async (req, res, next) => {
  try {
    const filtros = validarFiltrosBusca(req.query);
    const excedentes = await buscarExcedentes(filtros);
    res.json({ total: excedentes.length, excedentes });
  } catch (erro) {
    next(erro);
  }
};
