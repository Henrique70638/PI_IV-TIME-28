import { Router } from 'express';
import { publicarExcedente } from './handlers/publicarExcedente';
import { listarExcedentes } from './handlers/listarExcedentes';

export const rotasPublicar = Router();

rotasPublicar.get('/status', (_req, res) => {
  res.json({ tela: 'publicar', ok: true });
});


rotasPublicar.post('/', publicarExcedente);
rotasPublicar.get('/', listarExcedentes);