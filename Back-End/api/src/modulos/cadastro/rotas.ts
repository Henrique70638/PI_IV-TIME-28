import { Router } from 'express';

export const rotasCadastro = Router();

rotasCadastro.get('/status', (_req, res) => {
  res.json({ tela: 'cadastro', ok: true });
});