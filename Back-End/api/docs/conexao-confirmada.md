# Conexão confirmada — Backend CULT+

Implementação: Rafaela Jacobsen Braga — RA 25004280.

## Endpoints preparados

- `POST /api/conexao/matches` — solicita conexão com uma oferta. Corpo: `{ "excedenteId": "<24 hex>", "raioKm": 5, "categoria": "frutas" }`. O `raioKm` e a `categoria` são opcionais. Retorna `201` com `{ "conexao": {...} }`.
- `GET /api/conexao/matches/:matchId` — lê a confirmação apenas se o usuário autenticado participa do match. Retorna `{ "conexao": {...} }`.
- `GET /api/conexao/status` — rota preexistente, preservada.

**Autenticação atual:** o middleware `lerToken` do grupo já está registrado em `src/app.ts` e preenche `res.locals.usuarioId` somente após validar o JWT. As rotas retornam `401` sem sessão válida. **Não** preencher `res.locals.usuarioId` diretamente com `req.body`, `req.query` ou um header sem verificação. O `interessadoId` é sempre derivado da identidade autenticada e nunca aceito no JSON.

## Regras

- `excedenteId` deve ser ObjectId hexadecimal válido; raio permitido entre 0,1 e 50 km.
- Interessado deve existir e ter perfil `interessado` ou `ambos`.
- Oferta deve existir, estar `disponivel` e pertencer a outro usuário.
- Calcula a distância entre o usuário e a localização aproximada da oferta; recusa fora do raio.
- Confere categoria selecionada, quando informada.
- Impede duplicidade de match por usuário + oferta (incluindo corrida com índice único `match_unico`).
- Salva somente os campos previstos no validador MongoDB do projeto.
- Nas respostas, não expõe e-mail, senhaHash ou coordenadas. O GET não revela detalhes a quem não participa.
- Não altera a oferta para `concluido` ao criar interesse. Não envia notificações nem mensagens: essas integrações ainda dependem dos módulos do grupo.

## Testar localmente

Na pasta `Back-End/api`:

```bash
npm ci
npm run build
node --import tsx --test tests/conexao.test.ts
```

Esses testes não fazem escrita no banco: utilizam um repositório de teste. Para testar com MongoDB real, usar base de testes autorizada e dados de exemplo do grupo, com índices de `database/mongo/02-indices.js`. Verificar erros `401`, `400`, `403`, `404`, `409`, `422` e `503`, além do caso `201`. Não testar gravações na base de produção sem autorização.

**Integração candidata para revisão:** tela Inicial envia JWT e lê excedentes da API ao receber sessão autenticada; o botão de interesse chama a rota de criação, e a tela de confirmação recebe o resultado retornado. Ainda faltam testes de ponta a ponta com MongoDB, índices geoespaciais e de unicidade presentes, além da integração do chat pelo responsável. O cadastro atual usa coordenadas padrão de Campinas quando o usuário não fornece localização geográfica; essas coordenadas NÃO devem ser confundidas com localização precisa do usuário. Não foi implementado envio de notificações ao ofertante.
