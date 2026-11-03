# Dicionário de dados

Gerado automaticamente a partir de `scripts/schema.js` (`npm run dicionario`). Não editar à mão: altere o esquema e gere novamente.

Convenções: nomes de campos em camelCase, sem acentos; datas como `timestamp` do Firestore; coordenadas como `geopoint`. A coluna **Fase** indica se o campo é usado pelo MVP ou se pertence a uma funcionalidade futura.

## `usuarios/{uid}`

Perfil público do usuário. O documento usa o UID do Firebase Authentication; e-mail e senha ficam apenas no Authentication.

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `nome` | string | Sim | 1 a 60 caracteres | Nome de exibição (ex.: "Roberto C."). | MVP |
| `perfil` | string | Sim | `ofertante`, `interessado`, `ambos` | Como o usuário usa o CULT+. | MVP |
| `bairro` | string | Sim | — | Bairro aproximado, exibido para outros usuários. | MVP |
| `cidade` | string | Sim | — | Cidade do usuário. | MVP |
| `avatar` | string | Não | — | Caminho/URL da foto de perfil no Storage. | MVP |
| `avaliacaoMedia` | number | Não | 1 a 5 | Média das avaliações recebidas. Gravada somente pelo servidor; faz parte da funcionalidade futura de avaliação. | Futuro |
| `totalAvaliacoes` | number | Não | — | Quantidade de avaliações recebidas. Funcionalidade futura. | Futuro |
| `criadoEm` | timestamp | Sim | — | Data de criação do perfil (imutável). | MVP |

## `usuarios/{uid}/privado/perfil`

Dados privados do usuário, legíveis apenas pelo próprio. Documento único com ID fixo "perfil".

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `localizacao` | map | Sim | — | Centro das buscas do usuário. | MVP |
| `localizacao.geo` | geopoint | Sim | — | Coordenadas do usuário. | MVP |
| `localizacao.geohash` | string | Sim | — | Geohash de 10 caracteres de geo. | MVP |
| `preferencias` | map | Não | — | Preferências do interessado. Critério de match previsto para versões futuras (hipótese a validar). | Futuro |
| `preferencias.categorias` | array<string> | Não | `frutas`, `verduras`, `legumes`, `mudas` | Categorias de interesse recorrente. | Futuro |
| `atualizadoEm` | timestamp | Sim | — | Última atualização. | MVP |

## `excedentes/{excedenteId}`

Oferta publicada por um ofertante (venda ou doação).

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `ofertanteId` | string | Sim | — | UID do ofertante (imutável). | MVP |
| `ofertanteNome` | string | Sim | — | Nome do ofertante copiado de usuarios (desnormalização para listagem). | MVP |
| `produto` | string | Sim | 1 a 80 caracteres | Nome do produto (ex.: "Manga Tommy"). | MVP |
| `descricao` | string | Não | até 500 caracteres | Descrição livre. | MVP |
| `categoria` | string | Sim | `frutas`, `verduras`, `legumes`, `mudas` | Categoria do produto. Critério de match do MVP. | MVP |
| `quantidade` | number | Sim | maior que 0 | Quantidade disponível. Coletada no cadastro; ainda não é critério de match. | MVP |
| `unidade` | string | Sim | `kg`, `un`, `maco`, `cacho`, `muda` | Unidade da quantidade. | MVP |
| `urgencia` | string | Sim | `hoje`, `alguns_dias`, `sem_pressa` | Urgência para aproveitar o produto. Coletada no cadastro; ainda não é critério de match. | MVP |
| `modalidade` | string | Sim | `doacao`, `venda` | Venda ou doação. | MVP |
| `localizacao` | map | Sim | — | Localização aproximada da oferta (nunca o endereço exato). | MVP |
| `localizacao.bairro` | string | Sim | — | Bairro exibido na oferta. | MVP |
| `localizacao.cidade` | string | Sim | — | Cidade da oferta. | MVP |
| `localizacao.geoAproximada` | geopoint | Sim | — | Coordenadas arredondadas (cerca de 100 m) usadas para calcular a distância. | MVP |
| `localizacao.geohash` | string | Sim | — | Geohash de 10 caracteres de geoAproximada, usado na busca por proximidade. | MVP |
| `fotos` | array<string> | Não | até 3 itens | Caminhos/URLs das fotos no Storage. | MVP |
| `status` | string | Sim | `disponivel`, `concluido`, `removido` | Situação da oferta. Apenas "disponivel" aparece na busca. | MVP |
| `criadoEm` | timestamp | Sim | — | Data de publicação (imutável). | MVP |
| `atualizadoEm` | timestamp | Sim | — | Última atualização. | MVP |

## `matches/{excedenteId}_{interessadoId}`

Conexão entre uma oferta e um interessado. O ID determinístico impede duplicidade. É também a "conversa" do chat.

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `excedenteId` | string | Sim | — | Oferta conectada. | MVP |
| `ofertanteId` | string | Sim | — | UID do ofertante. | MVP |
| `interessadoId` | string | Sim | — | UID do interessado. | MVP |
| `ofertanteNome` | string | Sim | — | Nome do ofertante (desnormalização para a lista de conversas). | MVP |
| `interessadoNome` | string | Sim | — | Nome do interessado (desnormalização para a lista de conversas). | MVP |
| `participantes` | array<string> | Sim | [ofertanteId, interessadoId] | Usado nas regras de segurança e na consulta "minhas conversas". | MVP |
| `status` | string | Sim | `conectado`, `concluido`, `cancelado` | Situação da conexão. | MVP |
| `criterios` | map | Sim | — | Registro dos critérios que justificaram o match. Permite avaliar as hipóteses do MVP. | MVP |
| `criterios.localizacao` | boolean | Sim | — | Oferta dentro do raio de busca do interessado. | MVP |
| `criterios.categoria` | boolean | Sim | — | Categoria da oferta coincide com a categoria buscada. | MVP |
| `criterios.distanciaKm` | number | Sim | — | Distância calculada no momento do match. | MVP |
| `excedenteResumo` | map | Sim | — | Cópia dos dados da oferta no momento do match (cabeçalho do chat). | MVP |
| `excedenteResumo.produto` | string | Sim | — | Nome do produto. | MVP |
| `excedenteResumo.categoria` | string | Sim | `frutas`, `verduras`, `legumes`, `mudas` | Categoria. | MVP |
| `excedenteResumo.modalidade` | string | Sim | `doacao`, `venda` | Venda ou doação. | MVP |
| `excedenteResumo.quantidade` | number | Sim | — | Quantidade. | MVP |
| `excedenteResumo.unidade` | string | Sim | `kg`, `un`, `maco`, `cacho`, `muda` | Unidade. | MVP |
| `ultimaMensagem` | map | Não | — | Resumo da última mensagem, para a lista de conversas. | MVP |
| `ultimaMensagem.texto` | string | Sim | — | Texto. | MVP |
| `ultimaMensagem.autorId` | string | Sim | — | UID do autor. | MVP |
| `ultimaMensagem.criadoEm` | timestamp | Sim | — | Data de envio. | MVP |
| `criadoEm` | timestamp | Sim | — | Momento em que o interessado manifestou interesse (imutável). | MVP |
| `atualizadoEm` | timestamp | Sim | — | Última atividade (criação, mensagem ou mudança de status). | MVP |
| `concluidoEm` | timestamp | Não | — | Momento em que a negociação foi concluída. | MVP |

## `matches/{matchId}/mensagens/{mensagemId}`

Mensagens do chat entre ofertante e interessado. Imutáveis depois de enviadas.

| Campo | Tipo | Obrigatório | Valores / regra | Descrição | Fase |
|---|---|---|---|---|---|
| `autorId` | string | Sim | — | UID de quem enviou. | MVP |
| `texto` | string | Sim | 1 a 1000 caracteres | Conteúdo da mensagem. | MVP |
| `criadoEm` | timestamp | Sim | — | Data de envio. | MVP |

## Coleções futuras (fora do MVP)

Ainda não existem no banco nem nas regras de segurança; ficam documentadas para a evolução do produto.

| Caminho | Descrição | Campos previstos |
|---|---|---|
| `avaliacoes/{avaliacaoId}` | Avaliação mútua após a negociação. | matchId, avaliadorId, avaliadoId, nota (1 a 5), comentario (opcional), criadoEm |
| `usuarios/{uid}/notificacoes/{notificacaoId}` | Alertas de novo excedente compatível, match confirmado e nova mensagem. | tipo, titulo, corpo, referenciaId, lida, criadoEm |
