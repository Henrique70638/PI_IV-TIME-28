import { Router } from 'express';

export const rotasConversas = Router();

rotasConversas.get('/status', (_req, res) => {
  res.json({ tela: 'conversas', ok: true });
});