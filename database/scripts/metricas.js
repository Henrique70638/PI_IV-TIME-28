/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const { db, destino } = require('./conexao');
const { CATEGORIAS, PERFIS } = require('./schema');

const contar = async (consulta) => (await consulta.count().get()).data().count;

async function main() {
  console.log(`Métricas do MVP — ${destino}\n`);

  const usuarios = db.collection('usuarios');
  const excedentes = db.collection('excedentes');
  const matches = db.collection('matches');

  console.log('Usuários por perfil');
  for (const perfil of PERFIS) console.log(`  ${perfil}: ${await contar(usuarios.where('perfil', '==', perfil))}`);

  const totalExcedentes = await contar(excedentes);
  console.log(`\nExcedentes cadastrados: ${totalExcedentes}`);
  for (const categoria of CATEGORIAS) console.log(`  ${categoria}: ${await contar(excedentes.where('categoria', '==', categoria))}`);

  const totalMatches = await contar(matches);
  const concluidos = await contar(matches.where('status', '==', 'concluido'));
  console.log(`\nMatches gerados: ${totalMatches}`);
  console.log(`Negociações concluídas: ${concluidos}`);
  if (totalMatches > 0) console.log(`Taxa de conclusão: ${((concluidos / totalMatches) * 100).toFixed(0)}%`);

  const lista = await matches.get();
  const distancias = lista.docs.map((d) => d.get('criterios.distanciaKm')).filter((n) => typeof n === 'number');
  if (distancias.length) console.log(`Distância média dos matches: ${(distancias.reduce((a, b) => a + b, 0) / distancias.length).toFixed(1)} km`);
}

main().catch((e) => {
  console.error('Falha ao consultar:', e.message);
  process.exit(1);
});
