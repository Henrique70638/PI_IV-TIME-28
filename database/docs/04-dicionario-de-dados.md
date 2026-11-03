# Dicionário de dados

Gerado automaticamente a partir de `scripts/schema.js` (`npm run dicionario`). Não editar à mão: altere o esquema e gere novamente.

Banco: `cultmais`. Convenções: nomes de campos em camelCase, sem acentos; datas em `date` (UTC); localizações em GeoJSON no formato `{ type: "Point", coordinates: [longitude, latitude] }`. A coluna **Fase** indica se o campo é usado pelo MVP ou pertence a uma funcionalidade futura.

## Coleção `usuarios`

Pessoas que usam o CULT+ como ofertante, interessado ou ambos. A autenticação é feita pelo servidor, que guarda apenas o hash da senha.

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `_id` | ObjectId | Sim | — | Identificador do usuário. | MVP |
| `nome` | string | Sim | 1 a 60 caracteres | Nome de exibição (ex.: "Roberto C."). | MVP |
| `email` | string | Sim | único | E-mail de login. Privado: a API não deve devolvê-lo a outros usuários. | MVP |
| `senhaHash` | string | Sim | — | Hash BCrypt da senha. Nunca a senha em texto. Privado. | MVP |
| `perfil` | string | Sim | `ofertante`, `interessado`, `ambos` | Como o usuário usa o CULT+. | MVP |
| `bairro` | string | Sim | — | Bairro exibido para outros usuários. | MVP |
| `cidade` | string | Sim | — | Cidade do usuário. | MVP |
| `localizacao` | GeoJSON Point | Sim | — | Localização do usuário (GeoJSON Point), centro das suas buscas. Privada. | MVP |
| `avatar` | string | Não | — | Caminho ou URL da foto de perfil. | MVP |
| `preferencias` | object | Não | — | Preferências do interessado. Critério de match previsto para versões futuras (hipótese a validar). | Futuro |
| `preferencias.categorias` | array de string | Não | `frutas`, `verduras`, `legumes`, `mudas` | Categorias de interesse recorrente. | Futuro |
| `avaliacaoMedia` | number | Não | 1 a 5 | Média das avaliações recebidas. Funcionalidade futura. | Futuro |
| `totalAvaliacoes` | number | Não | — | Quantidade de avaliações recebidas. Funcionalidade futura. | Futuro |
| `criadoEm` | date | Sim | — | Data de criação do perfil. | MVP |

Índices:

| Nome | Chave | Único | Uso |
|---|---|---|---|
| `email_unico` | `{"email":1}` | Sim | Login e garantia de e-mail único. |

## Coleção `excedentes`

Oferta de produto cultivado em casa, para venda ou doação.

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `_id` | ObjectId | Sim | — | Identificador da oferta. | MVP |
| `ofertante` | object | Sim | — | Referência estendida ao ofertante: guarda o id e o nome para exibir a oferta sem consultar usuarios. | MVP |
| `ofertante._id` | ObjectId | Sim | — | Id do ofertante (usuarios._id). | MVP |
| `ofertante.nome` | string | Sim | — | Nome copiado de usuarios.nome. | MVP |
| `produto` | string | Sim | 1 a 80 caracteres | Nome do produto (ex.: "Manga Tommy"). | MVP |
| `descricao` | string | Não | até 500 caracteres | Descrição livre. | MVP |
| `categoria` | string | Sim | `frutas`, `verduras`, `legumes`, `mudas` | Categoria. Critério de match do MVP. | MVP |
| `quantidade` | number | Sim | maior que 0 | Quantidade disponível. Coletada no cadastro; ainda não é critério de match. | MVP |
| `unidade` | string | Sim | `kg`, `un`, `maco`, `cacho`, `muda` | Unidade da quantidade. | MVP |
| `urgencia` | string | Sim | `hoje`, `alguns_dias`, `sem_pressa` | Urgência para aproveitar o produto. Coletada no cadastro; ainda não é critério de match. | MVP |
| `modalidade` | string | Sim | `doacao`, `venda` | Venda ou doação. | MVP |
| `localizacao` | object | Sim | — | Localização aproximada da oferta, nunca o endereço exato. | MVP |
| `localizacao.bairro` | string | Sim | — | Bairro exibido na oferta. | MVP |
| `localizacao.cidade` | string | Sim | — | Cidade da oferta. | MVP |
| `localizacao.ponto` | GeoJSON Point | Sim | — | GeoJSON Point com coordenadas arredondadas (cerca de 100 m), usado na busca por proximidade. | MVP |
| `fotos` | array de string | Não | até 3 itens | Caminhos ou URLs das fotos. | MVP |
| `status` | string | Sim | `disponivel`, `concluido`, `removido` | Situação da oferta. Só "disponivel" aparece na busca. | MVP |
| `criadoEm` | date | Sim | — | Data de publicação. | MVP |
| `atualizadoEm` | date | Sim | — | Última atualização. | MVP |

Índices:

| Nome | Chave | Único | Uso |
|---|---|---|---|
| `geo_status_categoria` | `{"localizacao.ponto":"2dsphere","status":1,"categoria":1}` | Não | Busca por proximidade, com filtro de status e categoria (Home/Busca e Filtros). |
| `ofertante_recentes` | `{"ofertante._id":1,"criadoEm":-1}` | Não | Lista "meus excedentes". |

## Coleção `matches`

Conexão entre uma oferta e um interessado. Também representa a conversa do chat.

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `_id` | ObjectId | Sim | — | Identificador do match. | MVP |
| `excedenteId` | ObjectId | Sim | — | Oferta conectada (excedentes._id). | MVP |
| `ofertanteId` | ObjectId | Sim | — | Ofertante (usuarios._id). | MVP |
| `interessadoId` | ObjectId | Sim | — | Interessado (usuarios._id). | MVP |
| `ofertanteNome` | string | Sim | — | Nome do ofertante (referência estendida para a lista de conversas). | MVP |
| `interessadoNome` | string | Sim | — | Nome do interessado (referência estendida para a lista de conversas). | MVP |
| `participantes` | array de ObjectId | Sim | [ofertanteId, interessadoId] | Os dois usuários, para consultar "minhas conversas" com um único índice. | MVP |
| `status` | string | Sim | `conectado`, `concluido`, `cancelado` | Situação da conexão. | MVP |
| `criterios` | object | Sim | — | Registro dos critérios que justificaram o match. Permite avaliar as hipóteses do MVP. | MVP |
| `criterios.localizacao` | bool | Sim | — | Oferta dentro do raio de busca do interessado. | MVP |
| `criterios.categoria` | bool | Sim | — | Categoria da oferta coincide com a categoria buscada. | MVP |
| `criterios.distanciaKm` | number | Sim | — | Distância calculada no momento do match. | MVP |
| `excedenteResumo` | object | Sim | — | Cópia dos dados da oferta no momento do match (cabeçalho do chat). | MVP |
| `excedenteResumo.produto` | string | Sim | — | Nome do produto. | MVP |
| `excedenteResumo.categoria` | string | Sim | `frutas`, `verduras`, `legumes`, `mudas` | Categoria. | MVP |
| `excedenteResumo.modalidade` | string | Sim | `doacao`, `venda` | Venda ou doação. | MVP |
| `excedenteResumo.quantidade` | number | Sim | — | Quantidade. | MVP |
| `excedenteResumo.unidade` | string | Sim | `kg`, `un`, `maco`, `cacho`, `muda` | Unidade. | MVP |
| `ultimaMensagem` | object | Não | — | Resumo da última mensagem, para a lista de conversas. | MVP |
| `ultimaMensagem.texto` | string | Sim | — | Texto. | MVP |
| `ultimaMensagem.autorId` | ObjectId | Sim | — | Autor (usuarios._id). | MVP |
| `ultimaMensagem.criadoEm` | date | Sim | — | Data de envio. | MVP |
| `criadoEm` | date | Sim | — | Momento em que o interessado manifestou interesse. | MVP |
| `atualizadoEm` | date | Sim | — | Última atividade (criação, mensagem ou mudança de status). | MVP |
| `concluidoEm` | date | Não | — | Momento em que a negociação foi concluída. | MVP |

Índices:

| Nome | Chave | Único | Uso |
|---|---|---|---|
| `match_unico` | `{"excedenteId":1,"interessadoId":1}` | Sim | Impede dois matches do mesmo interessado na mesma oferta. |
| `conversas_do_usuario` | `{"participantes":1,"atualizadoEm":-1}` | Não | Lista de conversas do usuário, da mais recente para a mais antiga. |

## Coleção `mensagens`

Mensagens do chat. Ficam em coleção própria para não criar um array sem limite dentro do match.

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `_id` | ObjectId | Sim | — | Identificador da mensagem. | MVP |
| `matchId` | ObjectId | Sim | — | Conversa (matches._id). | MVP |
| `autorId` | ObjectId | Sim | — | Quem enviou (usuarios._id). | MVP |
| `texto` | string | Sim | 1 a 1000 caracteres | Conteúdo da mensagem. | MVP |
| `criadoEm` | date | Sim | — | Data de envio. | MVP |

Índices:

| Nome | Chave | Único | Uso |
|---|---|---|---|
| `mensagens_do_match` | `{"matchId":1,"criadoEm":1}` | Não | Leitura do chat em ordem cronológica. |

## Coleções futuras (fora do MVP)

Ainda não existem no banco; ficam documentadas para a evolução do produto.

| Coleção | Descrição | Campos previstos |
|---|---|---|
| `avaliacoes` | Avaliação mútua após a negociação. | matchId, avaliadorId, avaliadoId, nota (1 a 5), comentario (opcional), criadoEm |
| `notificacoes` | Alertas de novo excedente compatível, match confirmado e nova mensagem. | usuarioId, tipo, titulo, corpo, referenciaId, lida, criadoEm |
