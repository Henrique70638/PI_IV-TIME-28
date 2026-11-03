# 3. Modelo de dados no Firestore

O Firestore é um banco de documentos organizado em coleções. Por isso o modelo conceitual foi adaptado: em vez de tabelas ligadas por chaves estrangeiras, usamos documentos que guardam IDs de outros documentos e, quando compensa, uma cópia de dados que a tela precisa exibir (desnormalização).

## 3.1 Estrutura das coleções

```
usuarios/{uid}
└── privado/perfil
excedentes/{excedenteId}
matches/{excedenteId}_{interessadoId}
└── mensagens/{mensagemId}
```

Coleções futuras (fora do MVP, sem regras ainda): `avaliacoes/{id}` e `usuarios/{uid}/notificacoes/{id}`.

## 3.2 Telas do protótipo e o que cada uma lê e grava

| Tela | Lê | Grava |
|---|---|---|
| Cadastro / Login | Authentication | Authentication, `usuarios/{uid}`, `usuarios/{uid}/privado/perfil` |
| Home / Busca (com filtros) | `excedentes` (por categoria e proximidade), `usuarios/{uid}/privado/perfil` | — |
| Cadastro de Excedente | `usuarios/{uid}` | `excedentes`, fotos no Storage |
| Detalhe da Oferta | `excedentes/{id}`, `usuarios/{ofertanteId}` | — |
| Mecanismo de Match | `excedentes`, `usuarios/{uid}/privado/perfil` | `matches/{id}` ao tocar em "Tenho interesse" |
| Conexão / Match Confirmado | `matches/{id}` | — |
| Chat | `matches/{id}`, `matches/{id}/mensagens` | `matches/{id}/mensagens`, `matches/{id}` (última mensagem) |
| Perfil | `usuarios/{uid}` | `usuarios/{uid}` |

## 3.3 Exemplos de documentos

Oferta (`excedentes/exc_manga_tommy`):

```json
{
  "ofertanteId": "u_roberto",
  "ofertanteNome": "Roberto C.",
  "produto": "Manga Tommy",
  "descricao": "Mangas colhidas hoje, quintal com sombra parcial.",
  "categoria": "frutas",
  "quantidade": 5,
  "unidade": "kg",
  "urgencia": "alguns_dias",
  "modalidade": "doacao",
  "localizacao": {
    "bairro": "Jardim das Flores",
    "cidade": "Campinas",
    "geoAproximada": "GeoPoint(-22.921, -47.065)",
    "geohash": "6gyt95276p"
  },
  "fotos": ["excedentes/exc_manga_tommy/1.jpg"],
  "status": "disponivel",
  "criadoEm": "Timestamp",
  "atualizadoEm": "Timestamp"
}
```

Match (`matches/exc_manga_tommy_u_marina`):

```json
{
  "excedenteId": "exc_manga_tommy",
  "ofertanteId": "u_roberto",
  "interessadoId": "u_marina",
  "ofertanteNome": "Roberto C.",
  "interessadoNome": "Marina S.",
  "participantes": ["u_roberto", "u_marina"],
  "status": "conectado",
  "criterios": { "localizacao": true, "categoria": true, "distanciaKm": 1.2 },
  "excedenteResumo": { "produto": "Manga Tommy", "categoria": "frutas", "modalidade": "doacao", "quantidade": 5, "unidade": "kg" },
  "ultimaMensagem": { "texto": "Combinado, obrigado! 🙌", "autorId": "u_marina", "criadoEm": "Timestamp" },
  "criadoEm": "Timestamp",
  "atualizadoEm": "Timestamp"
}
```

Os valores completos estão em `scripts/dados-exemplo.js` (dados fictícios).

## 3.4 Decisões de modelagem

| Decisão | Motivo |
|---|---|
| Match como "conversa" e mensagens em subcoleção | Há uma conversa por match; a subcoleção evita lista de mensagens crescendo dentro de um documento e permite ordenar e paginar. |
| ID do match = `excedenteId_interessadoId` | Impede dois matches para o mesmo par e permite consultar sem índice extra. |
| Campo `participantes` no match | Permite que as regras de segurança e a consulta "minhas conversas" usem uma lista única, sem consultar dois campos. |
| Busca por proximidade com geohash | O Firestore não filtra por distância. O geohash (10 caracteres) permite buscar por faixas e depois filtrar pela distância real no aplicativo. |
| Coordenadas aproximadas na oferta | Protege o endereço do ofertante; a precisão (cerca de 100 m) basta para calcular distância em km. |
| Localização precisa em documento privado | Os documentos de `usuarios` são legíveis por todos os usuários logados; a localização precisa só pelo próprio dono. |
| Desnormalização (`ofertanteNome`, `excedenteResumo`, `ultimaMensagem`) | Evita leituras extras ao montar listas e o cabeçalho do chat. Custo: o aplicativo precisa manter essas cópias coerentes. Como o plano gratuito não permite Cloud Functions, essa manutenção é feita pelo cliente. |
| `criterios` gravado no match | Registra o que justificou a conexão e a distância, para avaliar as hipóteses do MVP. |
| Sem exclusão física | Ofertas usam `status = removido`; histórico é preservado para as métricas. |
| E-mail e senha só no Authentication | Evita duplicar dados pessoais. |

## 3.5 Regras de segurança (`firestore/firestore.rules`)

| Recurso | Leitura | Escrita |
|---|---|---|
| `usuarios/{uid}` | Qualquer usuário logado | Só o próprio dono; campos validados; `criadoEm` imutável |
| `usuarios/{uid}/privado/*` | Só o dono | Só o dono |
| `excedentes` | Qualquer usuário logado | Criar: só quem tem perfil ofertante ou ambos, como autor da oferta. Alterar: só o ofertante. Excluir: ninguém |
| `matches` | Só os dois participantes | Criar: o interessado, em oferta disponível, com critérios de localização e categoria verdadeiros. Alterar: participantes, apenas `status`, `ultimaMensagem`, `atualizadoEm` e `concluidoEm`; só o ofertante conclui. Excluir: ninguém |
| `matches/{id}/mensagens` | Só os dois participantes | Criar: participante, como autor, texto de 1 a 1000 caracteres. Alterar e excluir: ninguém |
| Demais caminhos | Negado | Negado |

Limitação conhecida: sem Cloud Functions, o servidor não confere se a distância informada em `criterios` está correta; essa conferência é feita pelo aplicativo. Para o piloto do MVP isso é aceitável; para produção, o cálculo deveria ir para o servidor.

## 3.6 Índices (`firestore/firestore.indexes.json`)

| Coleção | Campos | Usado em |
|---|---|---|
| `excedentes` | `status`, `categoria`, `localizacao.geohash` | Busca por categoria e proximidade |
| `excedentes` | `status`, `localizacao.geohash` | Busca "todas as categorias" por proximidade |
| `excedentes` | `ofertanteId`, `criadoEm` (decrescente) | "Meus excedentes" |
| `matches` | `participantes` (array), `atualizadoEm` (decrescente) | Lista de conversas |
