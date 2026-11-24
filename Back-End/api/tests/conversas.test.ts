// Autor: Rafaela Jacobsen Braga - RA: 25004280
import test from 'node:test';
import assert from 'node:assert/strict';
import type { Request, Response } from 'express';
import { ObjectId } from 'mongodb';
import { ErroApp } from '../src/shared/erros';
import { usuarioLogado } from '../src/shared/autenticacao';
import { listarConversas } from '../src/modulos/conversas/handlers/listarConversas';
import { obterConversa } from '../src/modulos/conversas/handlers/obterConversa';
import { enviarMensagem } from '../src/modulos/conversas/handlers/enviarMensagem';
import { lerTextoMensagem } from '../src/modulos/conversas/handlers/validacoes';
import { mensagemPublica, participa } from '../src/modulos/conversas/handlers/formatadores';

const id = new ObjectId('a10000000000000000000001');
const estranho = new ObjectId('a10000000000000000000002');
const matchId = new ObjectId('b20000000000000000000001');
const respostaSemLogin = { locals: {} } as Response;

function erro401(erro: unknown): boolean {
  return erro instanceof ErroApp && erro.status === 401;
}

test('não permite listar conversas usando usuarioId de outra pessoa na URL', async () => {
  await assert.rejects(
    listarConversas({ query: { usuarioId: id.toHexString() } } as unknown as Request, respostaSemLogin),
    erro401,
  );
});

test('não permite consultar mensagens sem sessão mesmo recebendo um usuarioId', async () => {
  await assert.rejects(
    obterConversa({ params: { matchId: matchId.toHexString() }, query: { usuarioId: id.toHexString() } } as unknown as Request, respostaSemLogin),
    erro401,
  );
});

test('não permite forjar autorId no corpo sem autenticação', async () => {
  await assert.rejects(
    enviarMensagem({ params: { matchId: matchId.toHexString() }, body: { autorId: id.toHexString(), texto: 'Oi' } } as unknown as Request, respostaSemLogin),
    erro401,
  );
});

test('usa o usuário autenticado no middleware, não os campos do cliente', () => {
  const resposta = { locals: { usuarioId: id.toHexString() } } as unknown as Response;
  assert.ok(usuarioLogado(resposta).equals(id));
  assert.throws(() => usuarioLogado(respostaSemLogin), erro401);
});

test('mensagens são limitadas e participantes são conferidos', () => {
  assert.equal(lerTextoMensagem('  Olá!  '), 'Olá!');
  assert.throws(() => lerTextoMensagem(' '.repeat(10)), /Digite/);
  assert.throws(() => lerTextoMensagem('x'.repeat(1001)), /1000/);
  const match = { participantes: [id] } as any;
  assert.equal(participa(match, id), true);
  assert.equal(participa(match, estranho), false);
});

test('a API não devolve o autorId ou o matchId nas mensagens públicas', () => {
  const publica = mensagemPublica({
    _id: new ObjectId(), matchId, autorId: id, texto: 'Olá', criadoEm: new Date(),
  }, id);
  assert.equal(publica.minha, true);
  assert.equal(publica.texto, 'Olá');
  assert.equal('autorId' in publica, false);
  assert.equal('matchId' in publica, false);
});
