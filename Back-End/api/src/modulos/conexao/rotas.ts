import { Router } from 'express';
import { criarConexao, obterConexao } from './handlers/rotasMatch';

export const rotasConexao = Router();

rotasConexao.get('/status', (_req, res) => {
  res.json({ tela: 'conexao', ok: true });
});

// Autor: Rafaela Jacobsen Braga - RA: 25004280
// Estas rotas exigem res.locals.usuarioId preenchido por autenticação VERIFICADA.
rotasConexao.post('/matches', criarConexao);
rotasConexao.get('/matches/:matchId', obterConexao);
