/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * Cria o banco do CULT+ do zero: coleções com validação, índices e dados de exemplo.
 * Execute a partir da pasta mongo: mongosh "<string-de-conexao>" --file 00-executar-tudo.js
 */

load('01-colecoes.js');
load('02-indices.js');
load('03-dados-exemplo.js');
print('Banco cultmais pronto.');
