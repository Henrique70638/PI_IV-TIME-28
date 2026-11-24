import { Router } from 'express';
import { fazerLogin } from './handlers/fazerLogin';

export const rotasLogin = Router();

rotasLogin.get('/status', (_req, res) => {
  res.json({ tela: 'login', ok: true });
});
//confere e-mail e senha e devolve o token
rotasLogin.post('/', fazerLogin);