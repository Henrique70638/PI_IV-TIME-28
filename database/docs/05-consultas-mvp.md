# 5. Consultas principais do MVP

Os exemplos usam o SDK web do Firebase (JavaScript, versão modular) e a biblioteca `geofire-common` para a busca por proximidade. No Flutter, as mesmas consultas existem no pacote `cloud_firestore` com `where`, `orderBy`, `startAt` e `endAt`; o cálculo das faixas de geohash exige um pacote de geohash para Dart (por exemplo, `geoflutterfire_plus`; confirmar a versão no pub.dev).

> Estes trechos ainda não foram executados contra um projeto Firebase. Devem ser testados com o emulador antes de entrar no aplicativo.

## 5.1 Busca por categoria e proximidade (Home / Busca / Filtros)

```js
import { collection, query, where, orderBy, startAt, endAt, getDocs } from 'firebase/firestore';
import { geohashQueryBounds, distanceBetween } from 'geofire-common';

async function buscarExcedentes(db, centro, raioKm, categoria) {
  const faixas = geohashQueryBounds(centro, raioKm * 1000);
  const respostas = await Promise.all(
    faixas.map(([inicio, fim]) => {
      const filtros = [where('status', '==', 'disponivel')];
      if (categoria) filtros.push(where('categoria', '==', categoria));
      return getDocs(query(collection(db, 'excedentes'), ...filtros, orderBy('localizacao.geohash'), startAt(inicio), endAt(fim)));
    })
  );
  return respostas
    .flatMap((r) => r.docs)
    .map((d) => {
      const g = d.get('localizacao.geoAproximada');
      return { id: d.id, ...d.data(), distanciaKm: distanceBetween([g.latitude, g.longitude], centro) };
    })
    .filter((e) => e.distanciaKm <= raioKm)
    .sort((a, b) => a.distanciaKm - b.distanciaKm);
}
```

`centro` é `[latitude, longitude]` lido de `usuarios/{uid}/privado/perfil`. As faixas de geohash devolvem alguns resultados fora do raio; o filtro por `distanciaKm` descarta esses casos. Para "todas as categorias", passe `categoria = null`.

Equivalente em Flutter (uma faixa):

```dart
final resposta = await FirebaseFirestore.instance
    .collection('excedentes')
    .where('status', isEqualTo: 'disponivel')
    .where('categoria', isEqualTo: categoria)
    .orderBy('localizacao.geohash')
    .startAt([inicio])
    .endAt([fim])
    .get();
```

## 5.2 Detalhe da oferta

```js
import { doc, getDoc } from 'firebase/firestore';

const oferta = await getDoc(doc(db, 'excedentes', excedenteId));
const ofertante = await getDoc(doc(db, 'usuarios', oferta.get('ofertanteId')));
```

## 5.3 Mecanismo de match: manifestar interesse

```js
import { doc, setDoc, serverTimestamp } from 'firebase/firestore';

async function manifestarInteresse(db, oferta, interessado, distanciaKm) {
  const matchId = `${oferta.id}_${interessado.uid}`;
  await setDoc(doc(db, 'matches', matchId), {
    excedenteId: oferta.id,
    ofertanteId: oferta.ofertanteId,
    interessadoId: interessado.uid,
    ofertanteNome: oferta.ofertanteNome,
    interessadoNome: interessado.nome,
    participantes: [oferta.ofertanteId, interessado.uid],
    status: 'conectado',
    criterios: { localizacao: true, categoria: true, distanciaKm: Number(distanciaKm.toFixed(1)) },
    excedenteResumo: {
      produto: oferta.produto,
      categoria: oferta.categoria,
      modalidade: oferta.modalidade,
      quantidade: oferta.quantidade,
      unidade: oferta.unidade,
    },
    criadoEm: serverTimestamp(),
    atualizadoEm: serverTimestamp(),
  });
  return matchId;
}
```

Se o match já existir, a escrita é recusada pelas regras (seria uma alteração de campos protegidos); nesse caso o aplicativo apenas abre a conversa existente.

## 5.4 Lista de conversas

```js
import { collection, query, where, orderBy, getDocs } from 'firebase/firestore';

const conversas = await getDocs(
  query(collection(db, 'matches'), where('participantes', 'array-contains', uid), orderBy('atualizadoEm', 'desc'))
);
```

## 5.5 Chat: ler e enviar mensagens

```js
import { collection, query, orderBy, onSnapshot, writeBatch, doc, serverTimestamp } from 'firebase/firestore';

const cancelar = onSnapshot(
  query(collection(db, 'matches', matchId, 'mensagens'), orderBy('criadoEm', 'asc')),
  (snapshot) => snapshot.docs.map((d) => ({ id: d.id, ...d.data() }))
);

async function enviarMensagem(db, matchId, autorId, texto) {
  const lote = writeBatch(db);
  lote.set(doc(collection(db, 'matches', matchId, 'mensagens')), { autorId, texto, criadoEm: serverTimestamp() });
  lote.update(doc(db, 'matches', matchId), {
    ultimaMensagem: { texto, autorId, criadoEm: serverTimestamp() },
    atualizadoEm: serverTimestamp(),
  });
  await lote.commit();
}
```

## 5.6 Concluir a negociação (somente o ofertante)

```js
import { writeBatch, doc, serverTimestamp } from 'firebase/firestore';

async function concluirNegociacao(db, matchId, excedenteId) {
  const lote = writeBatch(db);
  lote.update(doc(db, 'matches', matchId), { status: 'concluido', concluidoEm: serverTimestamp(), atualizadoEm: serverTimestamp() });
  lote.update(doc(db, 'excedentes', excedenteId), { status: 'concluido', atualizadoEm: serverTimestamp() });
  await lote.commit();
}
```

## 5.7 Meus excedentes

```js
import { collection, query, where, orderBy, getDocs } from 'firebase/firestore';

const meus = await getDocs(
  query(collection(db, 'excedentes'), where('ofertanteId', '==', uid), orderBy('criadoEm', 'desc'))
);
```

## 5.8 Indicadores do MVP

Os indicadores (excedentes cadastrados, matches gerados, negociações concluídas, taxa de conclusão e distância média) são calculados pelo script administrativo, que não passa pelas regras de segurança:

```
cd scripts
npm run metricas
```
