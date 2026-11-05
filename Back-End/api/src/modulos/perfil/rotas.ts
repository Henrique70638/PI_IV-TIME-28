import { Router } from 'express';

export const rotasPerfil = Router();

rotasPerfil.get('/status', (_req, res) => {
  res.json({ tela: 'perfil', ok: true });
});