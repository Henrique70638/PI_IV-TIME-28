import { Router } from 'express';
import { listarExcedentes } from './handlers/listarExcedentes';

export const rotasInicio = Router();

rotasInicio.get('/status', (_req, res) => {
  res.json({ tela: 'inicio', ok: true });
});

// GET /api/inicio/excedentes?latitude=-22.91&longitude=-47.065&raioKm=5&categoria=frutas
// Autor: Rafaela Jacobsen Braga - RA: 25004280
rotasInicio.get('/excedentes', listarExcedentes);
