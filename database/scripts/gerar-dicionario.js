const fs = require('fs');
const path = require('path');
const { colecoes, colecoesFuturas } = require('./schema');

function linhas(campos, prefixo = '', faseHerdada = true) {
  const saida = [];
  for (const [nome, def] of Object.entries(campos)) {
    const mvp = faseHerdada && def.mvp !== false;
    const detalhes = [];
    if (def.valores) detalhes.push(def.valores.map((v) => `\`${v}\``).join(', '));
    if (def.regra) detalhes.push(def.regra);
    saida.push(`| \`${prefixo}${nome}\` | ${def.tipo} | ${def.obrigatorio ? 'Sim' : 'Não'} | ${detalhes.join('; ') || '—'} | ${def.desc} | ${mvp ? 'MVP' : 'Futuro'} |`);
    if (def.tipo === 'map' && def.campos) saida.push(...linhas(def.campos, `${prefixo}${nome}.`, mvp));
  }
  return saida;
}

const partes = [
  '# Dicionário de dados',
  '',
  'Gerado automaticamente a partir de `scripts/schema.js` (`npm run dicionario`). Não editar à mão: altere o esquema e gere novamente.',
  '',
  'Convenções: nomes de campos em camelCase, sem acentos; datas como `timestamp` do Firestore; coordenadas como `geopoint`. A coluna **Fase** indica se o campo é usado pelo MVP ou se pertence a uma funcionalidade futura.',
];

for (const def of Object.values(colecoes)) {
  partes.push('', `## \`${def.caminho}\``, '', def.desc, '', '| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |', '|---|---|---|---|---|---|', ...linhas(def.campos));
}

partes.push('', '## Coleções futuras (fora do MVP)', '', 'Ainda não existem no banco nem nas regras de segurança; ficam documentadas para a evolução do produto.', '', '| Caminho | Descrição | Campos previstos |', '|---|---|---|');
for (const f of colecoesFuturas) partes.push(`| \`${f.caminho}\` | ${f.desc} | ${f.campos} |`);

const destino = path.join(__dirname, '..', 'docs', '04-dicionario-de-dados.md');
fs.writeFileSync(destino, partes.join('\n') + '\n');
console.log('Gerado:', destino);
