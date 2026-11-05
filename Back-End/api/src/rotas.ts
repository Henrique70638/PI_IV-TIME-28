import { Router } from 'express';
import { rotasCadastro } from './modulos/cadastro/rotas';
import { rotasLogin } from './modulos/login/rotas';
import { rotasInicio } from './modulos/inicio/rotas';
import { rotasPerfil } from './modulos/perfil/rotas';
import { rotasConversas } from './modulos/conversas/rotas';
import { rotasConexao } from './modulos/conexao/rotas';
import { rotasPublicar } from './modulos/publicar/rotas';

export const rotas = Router();

rotas.use('/cadastro', rotasCadastro);
rotas.use('/login', rotasLogin);
rotas.use('/inicio', rotasInicio);
rotas.use('/perfil', rotasPerfil);
rotas.use('/conversas', rotasConversas);
rotas.use('/conexao', rotasConexao);
rotas.use('/publicar', rotasPublicar);