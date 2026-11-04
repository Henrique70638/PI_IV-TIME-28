# Banco de dados — CULT+ (PI IV, Time 28)

Banco de dados do CULT+, plataforma que conecta pessoas com excedentes de produtos cultivados em casa a pessoas interessadas em comprá-los ou recebê-los. O modelo cobre as funcionalidades do **MVP** definidas no relatório de ideação e usa **MongoDB** (hospedado no **MongoDB Atlas**), conforme o Plano de Ensino do PI IV.

Autor: Henrique Leite de Camargo (RA 25005997).

## Conteúdo

| Caminho | O que é |
|---|---|
| `docs/01-requisitos-de-dados.md` | Requisitos da disciplina, funcionalidades do MVP, dados necessários, indicadores e premissas |
| `docs/02-modelo-conceitual.md` | Modelo conceitual (DER), entidades, relacionamentos e regras de negócio |
| `docs/03-modelo-mongodb.md` | Coleções, decisões de modelagem (embutir ou referenciar), exemplos, índices e segurança |
| `docs/04-dicionario-de-dados.md` | Dicionário de dados (gerado a partir de `scripts/schema.js`) |
| `docs/05-consultas-e-desempenho.md` | Consultas do MVP, uso no servidor Java e medição de desempenho |
| `docs/06-atlas-passo-a-passo.md` | Como criar o cluster no Atlas, conectar com Compass e mongosh e reunir evidências |
| `docs/diagramas/` | DER em PNG e o código-fonte (`.dot`) |
| `mongo/` | Scripts do `mongosh`: coleções com validação, índices, dados de exemplo, consultas, fluxo do MVP, desempenho e métricas |
| `scripts/` | Esquema (fonte única), geradores, validação e testes locais (Node.js, sem dependências) |

## Como criar o banco no Atlas

Resumo (o passo a passo completo está em `docs/06-atlas-passo-a-passo.md`):

1. Crie o cluster M0 no Atlas, um usuário administrativo do banco (`readWrite` e `dbAdmin` em `cultmais`) e libere o seu IP.
2. Instale o `mongosh` e, na pasta `database\mongo`, execute com a sua string de conexão:

   ```
   mongosh "mongodb+srv://USUARIO:SENHA@NOME-DO-CLUSTER.mongodb.net/cultmais" --file 00-executar-tudo.js
   ```

3. Confira as coleções, os índices e a validação no MongoDB Compass.

Nunca coloque a string de conexão no repositório.

## Testes locais (sem Atlas)

Pré-requisito: Node.js 18 ou superior. Não há dependências para instalar.

```
cd database\scripts
npm test
```

O `npm test` executa três verificações:

- `geo.test.js`: cálculo de distância.
- `validar-dados.js`: dados de exemplo contra o esquema e consistência entre coleções (referências, nomes copiados, última mensagem, unicidade).
- `testar-mongo.js`: executa os scripts do `mongosh` contra um banco simulado, duas vezes seguidas, e confere validadores, índices, unicidade e rejeição de dados inválidos.

## Alterar o modelo

O esquema fica em `scripts/schema.js`. Depois de alterá-lo:

```
cd database\scripts
npm run gerar
npm test
```

O `gerar` reescreve `mongo/01-colecoes.js`, `mongo/02-indices.js`, `mongo/03-dados-exemplo.js` e `docs/04-dicionario-de-dados.md`. Esses arquivos são gerados; não os edite à mão.

## O que foi verificado e o que falta

Verificado (`npm test`):

- Dados de exemplo contra o esquema e consistência entre coleções.
- Scripts de criação executados duas vezes em um banco simulado, sem erro e sem colisão de nomes entre arquivos.
- Validadores gerados idênticos ao esquema; índices criados conforme o esquema; rejeição de dados inválidos e de duplicidade.
- Sintaxe dos demais scripts do `mongosh`.

Verificado no Atlas (cluster M0, MongoDB 8.0.36, AWS São Paulo, em 03/11/2026):

- Criação das coleções com validação, dos índices e dos dados de exemplo (`00-executar-tudo.js`).
- Consultas do MVP (`04-consultas-mvp.js`), com os resultados esperados e sem expor dados privados.
- Fluxo do MVP com escrita, bloqueio de duplicidade e de dados inválidos, e limpeza (`05-fluxo-mvp.js`).
- Desempenho com 20.000 ofertas sintéticas, com e sem índice (`06-desempenho.js`); resultados em `docs/05-consultas-e-desempenho.md`.
- Indicadores do MVP (`07-metricas.js`): 7 excedentes, 2 matches, 1 negociação concluída (50%) e distância média de 1,6 km.

Ainda não verificado:

- Os trechos em Java de `docs/05-consultas-e-desempenho.md`.

## Dados de exemplo

Os usuários, ofertas, matches e mensagens em `mongo/03-dados-exemplo.js` são **fictícios** e reproduzem a jornada das telas do protótipo (ex.: Manga Tommy, Roberto C.). Os e-mails usam o domínio reservado `example.com`, e o `senhaHash` de exemplo não corresponde a nenhuma senha.
