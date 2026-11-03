# Banco de dados — CULT+ (PI IV, Time 28)

Banco de dados do CULT+, plataforma que conecta pessoas com excedentes de produtos cultivados em casa a pessoas interessadas em comprá-los ou recebê-los. O modelo cobre as funcionalidades do **MVP** definidas no relatório de ideação e usa **Cloud Firestore** (Firebase), conforme a stack proposta na seção 3.2.3 do relatório.

## Conteúdo

| Caminho | O que é |
|---|---|
| `docs/01-requisitos-de-dados.md` | Funcionalidades do MVP, dados necessários, indicadores e premissas |
| `docs/02-modelo-conceitual.md` | Modelo conceitual (DER), entidades, relacionamentos e regras de negócio |
| `docs/03-modelo-firestore.md` | Estrutura das coleções, exemplos, decisões de modelagem, segurança e índices |
| `docs/04-dicionario-de-dados.md` | Dicionário de dados (gerado a partir de `scripts/schema.js`) |
| `docs/05-consultas-mvp.md` | Consultas principais do MVP |
| `docs/diagramas/` | DER em PNG e o código-fonte (`.dot`) |
| `firestore/firestore.rules` | Regras de segurança |
| `firestore/firestore.indexes.json` | Índices compostos |
| `firebase.json` | Configuração do Firebase CLI e do emulador |
| `scripts/` | Esquema, dados de exemplo, validação, carga (seed), métricas e testes das regras |

## Como executar (Windows, PowerShell)

Pré-requisitos: Node.js 18 ou superior, Java 21 ou superior (exigido pelo emulador) e o Firebase CLI (`npm install -g firebase-tools`).

1. Instalar as dependências e rodar os testes locais:

   ```
   cd database/scripts
   npm install
   npm test
   ```

2. Em outro terminal, iniciar o emulador do Firestore (a partir da pasta `database`):

   ```
   firebase emulators:start --only firestore --project cult-mais-dev
   ```

   O painel do emulador abre em http://localhost:4000.

3. Gravar os dados de exemplo no emulador e consultar as métricas:

   ```
   npm run seed
   npm run metricas
   ```

4. Testar as regras de segurança (com o emulador ligado). Os testes apagam os dados do emulador; rode `npm run seed` depois para recarregá-los:

   ```
   node --test regras.test.js
   ```

5. Regerar o dicionário de dados depois de alterar `scripts/schema.js`:

   ```
   npm run dicionario
   ```

Os scripts gravam no **emulador** por padrão. Para usar um projeto Firebase real, defina a variável `GOOGLE_APPLICATION_CREDENTIALS` com o caminho da chave de serviço e use `npm run seed:real` ou `npm run metricas:real`. Nunca versione a chave de serviço (o `.gitignore` já a ignora).

Publicar regras e índices em um projeto real:

```
firebase login
firebase use <id-do-projeto>
firebase deploy --only firestore:rules,firestore:indexes
```

## O que foi verificado e o que falta

Verificado:

- Cálculo de geohash e de distância, contra valores de referência (`npm test`).
- Dados de exemplo contra o esquema: tipos, campos obrigatórios, valores permitidos, referências entre coleções e coerência das cópias desnormalizadas (`npm test`).
- Carga dos dados (`npm run seed`, 25 documentos) e cálculo das métricas (`npm run metricas`) no emulador do Firestore.
- Regras de segurança: 35 testes automatizados no emulador (`node --test regras.test.js`), cobrindo leitura e escrita de usuários, ofertas, matches e mensagens, e o bloqueio de coleções não previstas.

Ainda não verificado:

- Publicação das regras e dos índices em um projeto Firebase real (`firebase deploy`).
- Consultas do documento `docs/05-consultas-mvp.md` em um aplicativo. Os índices compostos só são exigidos pelo Firestore de produção, então a busca por proximidade deve ser testada lá.

## Dados de exemplo

Os usuários, ofertas, matches e mensagens em `scripts/dados-exemplo.js` são **fictícios** e reproduzem a jornada mostrada nas telas do protótipo (ex.: Manga Tommy, Roberto C.).
