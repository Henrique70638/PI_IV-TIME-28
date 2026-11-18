/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { Router } from 'express';
import { cadastrar } from './handlers/cadastrar';

export const rotasCadastro = Router();

rotasCadastro.get('/status', (_req, res) => {
  res.json({ tela: 'cadastro', ok: true });
});

rotasCadastro.post('/', cadastrar);
