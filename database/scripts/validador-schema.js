/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

function tipoBson(v) {
  if (v === null) return 'null';
  if (Array.isArray(v)) return 'array';
  if (v instanceof Date) return 'date';
  switch (typeof v) {
    case 'string': return 'string';
    case 'boolean': return 'bool';
    case 'number': return 'number';
    case 'object':
      if (v.$oid !== undefined || v._bsontype === 'ObjectId') return 'objectId';
      if (v.$date !== undefined || v._bsontype === 'Date') return 'date';
      return 'object';
    default: return 'desconhecido';
  }
}

function bateTipo(esperado, real) {
  return esperado === real || ((esperado === 'int' || esperado === 'double') && real === 'number');
}

function validar(valor, esquema, caminho, erros) {
  const real = tipoBson(valor);
  if (esquema.bsonType) {
    const aceitos = Array.isArray(esquema.bsonType) ? esquema.bsonType : [esquema.bsonType];
    if (!aceitos.some((t) => bateTipo(t, real))) {
      erros.push(`${caminho}: esperado ${aceitos.join('|')}, recebido ${real}`);
      return;
    }
  }
  if (esquema.enum && !esquema.enum.includes(valor)) erros.push(`${caminho}: valor "${valor}" fora da lista`);

  if (real === 'string') {
    if (esquema.minLength !== undefined && [...valor].length < esquema.minLength) erros.push(`${caminho}: texto curto demais`);
    if (esquema.maxLength !== undefined && [...valor].length > esquema.maxLength) erros.push(`${caminho}: texto longo demais`);
    if (esquema.pattern && !new RegExp(esquema.pattern).test(valor)) erros.push(`${caminho}: formato inválido`);
  }

  if (real === 'number') {
    if (esquema.minimum !== undefined) {
      const abaixo = esquema.exclusiveMinimum ? valor <= esquema.minimum : valor < esquema.minimum;
      if (abaixo) erros.push(`${caminho}: abaixo do mínimo`);
    }
    if (esquema.maximum !== undefined && valor > esquema.maximum) erros.push(`${caminho}: acima do máximo`);
  }

  if (real === 'array') {
    if (esquema.minItems !== undefined && valor.length < esquema.minItems) erros.push(`${caminho}: itens de menos`);
    if (esquema.maxItems !== undefined && valor.length > esquema.maxItems) erros.push(`${caminho}: itens demais`);
    if (esquema.items) valor.forEach((item, i) => validar(item, esquema.items, `${caminho}[${i}]`, erros));
  }

  if (real === 'object') {
    for (const obrigatorio of esquema.required || []) {
      if (valor[obrigatorio] === undefined) erros.push(`${caminho}.${obrigatorio}: campo obrigatório ausente`);
    }
    const props = esquema.properties || {};
    for (const chave of Object.keys(valor)) {
      if (props[chave]) validar(valor[chave], props[chave], `${caminho}.${chave}`, erros);
      else if (esquema.additionalProperties === false) erros.push(`${caminho}.${chave}: campo não previsto`);
    }
  }
}

function validarDocumento(doc, esquema, nome = 'doc') {
  const erros = [];
  validar(doc, esquema, nome, erros);
  return erros;
}

module.exports = { validarDocumento, tipoBson };
