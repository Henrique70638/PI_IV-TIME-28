import { Router } from 'express';

export const rotasPublicar = Router();

rotasPublicar.get('/status', (_req, res) => {
  res.json({ tela: 'publicar', ok: true });
});