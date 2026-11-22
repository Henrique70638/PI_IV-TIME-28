// Autor: Rafaela Jacobsen Braga - RA: 25004280
import test from 'node:test';
import assert from 'node:assert/strict';
import { validarAtualizacaoPerfil } from '../src/modulos/perfil/handlers/atualizarPerfil';

test('permite trocar nome e tipo de conta sem modificar a localizacao', () => {
  assert.deepEqual(validarAtualizacaoPerfil({ nome: '  Rafaela  ', perfil: 'ambos' }),
    { nome: 'Rafaela', perfil: 'ambos' });
});
test('não permite alterar credenciais nem fingir outro usuario', () => {
  assert.throws(() => validarAtualizacaoPerfil({ email: 'outro@exemplo.com' }));
  assert.throws(() => validarAtualizacaoPerfil({ email: 'email-invalido', senhaAtual: 'senha' }));
  assert.throws(() => validarAtualizacaoPerfil({ senhaAtual: 'senha' }));
  assert.throws(() => validarAtualizacaoPerfil({ usuarioId: 'forjado', nome: 'Ana' }));
});
test('permite trocar o e-mail apenas com senha atual e normaliza o endereço', () => {
  assert.deepEqual(validarAtualizacaoPerfil({
    email: '  NOVO@EXEMPLO.COM ', senhaAtual: 'minhaSenhaAtual',
  }), { email: 'novo@exemplo.com' });
});
test('exige bairro, cidade e coordenadas juntos para mudar a localização', () => {
  assert.throws(() => validarAtualizacaoPerfil({ bairro: 'Cambuí' }));
  assert.throws(() => validarAtualizacaoPerfil({ bairro: 'Cambuí', cidade: 'Campinas', latitude: -22.9 }));
  assert.deepEqual(validarAtualizacaoPerfil({
    bairro: 'Cambuí', cidade: 'Campinas', latitude: -22.9, longitude: -47.06,
  }), {
    bairro: 'Cambuí', cidade: 'Campinas',
    localizacao: { type: 'Point', coordinates: [-47.06, -22.9] },
  });
});
test('recusa coordenadas e tipos invalidos', () => {
  assert.throws(() => validarAtualizacaoPerfil({
    bairro: 'Centro', cidade: 'Campinas', latitude: 900, longitude: -47,
  }));
  assert.throws(() => validarAtualizacaoPerfil({ perfil: 'administrador' }));
  assert.throws(() => validarAtualizacaoPerfil({}));
});
