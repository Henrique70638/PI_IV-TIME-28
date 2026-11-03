/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const fs = require('fs');
const path = require('path');
const { colecoes, indices, jsonSchemaDe } = require('./schema');
const dados = require('./dados-exemplo');

const CABECALHO = `/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * ARQUIVO GERADO por scripts/gerar-mongo.js. Não editar à mão.
 */
`;

const identificador = /^[A-Za-z_$][A-Za-z0-9_$]*$/;

function paraJs(valor, nivel = 0) {
  const recuo = '  '.repeat(nivel + 1);
  const fecha = '  '.repeat(nivel);
  if (valor === null) return 'null';
  if (Array.isArray(valor)) {
    if (!valor.length) return '[]';
    const simples = valor.every((v) => v === null || typeof v !== 'object' || v.$oid !== undefined || v.$date !== undefined);
    const itens = valor.map((v) => paraJs(v, nivel + 1));
    if (simples && itens.join(', ').length < 90) return `[${itens.join(', ')}]`;
    return `[\n${itens.map((i) => recuo + i).join(',\n')}\n${fecha}]`;
  }
  if (typeof valor === 'object') {
    if (valor.$oid !== undefined) return `ObjectId(${JSON.stringify(valor.$oid)})`;
    if (valor.$date !== undefined) return `ISODate(${JSON.stringify(valor.$date)})`;
    const entradas = Object.entries(valor).map(([k, v]) => `${identificador.test(k) ? k : JSON.stringify(k)}: ${paraJs(v, nivel + 1)}`);
    if (!entradas.length) return '{}';
    const linha = `{ ${entradas.join(', ')} }`;
    if (linha.length < 80 && !linha.includes('\n')) return linha;
    return `{\n${entradas.map((e) => recuo + e).join(',\n')}\n${fecha}}`;
  }
  return JSON.stringify(valor);
}

const indenta = (texto, n = 2) => texto.split('\n').map((l) => (l ? ' '.repeat(n) + l : l)).join('\n');
const envolve = (corpo) => `${CABECALHO}\n(() => {\n${indenta(corpo)}\n})();\n`;

function arquivoColecoes() {
  const validadores = Object.keys(colecoes)
    .map((nome) => `${nome}: ${paraJs(jsonSchemaDe(nome), 0)}`)
    .join(',\n');
  const corpo = `const bd = db.getSiblingDB('cultmais');

const validadores = {
${indenta(validadores)}
};

function criarOuAtualizar(nome, esquema) {
  const validator = { $jsonSchema: esquema };
  const opcoes = { validationLevel: 'strict', validationAction: 'error' };
  if (bd.getCollectionInfos({ name: nome }).length > 0) {
    bd.runCommand({ collMod: nome, validator, ...opcoes });
    print('Coleção atualizada: ' + nome);
  } else {
    bd.createCollection(nome, { validator, ...opcoes });
    print('Coleção criada: ' + nome);
  }
}

for (const [nome, esquema] of Object.entries(validadores)) criarOuAtualizar(nome, esquema);
`;
  return envolve(corpo);
}

function arquivoIndices() {
  const blocos = Object.entries(indices).map(([nome, lista]) => {
    const linhas = lista.map((i) => `bd.${nome}.createIndex(${paraJs(i.chave)}, ${paraJs(i.opcoes)});`);
    return `// ${nome}\n${linhas.join('\n')}`;
  });
  const corpo = `const bd = db.getSiblingDB('cultmais');

${blocos.join('\n\n')}

for (const nome of ${paraJs(Object.keys(indices))}) {
  print('Índices de ' + nome + ': ' + bd.getCollection(nome).getIndexes().map((i) => i.name).join(', '));
}
`;
  return envolve(corpo);
}

function arquivoDados() {
  const partes = ['usuarios', 'excedentes', 'matches', 'mensagens'].map((nome) => {
    const ids = dados[nome].map((d) => paraJs(d._id));
    return `bd.${nome}.deleteMany({ _id: { $in: [${ids.join(', ')}] } });
bd.${nome}.insertMany(${paraJs(dados[nome])});
print('${nome}: ' + bd.${nome}.countDocuments() + ' documentos');`;
  });
  const corpo = `const bd = db.getSiblingDB('cultmais');

${partes.join('\n\n')}
`;
  return envolve(corpo);
}

const pasta = path.join(__dirname, '..', 'mongo');
fs.mkdirSync(pasta, { recursive: true });
const saidas = { '01-colecoes.js': arquivoColecoes(), '02-indices.js': arquivoIndices(), '03-dados-exemplo.js': arquivoDados() };
for (const [nome, conteudo] of Object.entries(saidas)) {
  fs.writeFileSync(path.join(pasta, nome), conteudo);
  console.log('Gerado:', path.join('mongo', nome));
}
