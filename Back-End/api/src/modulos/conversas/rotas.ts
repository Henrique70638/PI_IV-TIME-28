/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { Router } from 'express';
import { enviarMensagem } from './handlers/enviarMensagem';
import { listarConversas } from './handlers/listarConversas';
import { obterConversa } from './handlers/obterConversa';

export const rotasConversas = Router();

rotasConversas.get('/status', (_req, res) => {
  res.json({ tela: 'conversas', ok: true });
});

rotasConversas.get('/', listarConversas);
rotasConversas.get('/:matchId', obterConversa);
rotasConversas.post('/:matchId/mensagens', enviarMensagem);
