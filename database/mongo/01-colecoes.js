/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * ARQUIVO GERADO por scripts/gerar-mongo.js. Não editar à mão.
 */

(() => {
  const bd = db.getSiblingDB('cultmais');

  const validadores = {
    usuarios: {
      bsonType: "object",
      required: [
        "_id",
        "nome",
        "email",
        "senhaHash",
        "perfil",
        "bairro",
        "cidade",
        "localizacao",
        "criadoEm"
      ],
      additionalProperties: false,
      properties: {
        _id: { bsonType: "objectId", description: "Identificador do usuário." },
        nome: {
          bsonType: "string",
          minLength: 1,
          maxLength: 60,
          description: "Nome de exibição (ex.: \"Roberto C.\")."
        },
        email: {
          bsonType: "string",
          pattern: "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$",
          description: "E-mail de login. Privado: a API não deve devolvê-lo a outros usuários."
        },
        senhaHash: {
          bsonType: "string",
          minLength: 20,
          description: "Hash BCrypt da senha. Nunca a senha em texto. Privado."
        },
        perfil: {
          bsonType: "string",
          enum: ["ofertante", "interessado", "ambos"],
          description: "Como o usuário usa o CULT+."
        },
        bairro: {
          bsonType: "string",
          minLength: 1,
          description: "Bairro exibido para outros usuários."
        },
        cidade: { bsonType: "string", minLength: 1, description: "Cidade do usuário." },
        localizacao: {
          bsonType: "object",
          required: ["type", "coordinates"],
          additionalProperties: false,
          properties: {
            type: { bsonType: "string", enum: ["Point"] },
            coordinates: {
              bsonType: "array",
              minItems: 2,
              maxItems: 2,
              items: { bsonType: "number" },
              description: "[longitude, latitude]"
            }
          },
          description: "Localização do usuário (GeoJSON Point), centro das suas buscas. Privada."
        },
        avatar: { bsonType: "string", description: "Caminho ou URL da foto de perfil." },
        preferencias: {
          bsonType: "object",
          additionalProperties: false,
          properties: {
            categorias: {
              bsonType: "array",
              items: { bsonType: "string", enum: ["frutas", "verduras", "legumes", "mudas"] },
              description: "Categorias de interesse recorrente."
            }
          },
          description: "Preferências do interessado. Critério de match previsto para versões futuras (hipótese a validar)."
        },
        avaliacaoMedia: {
          bsonType: "number",
          minimum: 1,
          maximum: 5,
          description: "Média das avaliações recebidas. Funcionalidade futura."
        },
        totalAvaliacoes: {
          bsonType: "number",
          minimum: 0,
          description: "Quantidade de avaliações recebidas. Funcionalidade futura."
        },
        criadoEm: { bsonType: "date", description: "Data de criação do perfil." }
      }
    },
    excedentes: {
      bsonType: "object",
      required: [
        "_id",
        "ofertante",
        "produto",
        "categoria",
        "quantidade",
        "unidade",
        "urgencia",
        "modalidade",
        "localizacao",
        "status",
        "criadoEm",
        "atualizadoEm"
      ],
      additionalProperties: false,
      properties: {
        _id: { bsonType: "objectId", description: "Identificador da oferta." },
        ofertante: {
          bsonType: "object",
          required: ["_id", "nome"],
          additionalProperties: false,
          properties: {
            _id: { bsonType: "objectId", description: "Id do ofertante (usuarios._id)." },
            nome: {
              bsonType: "string",
              minLength: 1,
              description: "Nome copiado de usuarios.nome."
            }
          },
          description: "Referência estendida ao ofertante: guarda o id e o nome para exibir a oferta sem consultar usuarios."
        },
        produto: {
          bsonType: "string",
          minLength: 1,
          maxLength: 80,
          description: "Nome do produto (ex.: \"Manga Tommy\")."
        },
        descricao: { bsonType: "string", maxLength: 500, description: "Descrição livre." },
        categoria: {
          bsonType: "string",
          enum: ["frutas", "verduras", "legumes", "mudas"],
          description: "Categoria. Critério de match do MVP."
        },
        quantidade: {
          bsonType: "number",
          minimum: 0,
          exclusiveMinimum: true,
          description: "Quantidade disponível. Coletada no cadastro; ainda não é critério de match."
        },
        unidade: {
          bsonType: "string",
          enum: ["kg", "un", "maco", "cacho", "muda"],
          description: "Unidade da quantidade."
        },
        urgencia: {
          bsonType: "string",
          enum: ["hoje", "alguns_dias", "sem_pressa"],
          description: "Urgência para aproveitar o produto. Coletada no cadastro; ainda não é critério de match."
        },
        modalidade: {
          bsonType: "string",
          enum: ["doacao", "venda"],
          description: "Venda ou doação."
        },
        localizacao: {
          bsonType: "object",
          required: ["bairro", "cidade", "ponto"],
          additionalProperties: false,
          properties: {
            bairro: { bsonType: "string", minLength: 1, description: "Bairro exibido na oferta." },
            cidade: { bsonType: "string", minLength: 1, description: "Cidade da oferta." },
            ponto: {
              bsonType: "object",
              required: ["type", "coordinates"],
              additionalProperties: false,
              properties: {
                type: { bsonType: "string", enum: ["Point"] },
                coordinates: {
                  bsonType: "array",
                  minItems: 2,
                  maxItems: 2,
                  items: { bsonType: "number" },
                  description: "[longitude, latitude]"
                }
              },
              description: "GeoJSON Point com coordenadas arredondadas (cerca de 100 m), usado na busca por proximidade."
            }
          },
          description: "Localização aproximada da oferta, nunca o endereço exato."
        },
        fotos: {
          bsonType: "array",
          items: { bsonType: "string" },
          maxItems: 3,
          description: "Caminhos ou URLs das fotos."
        },
        status: {
          bsonType: "string",
          enum: ["disponivel", "concluido", "removido"],
          description: "Situação da oferta. Só \"disponivel\" aparece na busca."
        },
        criadoEm: { bsonType: "date", description: "Data de publicação." },
        atualizadoEm: { bsonType: "date", description: "Última atualização." }
      }
    },
    matches: {
      bsonType: "object",
      required: [
        "_id",
        "excedenteId",
        "ofertanteId",
        "interessadoId",
        "ofertanteNome",
        "interessadoNome",
        "participantes",
        "status",
        "criterios",
        "excedenteResumo",
        "criadoEm",
        "atualizadoEm"
      ],
      additionalProperties: false,
      properties: {
        _id: { bsonType: "objectId", description: "Identificador do match." },
        excedenteId: { bsonType: "objectId", description: "Oferta conectada (excedentes._id)." },
        ofertanteId: { bsonType: "objectId", description: "Ofertante (usuarios._id)." },
        interessadoId: { bsonType: "objectId", description: "Interessado (usuarios._id)." },
        ofertanteNome: {
          bsonType: "string",
          minLength: 1,
          description: "Nome do ofertante (referência estendida para a lista de conversas)."
        },
        interessadoNome: {
          bsonType: "string",
          minLength: 1,
          description: "Nome do interessado (referência estendida para a lista de conversas)."
        },
        participantes: {
          bsonType: "array",
          items: { bsonType: "objectId" },
          minItems: 2,
          maxItems: 2,
          description: "Os dois usuários, para consultar \"minhas conversas\" com um único índice."
        },
        status: {
          bsonType: "string",
          enum: ["conectado", "concluido", "cancelado"],
          description: "Situação da conexão."
        },
        criterios: {
          bsonType: "object",
          required: ["localizacao", "categoria", "distanciaKm"],
          additionalProperties: false,
          properties: {
            localizacao: {
              bsonType: "bool",
              description: "Oferta dentro do raio de busca do interessado."
            },
            categoria: {
              bsonType: "bool",
              description: "Categoria da oferta coincide com a categoria buscada."
            },
            distanciaKm: {
              bsonType: "number",
              minimum: 0,
              description: "Distância calculada no momento do match."
            }
          },
          description: "Registro dos critérios que justificaram o match. Permite avaliar as hipóteses do MVP."
        },
        excedenteResumo: {
          bsonType: "object",
          required: ["produto", "categoria", "modalidade", "quantidade", "unidade"],
          additionalProperties: false,
          properties: {
            produto: { bsonType: "string", minLength: 1, description: "Nome do produto." },
            categoria: {
              bsonType: "string",
              enum: ["frutas", "verduras", "legumes", "mudas"],
              description: "Categoria."
            },
            modalidade: {
              bsonType: "string",
              enum: ["doacao", "venda"],
              description: "Venda ou doação."
            },
            quantidade: {
              bsonType: "number",
              minimum: 0,
              exclusiveMinimum: true,
              description: "Quantidade."
            },
            unidade: {
              bsonType: "string",
              enum: ["kg", "un", "maco", "cacho", "muda"],
              description: "Unidade."
            }
          },
          description: "Cópia dos dados da oferta no momento do match (cabeçalho do chat)."
        },
        ultimaMensagem: {
          bsonType: "object",
          required: ["texto", "autorId", "criadoEm"],
          additionalProperties: false,
          properties: {
            texto: { bsonType: "string", minLength: 1, description: "Texto." },
            autorId: { bsonType: "objectId", description: "Autor (usuarios._id)." },
            criadoEm: { bsonType: "date", description: "Data de envio." }
          },
          description: "Resumo da última mensagem, para a lista de conversas."
        },
        criadoEm: {
          bsonType: "date",
          description: "Momento em que o interessado manifestou interesse."
        },
        atualizadoEm: {
          bsonType: "date",
          description: "Última atividade (criação, mensagem ou mudança de status)."
        },
        concluidoEm: { bsonType: "date", description: "Momento em que a negociação foi concluída." }
      }
    },
    mensagens: {
      bsonType: "object",
      required: ["_id", "matchId", "autorId", "texto", "criadoEm"],
      additionalProperties: false,
      properties: {
        _id: { bsonType: "objectId", description: "Identificador da mensagem." },
        matchId: { bsonType: "objectId", description: "Conversa (matches._id)." },
        autorId: { bsonType: "objectId", description: "Quem enviou (usuarios._id)." },
        texto: {
          bsonType: "string",
          minLength: 1,
          maxLength: 1000,
          description: "Conteúdo da mensagem."
        },
        criadoEm: { bsonType: "date", description: "Data de envio." }
      }
    }
  };

  function criarOuAtualizar(nome, esquema) {
    const validator = { $jsonSchema: esquema };
    const opcoes = { validationLevel: 'strict', validationAction: 'error' };
    if (bd.getCollectionInfos({ name: nome }).length > 0) {
      bd.runCommand({ collMod: nome, validator, ...opcoes });
      print('Coleção atualizada: ' + nome);
    } else {
      bd.createCollection(nome, { validator, ...opcoes });
      print('Coleção criada: ' + nome);
    }
  }

  for (const [nome, esquema] of Object.entries(validadores)) criarOuAtualizar(nome, esquema);

})();
