import { Router } from 'express';

export const rotasInicio = Router();

rotasInicio.get('/status', (_req, res) => {
  res.json({ tela: 'inicio', ok: true });
});