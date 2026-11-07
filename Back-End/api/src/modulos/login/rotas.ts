import { Router } from 'express';

export const rotasLogin = Router();

rotasLogin.get('/status', (_req, res) => {
  res.json({ tela: 'login', ok: true });
});