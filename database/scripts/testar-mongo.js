/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const fs = require('fs');
const path = require('path');
const vm = require('vm');
const assert = require('assert');
const { validarDocumento } = require('./validador-schema');
const { colecoes, indices, jsonSchemaDe } = require('./schema');

class ObjectIdClasse {
  constructor(hex) {
    if (!/^[0-9a-f]{24}$/.test(hex)) throw new Error(`ObjectId inválido: ${hex}`);
    this.hex = hex;
    this._bsontype = 'ObjectId';
  }
  toString() {
    return this.hex;
  }
}

class ISODateClasse extends Date {
  constructor(texto) {
    super(texto);
    if (Number.isNaN(this.getTime())) throw new Error(`Data inválida: ${texto}`);
    this._bsontype = 'Date';
  }
}

function ObjectId(hex) {
  const gerado = hex === undefined ? [...Array(24)].map(() => Math.floor(Math.random() * 16).toString(16)).join('') : hex;
  return new ObjectIdClasse(gerado);
}

function ISODate(texto) {
  return new ISODateClasse(texto);
}

const PALAVRAS_PERMITIDAS = ['bsonType', 'enum', 'properties', 'required', 'additionalProperties', 'items', 'minItems', 'maxItems', 'minimum', 'maximum', 'exclusiveMinimum', 'exclusiveMaximum', 'minLength', 'maxLength', 'pattern', 'description', 'title'];
const TIPOS_BSON = ['objectId', 'string', 'number', 'bool', 'date', 'object', 'array', 'int', 'double', 'long', 'decimal', 'null'];

function conferirEsquemaComoMongo(esquema, caminho = '$jsonSchema') {
  for (const palavra of Object.keys(esquema)) {
    assert.ok(PALAVRAS_PERMITIDAS.includes(palavra), `${caminho}: palavra-chave não prevista: ${palavra}`);
  }
  if (esquema.required !== undefined) {
    assert.ok(Array.isArray(esquema.required) && esquema.required.length > 0, `${caminho}: $jsonSchema keyword 'required' cannot be an empty array`);
  }
  if (esquema.enum !== undefined) assert.ok(Array.isArray(esquema.enum) && esquema.enum.length > 0, `${caminho}: 'enum' não pode ser vazio`);
  if (esquema.exclusiveMinimum !== undefined) assert.ok(esquema.minimum !== undefined, `${caminho}: exclusiveMinimum exige minimum`);
  for (const tipo of [].concat(esquema.bsonType || [])) assert.ok(TIPOS_BSON.includes(tipo), `${caminho}: bsonType desconhecido: ${tipo}`);
  for (const [nome, sub] of Object.entries(esquema.properties || {})) conferirEsquemaComoMongo(sub, `${caminho}.${nome}`);
  if (esquema.items) conferirEsquemaComoMongo(esquema.items, `${caminho}[]`);
}

const banco = {};
const saida = [];

const existe = (nome) => Object.prototype.hasOwnProperty.call(banco, nome);
const valorEm = (doc, caminho) => caminho.split('.').reduce((v, k) => (v === undefined || v === null ? undefined : v[k]), doc);
const chaveUnica = (doc, campos) => campos.map((c) => String(valorEm(doc, c))).join('|');

function colecao(nome) {
  return {
    createIndex(chave, opcoes = {}) {
      if (!existe(nome)) throw new Error(`Coleção inexistente: ${nome}`);
      const c = banco[nome];
      const nomeIndice = opcoes.name || Object.keys(chave).join('_');
      const igual = c.indices.find((i) => i.name === nomeIndice);
      if (igual) {
        assert.deepStrictEqual(igual.chave, chave, `Índice ${nomeIndice} já existe com outra definição`);
        return nomeIndice;
      }
      c.indices.push({ name: nomeIndice, chave, unique: !!opcoes.unique });
      return nomeIndice;
    },
    getIndexes() {
      return [{ name: '_id_' }, ...banco[nome].indices.map((i) => ({ name: i.name, key: i.chave }))];
    },
    insertMany(documentos) {
      if (!existe(nome)) throw new Error(`Coleção ${nome} não foi criada com validação`);
      const c = banco[nome];
      for (const doc of documentos) {
        const erros = validarDocumento(doc, c.validador, nome);
        if (erros.length) throw new Error(`Document failed validation: ${erros.join('; ')}`);
        if (c.docs.some((d) => String(d._id) === String(doc._id))) throw new Error('E11000 duplicate key: _id');
        for (const indice of c.indices.filter((i) => i.unique)) {
          const campos = Object.keys(indice.chave);
          if (c.docs.some((d) => chaveUnica(d, campos) === chaveUnica(doc, campos))) throw new Error(`E11000 duplicate key: ${indice.name}`);
        }
        c.docs.push(doc);
      }
      return { insertedCount: documentos.length };
    },
    deleteMany(filtro) {
      const ids = new Set(filtro._id.$in.map(String));
      const c = banco[nome];
      const antes = c.docs.length;
      c.docs = c.docs.filter((d) => !ids.has(String(d._id)));
      return { deletedCount: antes - c.docs.length };
    },
    countDocuments() {
      return banco[nome].docs.length;
    },
  };
}

const bd = new Proxy(
  {
    getSiblingDB: () => bd,
    getCollectionInfos: ({ name }) => (existe(name) ? [{ name }] : []),
    createCollection(nome, opcoes) {
      if (existe(nome)) throw new Error(`NamespaceExists: ${nome}`);
      conferirEsquemaComoMongo(opcoes.validator.$jsonSchema);
      assert.strictEqual(opcoes.validationLevel, 'strict');
      assert.strictEqual(opcoes.validationAction, 'error');
      banco[nome] = { docs: [], indices: [], validador: opcoes.validator.$jsonSchema };
    },
    runCommand(comando) {
      assert.ok(existe(comando.collMod), `collMod em coleção inexistente: ${comando.collMod}`);
      conferirEsquemaComoMongo(comando.validator.$jsonSchema);
      banco[comando.collMod].validador = comando.validator.$jsonSchema;
      return { ok: 1 };
    },
    getCollection: (nome) => colecao(nome),
  },
  { get: (alvo, prop) => (prop in alvo ? alvo[prop] : typeof prop === 'string' ? colecao(prop) : undefined) }
);

const contexto = vm.createContext({ db: bd, ObjectId, ISODate, print: (t) => saida.push(String(t)), printjson: (v) => saida.push(JSON.stringify(v)) });
const pasta = path.join(__dirname, '..', 'mongo');
const gerados = ['01-colecoes.js', '02-indices.js', '03-dados-exemplo.js'];

function executar(arquivo) {
  vm.runInContext(fs.readFileSync(path.join(pasta, arquivo), 'utf8'), contexto, { filename: arquivo });
}

for (const rodada of [1, 2]) {
  for (const arquivo of gerados) executar(arquivo);
}

for (const nome of Object.keys(colecoes)) {
  assert.ok(existe(nome), `coleção ${nome} não criada`);
  assert.deepStrictEqual(JSON.parse(JSON.stringify(banco[nome].validador)), JSON.parse(JSON.stringify(jsonSchemaDe(nome))), `validador de ${nome} diverge do esquema`);
}

const esperados = { usuarios: 4, excedentes: 7, matches: 2, mensagens: 8 };
for (const [nome, total] of Object.entries(esperados)) assert.strictEqual(banco[nome].docs.length, total, `${nome}: contagem após reexecução`);

for (const [nome, lista] of Object.entries(indices)) {
  for (const i of lista) {
    const criado = banco[nome].indices.find((x) => x.name === i.opcoes.name);
    assert.ok(criado, `índice ${i.opcoes.name} não criado`);
    assert.strictEqual(criado.unique, !!i.opcoes.unique, `índice ${i.opcoes.name}: unicidade`);
    assert.strictEqual(JSON.stringify(criado.chave), JSON.stringify(i.chave), `índice ${i.opcoes.name}: chave criada difere da definida no esquema`);
    for (const [campo, tipo] of Object.entries(i.chave)) {
      let esquema = jsonSchemaDe(nome);
      for (const parte of campo.split('.')) {
        assert.ok(esquema.properties && esquema.properties[parte], `índice ${i.opcoes.name}: campo ${campo} não existe no esquema de ${nome}`);
        esquema = esquema.properties[parte];
      }
      if (tipo === '2dsphere') assert.strictEqual(esquema.properties.type.enum[0], 'Point', `${campo} deveria ser GeoJSON Point`);
    }
  }
}
const geoEmExcedentes = banco.excedentes.indices.filter((i) => Object.values(i.chave).includes('2dsphere'));
assert.strictEqual(geoEmExcedentes.length, 1, 'excedentes deve ter exatamente um índice 2dsphere');

const rejeitado = (colecaoNome, doc, mensagem) => assert.throws(() => bd[colecaoNome].insertMany([doc]), new RegExp('Document failed validation|E11000'), mensagem);

const exemploExcedente = (alteracoes) => ({ ...banco.excedentes.docs[0], _id: new ObjectId('b2ffffffffffffffffffffff'), ...alteracoes });
rejeitado('excedentes', exemploExcedente({ categoria: 'carnes' }), 'categoria inválida deveria ser rejeitada');
rejeitado('excedentes', exemploExcedente({ quantidade: 0 }), 'quantidade 0 deveria ser rejeitada');
rejeitado('excedentes', exemploExcedente({ campoExtra: 1 }), 'campo não previsto deveria ser rejeitado');
rejeitado('excedentes', exemploExcedente({ fotos: ['a', 'b', 'c', 'd'] }), 'mais de 3 fotos deveria ser rejeitado');
rejeitado('usuarios', { ...banco.usuarios.docs[0], _id: new ObjectId('a1ffffffffffffffffffffff') }, 'e-mail repetido deveria ser rejeitado');
rejeitado('matches', { ...banco.matches.docs[0], _id: new ObjectId('c3ffffffffffffffffffffff') }, 'par oferta/interessado repetido deveria ser rejeitado');
rejeitado('mensagens', { ...banco.mensagens.docs[0], _id: new ObjectId('d4ffffffffffffffffffffff'), texto: '' }, 'mensagem vazia deveria ser rejeitada');

const outros = fs.readdirSync(pasta).filter((f) => /^(0[4-9]|99)-.*\.js$/.test(f));
for (const arquivo of outros) {
  const codigo = fs.readFileSync(path.join(pasta, arquivo), 'utf8');
  assert.ok(codigo.includes('Autor: Henrique Leite de Camargo'), `${arquivo}: sem cabeçalho de autoria`);
  assert.ok(codigo.includes('(() => {'), `${arquivo}: deve estar dentro de uma função para não colidir com outros scripts`);
  new vm.Script(codigo, { filename: arquivo });
}

const orquestrador = path.join(pasta, '00-executar-tudo.js');
if (fs.existsSync(orquestrador)) {
  const carregados = [...fs.readFileSync(orquestrador, 'utf8').matchAll(/load\('([^']+)'\)/g)].map((m) => m[1]);
  assert.deepStrictEqual(carregados, gerados, '00-executar-tudo.js deve carregar os três scripts de criação, em ordem');
}

console.log(`testar-mongo.js: ok (${Object.keys(colecoes).length} coleções, ${Object.values(indices).flat().length} índices, scripts executados duas vezes sem erro, ${outros.length} scripts de apoio verificados)`);
