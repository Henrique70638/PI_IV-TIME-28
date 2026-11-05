import { Router } from 'express';
import { rotasCadastro } from './modulos/cadastro/rotas';
import { rotasLogin } from './modulos/login/rotas';

export const rotas = Router();

rotas.use('/cadastro', rotasCadastro);
rotas.use('/login', rotasLogin);