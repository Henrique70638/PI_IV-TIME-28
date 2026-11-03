const { db, Timestamp, GeoPoint, destino } = require('./conexao');
const { colecoes } = require('./schema');
const dados = require('./dados-exemplo');

function converter(campos, doc) {
  const saida = {};
  for (const [nome, valor] of Object.entries(doc)) {
    const def = campos[nome];
    if (def.tipo === 'timestamp') saida[nome] = Timestamp.fromDate(new Date(valor));
    else if (def.tipo === 'geopoint') saida[nome] = new GeoPoint(valor.lat, valor.lng);
    else if (def.tipo === 'map' && def.campos) saida[nome] = converter(def.campos, valor);
    else saida[nome] = valor;
  }
  return saida;
}

async function main() {
  const batch = db.batch();
  let escritas = 0;
  const gravar = (caminho, campos, doc) => {
    batch.set(db.doc(caminho), converter(campos, doc));
    escritas++;
  };

  for (const u of dados.usuarios) {
    gravar(`usuarios/${u.id}`, colecoes.usuarios.campos, u.publico);
    gravar(`usuarios/${u.id}/privado/perfil`, colecoes['usuarios/{uid}/privado'].campos, u.privado);
  }
  for (const { id, ...doc } of dados.excedentes) {
    gravar(`excedentes/${id}`, colecoes.excedentes.campos, doc);
  }
  for (const { id, mensagens, ...doc } of dados.matches) {
    gravar(`matches/${id}`, colecoes.matches.campos, doc);
    for (const { id: mid, ...msg } of mensagens) {
      gravar(`matches/${id}/mensagens/${mid}`, colecoes['matches/{matchId}/mensagens'].campos, msg);
    }
  }

  await batch.commit();
  console.log(`seed.js: ${escritas} documentos gravados em ${destino}`);
}

main().catch((e) => {
  console.error('Falha ao gravar:', e.message);
  process.exit(1);
});
