# 5. Consultas, uso no servidor Java e desempenho

> Os scripts `00` a `06` do `mongosh` foram executados no MongoDB Atlas (cluster M0, MongoDB 8.0.36, AWS São Paulo) em 03/11/2026, com os resultados descritos neste documento. Os trechos em Java ainda não foram executados.

## 5.1 Consultas do MVP (mongosh)

O arquivo `mongo/04-consultas-mvp.js` executa seis consultas sobre os dados de exemplo:

| # | Consulta | Tela |
|---|---|---|
| 1 | Busca por proximidade e categoria com `$geoNear` (frutas até 5 km), com a distância calculada pelo banco | Home / Busca com filtros |
| 2 | Busca por proximidade, todas as categorias | Home / Busca |
| 3 | Detalhe da oferta com `$lookup` em `usuarios`, projetando só dados públicos do ofertante | Detalhe da Oferta |
| 4 | Lista de conversas do usuário, da mais recente para a mais antiga | Conversas |
| 5 | Mensagens do chat em ordem cronológica | Chat |
| 6 | "Meus excedentes" | Perfil / Publicar |

O arquivo `mongo/05-fluxo-mvp.js` percorre o fluxo principal com escrita: cria o match (distância calculada), envia uma mensagem, mostra o bloqueio de match duplicado e de dados inválidos, conclui a negociação e, no final, remove o que criou e devolve a oferta ao estado original.

O arquivo `mongo/07-metricas.js` calcula os indicadores do MVP (excedentes por categoria, matches, negociações concluídas, taxa de conclusão e distância média).

Consulta central, a busca por proximidade:

```js
db.excedentes.aggregate([
  {
    $geoNear: {
      near: { type: "Point", coordinates: [-47.065, -22.91] },
      distanceField: "distanciaM",
      maxDistance: 5000,
      spherical: true,
      query: { status: "disponivel", categoria: "frutas" }
    }
  },
  { $addFields: { distanciaKm: { $round: [{ $divide: ["$distanciaM", 1000] }, 1] } } }
])
```

## 5.2 Uso no servidor Java

O servidor usa o driver oficial `org.mongodb:mongodb-driver-sync` (usar a versão estável mais recente). A string de conexão vem de variável de ambiente.

Importações usadas nos trechos abaixo:

```java
import com.mongodb.ErrorCategory;
import com.mongodb.MongoWriteException;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import com.mongodb.client.model.geojson.Point;
import com.mongodb.client.model.geojson.Position;
import org.bson.Document;
import org.bson.conversions.Bson;
import java.util.ArrayList;
import java.util.List;
```

Conexão e busca por proximidade (ordenada pela distância). `raioKm`, `longitude` e `latitude` devem ser `double`:

```java
MongoClient cliente = MongoClients.create(System.getenv("MONGODB_URI"));
MongoCollection<Document> excedentes = cliente.getDatabase("cultmais").getCollection("excedentes");

Point centro = new Point(new Position(longitude, latitude));
Bson filtro = Filters.and(
    Filters.eq("status", "disponivel"),
    Filters.eq("categoria", categoria),
    Filters.nearSphere("localizacao.ponto", centro, raioKm * 1000, null));

List<Document> resultado = excedentes.find(filtro).limit(50).into(new ArrayList<>());
```

Esse `find` devolve as ofertas da mais próxima para a mais distante, mas sem o valor da distância; o servidor pode calcular a distância em km a partir das coordenadas (fórmula de Haversine) ou usar a etapa `$geoNear` em um `aggregate`.

Criação do match, tratando a duplicidade:

```java
MongoCollection<Document> matches = cliente.getDatabase("cultmais").getCollection("matches");
try {
    matches.insertOne(documentoDoMatch);
} catch (MongoWriteException e) {
    if (e.getError().getCategory() == ErrorCategory.DUPLICATE_KEY) {
        // o interessado já tem match nesta oferta: abrir a conversa existente
    } else {
        throw e;
    }
}
```

Lista de conversas do usuário:

```java
List<Document> conversas = matches
    .find(Filters.eq("participantes", usuarioId))
    .sort(Sorts.descending("atualizadoEm"))
    .into(new ArrayList<>());
```

Para os testes com JUnit exigidos pela disciplina, use um banco de testes separado (por exemplo `cultmais_teste`) e limpe as coleções entre os testes.

## 5.3 Desempenho

O arquivo `mongo/06-desempenho.js` insere 20.000 ofertas sintéticas (marcadas com `ofertante.nome = "SINTETICO"`), compara cada consulta com e sem índice usando `explain("executionStats")` e remove os dados sintéticos no final:

| Teste | Comparação |
|---|---|
| A e B | Busca por proximidade e categoria: com o índice `geo_status_categoria` e sem índice (`hint({ $natural: 1 })`) |
| C | `$geoNear` usado pelo servidor, com o índice |
| D e E | "Meus excedentes": com o índice `ofertante_recentes` e sem índice |

Como interpretar a saída:

- **Etapas do plano**: `IXSCAN` significa que o índice foi usado; `COLLSCAN` é a varredura da coleção inteira.
- **Documentos examinados**: com índice, deve ser próximo de **documentos retornados**; sem índice, é o total da coleção.
- **Tempo**: o tempo de execução em milissegundos.

## 5.4 Resultado medido no Atlas

Execução de `mongo/06-desempenho.js` em 03/11/2026, no cluster M0 (MongoDB 8.0.36, AWS São Paulo). A coleção `excedentes` tinha 20.007 documentos (20.000 sintéticos de 200 ofertantes, espalhados em torno de Campinas, mais os 7 de exemplo). A busca usou raio de 5 km e categoria `frutas`.

| Teste | Plano de execução | Documentos examinados | Documentos retornados | Tempo |
|---|---|---|---|---|
| A. Proximidade e categoria, com índice | `FETCH > IXSCAN` (`geo_status_categoria`) | 625 | 441 | 8 ms |
| B. Mesma busca, sem índice | `COLLSCAN` | 20.007 | 441 | 27 ms |
| C. `$geoNear` (consulta do servidor) | `GEO_NEAR_2DSPHERE > FETCH > IXSCAN` | 648 | 441 | 13 ms |
| D. "Meus excedentes", com índice | `FETCH > IXSCAN` (`ofertante_recentes`) | 100 | 100 | 0 ms |
| E. "Meus excedentes", sem índice | `SORT > COLLSCAN` | 20.007 | 100 | 72 ms |

Leitura dos resultados:

- Com o índice geoespacial composto, a busca por proximidade examinou 625 documentos em vez de 20.007, cerca de 3% da coleção (32 vezes menos), devolvendo o mesmo resultado.
- Com o índice `ofertante_recentes`, "meus excedentes" examinou 100 documentos em vez de 20.007 (200 vezes menos) e dispensou a etapa de ordenação em memória (`SORT`), porque o índice já entrega os documentos ordenados por `criadoEm`.
- O `$geoNear`, que devolve as ofertas ordenadas pela distância, também usa o índice geoespacial.

Ressalvas: foi uma única execução, em cluster gratuito compartilhado, e os tempos em milissegundos variam entre execuções; o número de documentos examinados é a medida mais estável. Os dados sintéticos são removidos no final do script.

Para repetir a medição, execute `mongo/06-desempenho.js` e, se quiser, confira os mesmos planos na aba **Explain Plan** do MongoDB Compass.
