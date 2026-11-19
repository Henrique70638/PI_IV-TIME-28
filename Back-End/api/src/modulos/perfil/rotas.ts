//Autora: Emilly Morelatto

import { Router } from 'express';
import { buscarMeuPerfil } from './handlers/perfilHandler';
import { lerToken } from '../../shared/autenticacao';

export const rotasPerfil = Router();

// Busca os dados do usuario logado
rotasPerfil.get('/', lerToken, buscarMeuPerfil);
