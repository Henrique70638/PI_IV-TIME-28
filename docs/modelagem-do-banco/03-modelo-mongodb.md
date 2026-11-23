# 3. Modelo de dados no MongoDB

O MongoDB é um banco orientado a documentos. Em vez de normalizar tudo em tabelas ligadas por chaves estrangeiras, o modelo decide, para cada relação, se os dados ficam **embutidos** no mesmo documento ou **referenciados** por `ObjectId`. A regra usada aqui: embutir o que é sempre lido junto e tem tamanho limitado; referenciar o que cresce sem limite ou é compartilhado.

## 3.1 Estrutura

Banco `cultmais`, com quatro coleções:

```
usuarios      pessoas e seus dados de acesso
excedentes    ofertas (localização embutida, ofertante como referência estendida)
matches       conexão entre oferta e interessado (também é a conversa)
mensagens     mensagens do chat, uma coleção própria
```

Coleções futuras (fora do MVP): `avaliacoes` e `notificacoes`. Os campos de cada coleção estão no dicionário de dados (documento 04).

## 3.2 Decisões de modelagem

| Decisão | Motivo |
|---|---|
| `excedentes.localizacao` **embutida** (bairro, cidade e ponto) | É sempre lida junto com a oferta, tem tamanho fixo e não é compartilhada. |
| `excedentes.ofertante` como **referência estendida** (`_id` e `nome`) | A listagem mostra o nome do ofertante em todo cartão. Copiar o nome evita um `$lookup` por oferta. Custo: se o usuário mudar de nome, as cópias precisam ser atualizadas (evento raro). |
| `matches` **referencia** oferta, ofertante e interessado por `ObjectId` | Esses dados continuam existindo e mudando fora do match. |
| `matches.excedenteResumo` **embutido** (cópia dos dados da oferta no momento do match) | O cabeçalho do chat precisa do produto e da modalidade sem consultar `excedentes`; registra também o que foi combinado. |
| `matches.criterios` **embutido** | Guarda por que o match aconteceu (localização, categoria, distância) e permite avaliar as hipóteses do MVP. Novos critérios entram como novos campos. |
| `mensagens` em **coleção própria**, e não como array dentro do match | Uma conversa pode crescer sem limite. Um array ilimitado dentro de um documento arrisca o teto de 16 MB por documento e degrada a escrita. A coleção própria permite paginar e usar índice. |
| `matches.ultimaMensagem` embutida | A lista de conversas mostra a última mensagem sem consultar `mensagens`. |
| `matches.participantes` (array com os dois usuários) | A consulta "minhas conversas" usa um único índice multikey, sem `$or`. |
| Localização como **GeoJSON Point** `[longitude, latitude]` com índice `2dsphere` | Permite buscar por proximidade e ordenar por distância no próprio banco. Dispensa técnicas como geohash. |
| Coordenadas **aproximadas** na oferta (3 casas decimais, cerca de 100 m) | Protege o endereço do ofertante. A precisão basta para calcular distância em km. |
| Sem exclusão física | Ofertas usam `status = "removido"`; o histórico é preservado para as métricas. |
| Validação com `$jsonSchema` no próprio banco | Garante tipos, campos obrigatórios, valores permitidos e ausência de campos não previstos, mesmo que o servidor tenha um erro. |
| `_id` como `ObjectId` | Padrão do MongoDB; gerado pelo servidor ou pelo banco. |

## 3.3 Telas do protótipo e as coleções usadas

| Tela | Lê | Grava |
|---|---|---|
| Cadastro / Login | `usuarios` | `usuarios` |
| Home / Busca (com filtros) | `excedentes` (por categoria e proximidade), `usuarios` (localização do usuário) | — |
| Cadastro de Excedente | `usuarios` | `excedentes` |
| Detalhe da Oferta | `excedentes`, `usuarios` | — |
| Mecanismo de Match | `excedentes`, `usuarios` | `matches` ao tocar em "Tenho interesse" |
| Conexão / Match Confirmado | `matches` | — |
| Chat | `matches`, `mensagens` | `mensagens`, `matches` (última mensagem) |
| Perfil | `usuarios` | `usuarios` |

## 3.4 Exemplos de documentos

Oferta (`excedentes`):

```js
{
  _id: ObjectId("b20000000000000000000001"),
  ofertante: { _id: ObjectId("a10000000000000000000001"), nome: "Roberto C." },
  produto: "Manga Tommy",
  descricao: "Mangas colhidas hoje, quintal com sombra parcial. Ideal para consumo imediato ou doces caseiros.",
  categoria: "frutas",
  quantidade: 5,
  unidade: "kg",
  urgencia: "alguns_dias",
  modalidade: "doacao",
  localizacao: {
    bairro: "Jardim das Flores",
    cidade: "Campinas",
    ponto: { type: "Point", coordinates: [-47.065, -22.921] }
  },
  fotos: ["excedentes/1/1.jpg"],
  status: "disponivel",
  criadoEm: ISODate("2026-10-29T11:00:00.000Z"),
  atualizadoEm: ISODate("2026-10-29T11:00:00.000Z")
}
```

Match (`matches`):

```js
{
  _id: ObjectId("c30000000000000000000001"),
  excedenteId: ObjectId("b20000000000000000000001"),
  ofertanteId: ObjectId("a10000000000000000000001"),
  interessadoId: ObjectId("a10000000000000000000002"),
  ofertanteNome: "Roberto C.",
  interessadoNome: "Marina S.",
  participantes: [ObjectId("a10000000000000000000001"), ObjectId("a10000000000000000000002")],
  status: "conectado",
  criterios: { localizacao: true, categoria: true, distanciaKm: 1.2 },
  excedenteResumo: { produto: "Manga Tommy", categoria: "frutas", modalidade: "doacao", quantidade: 5, unidade: "kg" },
  ultimaMensagem: { texto: "Combinado, obrigado! 🙌", autorId: ObjectId("a10000000000000000000002"), criadoEm: ISODate("2026-10-29T12:41:00.000Z") },
  criadoEm: ISODate("2026-10-29T12:37:00.000Z"),
  atualizadoEm: ISODate("2026-10-29T12:41:00.000Z")
}
```

Os dados de exemplo completos (fictícios) estão em `mongo/03-dados-exemplo.js`.

## 3.5 Índices

| Coleção | Índice | Atende |
|---|---|---|
| `usuarios` | `{ email: 1 }` único | Login e unicidade do e-mail |
| `excedentes` | `{ "localizacao.ponto": "2dsphere", status: 1, categoria: 1 }` | Busca por proximidade com filtro de status e categoria (Home/Busca e Filtros) |
| `excedentes` | `{ "ofertante._id": 1, criadoEm: -1 }` | "Meus excedentes" |
| `matches` | `{ excedenteId: 1, interessadoId: 1 }` único | Impede match duplicado |
| `matches` | `{ participantes: 1, atualizadoEm: -1 }` | Lista de conversas do usuário |
| `mensagens` | `{ matchId: 1, criadoEm: 1 }` | Leitura do chat em ordem cronológica |

O índice geográfico é composto, com `status` e `categoria` depois do campo geoespacial, para que um único índice sirva tanto a busca "todas as categorias" quanto a busca filtrada por categoria. A coleção `excedentes` tem exatamente um índice `2dsphere`, o que evita ambiguidade no `$geoNear`. A medição do efeito dos índices está no documento 05.

## 3.6 Segurança

| Camada | Medida |
|---|---|
| Acesso ao banco | Somente o servidor Java acessa o MongoDB. O aplicativo conversa com o servidor. |
| Usuários do banco | Dois usuários restritos ao banco `cultmais`: um de **aplicação** (`readWrite`), usado pelo servidor Java, e um **administrativo** (`readWrite` e `dbAdmin`), usado só para executar os scripts de criação, porque atualizar validadores (`collMod`) exige `dbAdmin`. Nenhum dos dois é o administrador do cluster. |
| Rede | Lista de IPs do Atlas restrita aos endereços usados pelo grupo (liberar "qualquer lugar" só temporariamente, em desenvolvimento). |
| Credenciais | A string de conexão fica em variável de ambiente e nunca vai para o repositório. |
| Senhas | Guardadas apenas como hash BCrypt (`senhaHash`). |
| Dados privados | `email`, `senhaHash` e `usuarios.localizacao` não devem ser devolvidos pela API a outros usuários (usar projeção nas consultas). |
| Integridade | `$jsonSchema` com `validationLevel: "strict"` e `validationAction: "error"`, e índices únicos. |

## 3.7 Limitações e próximos passos

- Duas operações envolvem mais de um documento: enviar mensagem (insere em `mensagens` e atualiza `matches.ultimaMensagem`) e concluir negociação (atualiza `matches` e `excedentes`). O Atlas suporta transações multidocumento; o servidor Java deve usá-las para garantir atomicidade. Nos scripts de demonstração as duas escritas são feitas em sequência, sem transação.
- As cópias desnormalizadas (`ofertante.nome`, `ofertanteNome`, `interessadoNome`, `excedenteResumo`, `ultimaMensagem`) são mantidas pelo servidor.
- Se o grupo validar quantidade, urgência ou preferências como critérios de match, basta acrescentá-los em `matches.criterios` e, se necessário, no índice.
- O comportamento real das consultas e dos planos de execução precisa ser conferido no Atlas (documentos 05 e 06).
