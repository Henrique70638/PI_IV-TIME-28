/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const fs = require('fs');
const path = require('path');
const { colecoes, indices, colecoesFuturas } = require('./schema');

const rotuloTipo = (def) => ({ objectId: 'ObjectId', string: 'string', number: 'number', boolean: 'bool', date: 'date', ponto: 'GeoJSON Point', objeto: 'object', 'array<string>': 'array de string', 'array<objectId>': 'array de ObjectId' }[def.tipo]);

function detalhes(def) {
  const itens = [];
  if (def.valores) itens.push(def.valores.map((v) => `\`${v}\``).join(', '));
  if (def.regra) itens.push(def.regra);
  if (def.minLength !== undefined && def.maxLength !== undefined) itens.push(`${def.minLength} a ${def.maxLength} caracteres`);
  else if (def.maxLength !== undefined) itens.push(`até ${def.maxLength} caracteres`);
  if (def.minimum !== undefined && def.maximum !== undefined) itens.push(`${def.minimum} a ${def.maximum}`);
  if (def.maxItems !== undefined && def.tipo === 'array<string>') itens.push(`até ${def.maxItems} itens`);
  return itens.join('; ') || '—';
}

function linhas(campos, prefixo = '', mvpHerdado = true) {
  const saida = [];
  for (const [nome, def] of Object.entries(campos)) {
    const mvp = mvpHerdado && def.mvp !== false;
    saida.push(`| \`${prefixo}${nome}\` | ${rotuloTipo(def)} | ${def.obrigatorio ? 'Sim' : 'Não'} | ${detalhes(def)} | ${def.desc} | ${mvp ? 'MVP' : 'Futuro'} |`);
    if (def.tipo === 'objeto') saida.push(...linhas(def.campos, `${prefixo}${nome}.`, mvp));
  }
  return saida;
}

const partes = [
  '# Dicionário de dados',
  '',
  'Gerado automaticamente a partir de `scripts/schema.js` (`npm run dicionario`). Não editar à mão: altere o esquema e gere novamente.',
  '',
  'Banco: `cultmais`. Convenções: nomes de campos em camelCase, sem acentos; datas em `date` (UTC); localizações em GeoJSON no formato `{ type: "Point", coordinates: [longitude, latitude] }`. A coluna **Fase** indica se o campo é usado pelo MVP ou pertence a uma funcionalidade futura.',
];

for (const [nome, def] of Object.entries(colecoes)) {
  partes.push('', `## Coleção \`${nome}\``, '', def.desc, '', '| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |', '|---|---|---|---|---|---|', ...linhas(def.campos));
  const lista = indices[nome] || [];
  if (lista.length) {
    partes.push('', 'Índices:', '', '| Nome | Chave | Único | Uso |', '|---|---|---|---|');
    for (const i of lista) partes.push(`| \`${i.opcoes.name}\` | \`${JSON.stringify(i.chave)}\` | ${i.opcoes.unique ? 'Sim' : 'Não'} | ${i.uso} |`);
  }
}

partes.push('', '## Coleções futuras (fora do MVP)', '', 'Ainda não existem no banco; ficam documentadas para a evolução do produto.', '', '| Coleção | Descrição | Campos previstos |', '|---|---|---|');
for (const f of colecoesFuturas) partes.push(`| \`${f.nome}\` | ${f.desc} | ${f.campos} |`);

const destino = path.join(__dirname, '..', 'docs', '04-dicionario-de-dados.md');
fs.writeFileSync(destino, partes.join('\n') + '\n');
console.log('Gerado:', path.join('docs', '04-dicionario-de-dados.md'));
