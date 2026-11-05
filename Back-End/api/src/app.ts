import express from 'express';
import cors from 'cors';
import { rotas } from './rotas';
import { tratarErros } from './shared/erros';

export const app = express();

app.use(cors());
app.use(express.json());

app.get('/saude', (_req, res) => {
  res.json({ ok: true });
});

app.use('/api', rotas);

app.use(tratarErros);