//Autora: Laura Lugli Fonseca Pereira RA:25000739
import express from 'express';
import cors from 'cors';
import { rotas } from './rotas';
import { tratarErros } from './shared/erros';
import { lerToken } from './shared/autenticacao';

export const app = express();

//libera o app acessar a api
app.use(cors());
//permite receber json no corpo da requisicao
app.use(express.json());
//libera o app acessar a api
app.use(cors());
//permite receber json no corpo da requisicao
app.use(express.json());
//confere o token de login em todo pedido
app.use(lerToken);

//rota pra testar se a api ta funcionando
app.get('/saude', (_req, res) => {
    res.json({ ok: true });
});

//rotas de todas as telas comecam com /api
app.use('/api', rotas);

//tem que ficar por ultimo pra pegar os erros das rotas
app.use(tratarErros);