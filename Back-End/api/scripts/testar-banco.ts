/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { MongoClient } from 'mongodb';
import 'dotenv/config';

// indices que cada colecao precisa ter (criados por database/mongo/02-indices.js)
const ESPERADOS: Record<string, string[]> = {
  usuarios: ['email_unico'],
  excedentes: ['geo_status_categoria', 'ofertante_recentes'],
  matches: ['match_unico', 'conversas_do_usuario'],
  mensagens: ['mensagens_do_match'],
};

// confere conexao, colecoes, indices, validacao do schema e busca geografica;
// sai com codigo 1 se algo falhar. Rodar com: npm run testar:banco
async function main() {
  const uri = process.env.MONGODB_URI;
  const nomeBanco = process.env.MONGO_BANCO ?? 'cultmais';
  if (!uri) throw new Error('MONGODB_URI não definida no .env');

  const cliente = new MongoClient(uri, { serverSelectionTimeoutMS: 8000 });
  let falhas = 0;
  const ok = (m: string) => console.log(`OK    ${m}`);
  const erro = (m: string) => {
    falhas++;
    console.log(`FALHA ${m}`);
  };

  try {
    await cliente.connect();
    const banco = cliente.db(nomeBanco);
    await banco.command({ ping: 1 });
    ok(`conectou e respondeu ao ping (banco ${nomeBanco})`);

    for (const [nome, indices] of Object.entries(ESPERADOS)) {
      const existe = await banco.listCollections({ name: nome }).hasNext();
      if (!existe) {
        erro(`coleção ${nome} não existe`);
        continue;
      }
      const total = await banco.collection(nome).countDocuments();
      ok(`coleção ${nome}: ${total} documentos`);
      const atuais = (await banco.collection(nome).indexes()).map((i) => i.name);
      for (const indice of indices) {
        atuais.includes(indice) ? ok(`índice ${nome}.${indice}`) : erro(`índice ${nome}.${indice} ausente`);
      }
    }

    // teste de escrita: usa um e-mail unico e apaga o que criou no final
    const usuarios = banco.collection('usuarios');
    const email = `teste-conexao-${Date.now()}@cultmais.test`;
    const base = {
      nome: 'Teste Conexao',
      email,
      senhaHash: '$2b$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ01234',
      perfil: 'ambos',
      bairro: 'Centro',
      cidade: 'Campinas',
      localizacao: { type: 'Point', coordinates: [-47.0608, -22.9056] },
      criadoEm: new Date(),
    };
    try {
      await usuarios.insertOne({ ...base });
      ok('inserção em usuarios aceita pela validação');
      await usuarios.insertOne({ ...base }).then(
        () => erro('e-mail duplicado foi aceito'),
        (e) => (e.code === 11000 ? ok('e-mail duplicado rejeitado (11000)') : erro(`erro inesperado: ${e.message}`)),
      );
      await usuarios.insertOne({ ...base, email: `x-${email}`, campoExtra: 1 }).then(
        () => erro('campo extra foi aceito'),
        (e) => (e.code === 121 ? ok('campo extra rejeitado pelo $jsonSchema (121)') : erro(`erro inesperado: ${e.message}`)),
      );
    } finally {
      await usuarios.deleteMany({ email: { $in: [email, `x-${email}`] } });
      ok('usuário de teste removido');
    }

    // busca por proximidade: ofertas disponiveis a ate 5 km do centro de Campinas
    const perto = await banco
      .collection('excedentes')
      .aggregate([
        {
          $geoNear: {
            near: { type: 'Point', coordinates: [-47.0608, -22.9056] },
            distanceField: 'distanciaM',
            maxDistance: 5000,
            query: { status: 'disponivel' },
            spherical: true,
          },
        },
        { $limit: 3 },
      ])
      .toArray();
    ok(`$geoNear em excedentes retornou ${perto.length} documento(s)`);
  } catch (e) {
    erro((e as Error).message);
  } finally {
    await cliente.close();
  }

  console.log(falhas === 0 ? '\nTudo certo.' : `\n${falhas} problema(s) encontrado(s).`);
  process.exit(falhas === 0 ? 0 : 1);
}

main();
