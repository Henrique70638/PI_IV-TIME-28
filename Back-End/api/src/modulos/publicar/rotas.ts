//Autora: Laura Lugli Fonseca Pereira RA: 25000739
import { Router } from 'express';
import { publicarExcedente } from './handlers/publicarExcedente';
import { listarExcedentes } from './handlers/listarExcedentes';

//rotas da tela de publicar
export const rotasPublicar = Router();

//rota de teste pra ver se a tela ta ligada na api
rotasPublicar.get('/status', (_req, res) => {
  res.json({ tela: 'publicar', ok: true });
});

//publica um excedente novo
rotasPublicar.post('/', publicarExcedente);
//lista os excedentes publicados pelo usuário
rotasPublicar.get('/', listarExcedentes);