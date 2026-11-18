// Autor: Rafaela Jacobsen Braga - RA: 25004280

import test from 'node:test';
import assert from 'node:assert/strict';
import { validarFiltrosBusca } from '../src/modulos/inicio/types/filtrosBusca';
import { montarPipelineBusca } from '../src/modulos/inicio/repositories/buscarExcedentes';

const local = { latitude: '-22.91', longitude: '-47.065' };

test('usa raio padrão de 5 km e limite de 30', () => {
  const filtros = validarFiltrosBusca(local);
  assert.equal(filtros.raioKm, 5);
  assert.equal(filtros.limite, 30);
  assert.equal(filtros.categoria, undefined);
});

test('rejeita coordenadas inválidas e parâmetro repetido', () => {
  assert.throws(() => validarFiltrosBusca({ ...local, latitude: '100' }), /latitude/);
  assert.throws(() => validarFiltrosBusca({ ...local, longitude: ['-47.065'] }), /longitude/);
  assert.throws(() => validarFiltrosBusca({ ...local, raioKm: '0' }), /raioKm/);
});

test('rejeita categorias e limites inválidos', () => {
  assert.throws(() => validarFiltrosBusca({ ...local, categoria: 'flores' }), /Categoria/);
  assert.throws(() => validarFiltrosBusca({ ...local, limite: '2.5' }), /inteiro/);
});

test('converte plantas em mudas conforme banco', () => {
  assert.equal(validarFiltrosBusca({ ...local, categoria: 'plantas' }).categoria, 'mudas');
});

test('filtra por proximidade, status, categoria e modalidade', () => {
  const filtros = validarFiltrosBusca({ ...local, raioKm: '3', categoria: 'frutas', modalidade: 'doacao' });
  const pipeline = montarPipelineBusca(filtros);
  const geo = pipeline[0].$geoNear;
  assert.deepEqual(geo.near.coordinates, [-47.065, -22.91]);
  assert.equal(geo.maxDistance, 3000);
  assert.deepEqual(geo.query, { status: 'disponivel', categoria: 'frutas', modalidade: 'doacao' });
  assert.deepEqual(pipeline[1], { $limit: 30 });
});

test('escapa caracteres especiais na busca e não expõe dados privados', () => {
  const filtros = validarFiltrosBusca({ ...local, busca: 'Maçã.*' });
  const pipeline = montarPipelineBusca(filtros);
  assert.deepEqual(pipeline[0].$geoNear.query.produto, { $regex: 'Maçã\\.\\*', $options: 'i' });
  const projecao = pipeline[2].$project;
  assert.equal(projecao._id, 0);
  assert.equal(projecao.email, undefined);
  assert.equal(projecao.senhaHash, undefined);
  assert.equal(projecao.localizacao, undefined);
});
