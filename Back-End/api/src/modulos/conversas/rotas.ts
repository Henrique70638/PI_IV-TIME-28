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

// rota de teste: so confirma que o modulo de conversas esta no ar
rotasConversas.get('/status', (_req, res) => {
  res.json({ tela: 'conversas', ok: true });
});

// GET /api/conversas: lista as conversas do usuario logado
rotasConversas.get('/', listarConversas);
// GET /api/conversas/:matchId: abre uma conversa com as mensagens
rotasConversas.get('/:matchId', obterConversa);
// POST /api/conversas/:matchId/mensagens: envia uma mensagem
rotasConversas.post('/:matchId/mensagens', enviarMensagem);
