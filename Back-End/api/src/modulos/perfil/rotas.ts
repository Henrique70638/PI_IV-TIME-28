// Autores: Emilly Morelatto
// Rafaela Jacobsen Braga - RA: 25004280

import { Router } from 'express';
import { buscarMeuPerfil } from './handlers/perfilHandler';
import { atualizarMeuPerfil } from './handlers/atualizarPerfil';
import { lerToken } from '../../shared/autenticacao';

export const rotasPerfil = Router();

// Busca os dados do usuario logado
rotasPerfil.get('/', lerToken, buscarMeuPerfil);

// A identidade vem do JWT; nunca do corpo enviado pelo aplicativo.
rotasPerfil.patch('/', lerToken, atualizarMeuPerfil);
