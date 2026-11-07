import { Router } from 'express';

export const rotasConexao = Router();

rotasConexao.get('/status', (_req, res) => {
  res.json({ tela: 'conexao', ok: true });
});