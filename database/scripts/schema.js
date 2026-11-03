/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 */

const CATEGORIAS = ['frutas', 'verduras', 'legumes', 'mudas'];
const UNIDADES = ['kg', 'un', 'maco', 'cacho', 'muda'];
const URGENCIAS = ['hoje', 'alguns_dias', 'sem_pressa'];
const MODALIDADES = ['doacao', 'venda'];
const PERFIS = ['ofertante', 'interessado', 'ambos'];
const STATUS_EXCEDENTE = ['disponivel', 'concluido', 'removido'];
const STATUS_MATCH = ['conectado', 'concluido', 'cancelado'];

const id = (desc) => ({ tipo: 'objectId', obrigatorio: true, desc });
const ponto = (desc) => ({ tipo: 'ponto', obrigatorio: true, desc });

const colecoes = {
  usuarios: {
    mvp: true,
    desc: 'Pessoas que usam o CULT+ como ofertante, interessado ou ambos. A autenticação é feita pelo servidor, que guarda apenas o hash da senha.',
    campos: {
      _id: id('Identificador do usuário.'),
      nome: { tipo: 'string', obrigatorio: true, minLength: 1, maxLength: 60, desc: 'Nome de exibição (ex.: "Roberto C.").' },
      email: { tipo: 'string', obrigatorio: true, pattern: '^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$', regra: 'único', desc: 'E-mail de login. Privado: a API não deve devolvê-lo a outros usuários.' },
      senhaHash: { tipo: 'string', obrigatorio: true, minLength: 20, desc: 'Hash BCrypt da senha. Nunca a senha em texto. Privado.' },
      perfil: { tipo: 'string', obrigatorio: true, valores: PERFIS, desc: 'Como o usuário usa o CULT+.' },
      bairro: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Bairro exibido para outros usuários.' },
      cidade: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Cidade do usuário.' },
      localizacao: ponto('Localização do usuário (GeoJSON Point), centro das suas buscas. Privada.'),
      avatar: { tipo: 'string', obrigatorio: false, desc: 'Caminho ou URL da foto de perfil.' },
      preferencias: {
        tipo: 'objeto',
        obrigatorio: false,
        mvp: false,
        desc: 'Preferências do interessado. Critério de match previsto para versões futuras (hipótese a validar).',
        campos: {
          categorias: { tipo: 'array<string>', obrigatorio: false, valores: CATEGORIAS, desc: 'Categorias de interesse recorrente.' },
        },
      },
      avaliacaoMedia: { tipo: 'number', obrigatorio: false, mvp: false, minimum: 1, maximum: 5, desc: 'Média das avaliações recebidas. Funcionalidade futura.' },
      totalAvaliacoes: { tipo: 'number', obrigatorio: false, mvp: false, minimum: 0, desc: 'Quantidade de avaliações recebidas. Funcionalidade futura.' },
      criadoEm: { tipo: 'date', obrigatorio: true, desc: 'Data de criação do perfil.' },
    },
  },

  excedentes: {
    mvp: true,
    desc: 'Oferta de produto cultivado em casa, para venda ou doação.',
    campos: {
      _id: id('Identificador da oferta.'),
      ofertante: {
        tipo: 'objeto',
        obrigatorio: true,
        desc: 'Referência estendida ao ofertante: guarda o id e o nome para exibir a oferta sem consultar usuarios.',
        campos: {
          _id: id('Id do ofertante (usuarios._id).'),
          nome: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Nome copiado de usuarios.nome.' },
        },
      },
      produto: { tipo: 'string', obrigatorio: true, minLength: 1, maxLength: 80, desc: 'Nome do produto (ex.: "Manga Tommy").' },
      descricao: { tipo: 'string', obrigatorio: false, maxLength: 500, desc: 'Descrição livre.' },
      categoria: { tipo: 'string', obrigatorio: true, valores: CATEGORIAS, desc: 'Categoria. Critério de match do MVP.' },
      quantidade: { tipo: 'number', obrigatorio: true, minimum: 0, exclusiveMinimum: true, regra: 'maior que 0', desc: 'Quantidade disponível. Coletada no cadastro; ainda não é critério de match.' },
      unidade: { tipo: 'string', obrigatorio: true, valores: UNIDADES, desc: 'Unidade da quantidade.' },
      urgencia: { tipo: 'string', obrigatorio: true, valores: URGENCIAS, desc: 'Urgência para aproveitar o produto. Coletada no cadastro; ainda não é critério de match.' },
      modalidade: { tipo: 'string', obrigatorio: true, valores: MODALIDADES, desc: 'Venda ou doação.' },
      localizacao: {
        tipo: 'objeto',
        obrigatorio: true,
        desc: 'Localização aproximada da oferta, nunca o endereço exato.',
        campos: {
          bairro: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Bairro exibido na oferta.' },
          cidade: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Cidade da oferta.' },
          ponto: ponto('GeoJSON Point com coordenadas arredondadas (cerca de 100 m), usado na busca por proximidade.'),
        },
      },
      fotos: { tipo: 'array<string>', obrigatorio: false, maxItems: 3, desc: 'Caminhos ou URLs das fotos.' },
      status: { tipo: 'string', obrigatorio: true, valores: STATUS_EXCEDENTE, desc: 'Situação da oferta. Só "disponivel" aparece na busca.' },
      criadoEm: { tipo: 'date', obrigatorio: true, desc: 'Data de publicação.' },
      atualizadoEm: { tipo: 'date', obrigatorio: true, desc: 'Última atualização.' },
    },
  },

  matches: {
    mvp: true,
    desc: 'Conexão entre uma oferta e um interessado. Também representa a conversa do chat.',
    campos: {
      _id: id('Identificador do match.'),
      excedenteId: id('Oferta conectada (excedentes._id).'),
      ofertanteId: id('Ofertante (usuarios._id).'),
      interessadoId: id('Interessado (usuarios._id).'),
      ofertanteNome: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Nome do ofertante (referência estendida para a lista de conversas).' },
      interessadoNome: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Nome do interessado (referência estendida para a lista de conversas).' },
      participantes: { tipo: 'array<objectId>', obrigatorio: true, minItems: 2, maxItems: 2, regra: '[ofertanteId, interessadoId]', desc: 'Os dois usuários, para consultar "minhas conversas" com um único índice.' },
      status: { tipo: 'string', obrigatorio: true, valores: STATUS_MATCH, desc: 'Situação da conexão.' },
      criterios: {
        tipo: 'objeto',
        obrigatorio: true,
        desc: 'Registro dos critérios que justificaram o match. Permite avaliar as hipóteses do MVP.',
        campos: {
          localizacao: { tipo: 'boolean', obrigatorio: true, desc: 'Oferta dentro do raio de busca do interessado.' },
          categoria: { tipo: 'boolean', obrigatorio: true, desc: 'Categoria da oferta coincide com a categoria buscada.' },
          distanciaKm: { tipo: 'number', obrigatorio: true, minimum: 0, desc: 'Distância calculada no momento do match.' },
        },
      },
      excedenteResumo: {
        tipo: 'objeto',
        obrigatorio: true,
        desc: 'Cópia dos dados da oferta no momento do match (cabeçalho do chat).',
        campos: {
          produto: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Nome do produto.' },
          categoria: { tipo: 'string', obrigatorio: true, valores: CATEGORIAS, desc: 'Categoria.' },
          modalidade: { tipo: 'string', obrigatorio: true, valores: MODALIDADES, desc: 'Venda ou doação.' },
          quantidade: { tipo: 'number', obrigatorio: true, minimum: 0, exclusiveMinimum: true, desc: 'Quantidade.' },
          unidade: { tipo: 'string', obrigatorio: true, valores: UNIDADES, desc: 'Unidade.' },
        },
      },
      ultimaMensagem: {
        tipo: 'objeto',
        obrigatorio: false,
        desc: 'Resumo da última mensagem, para a lista de conversas.',
        campos: {
          texto: { tipo: 'string', obrigatorio: true, minLength: 1, desc: 'Texto.' },
          autorId: id('Autor (usuarios._id).'),
          criadoEm: { tipo: 'date', obrigatorio: true, desc: 'Data de envio.' },
        },
      },
      criadoEm: { tipo: 'date', obrigatorio: true, desc: 'Momento em que o interessado manifestou interesse.' },
      atualizadoEm: { tipo: 'date', obrigatorio: true, desc: 'Última atividade (criação, mensagem ou mudança de status).' },
      concluidoEm: { tipo: 'date', obrigatorio: false, desc: 'Momento em que a negociação foi concluída.' },
    },
  },

  mensagens: {
    mvp: true,
    desc: 'Mensagens do chat. Ficam em coleção própria para não criar um array sem limite dentro do match.',
    campos: {
      _id: id('Identificador da mensagem.'),
      matchId: id('Conversa (matches._id).'),
      autorId: id('Quem enviou (usuarios._id).'),
      texto: { tipo: 'string', obrigatorio: true, minLength: 1, maxLength: 1000, desc: 'Conteúdo da mensagem.' },
      criadoEm: { tipo: 'date', obrigatorio: true, desc: 'Data de envio.' },
    },
  },
};

const indices = {
  usuarios: [
    { chave: { email: 1 }, opcoes: { unique: true, name: 'email_unico' }, uso: 'Login e garantia de e-mail único.' },
  ],
  excedentes: [
    { chave: { 'localizacao.ponto': '2dsphere', status: 1, categoria: 1 }, opcoes: { name: 'geo_status_categoria' }, uso: 'Busca por proximidade, com filtro de status e categoria (Home/Busca e Filtros).' },
    { chave: { 'ofertante._id': 1, criadoEm: -1 }, opcoes: { name: 'ofertante_recentes' }, uso: 'Lista "meus excedentes".' },
  ],
  matches: [
    { chave: { excedenteId: 1, interessadoId: 1 }, opcoes: { unique: true, name: 'match_unico' }, uso: 'Impede dois matches do mesmo interessado na mesma oferta.' },
    { chave: { participantes: 1, atualizadoEm: -1 }, opcoes: { name: 'conversas_do_usuario' }, uso: 'Lista de conversas do usuário, da mais recente para a mais antiga.' },
  ],
  mensagens: [
    { chave: { matchId: 1, criadoEm: 1 }, opcoes: { name: 'mensagens_do_match' }, uso: 'Leitura do chat em ordem cronológica.' },
  ],
};

const colecoesFuturas = [
  { nome: 'avaliacoes', desc: 'Avaliação mútua após a negociação.', campos: 'matchId, avaliadorId, avaliadoId, nota (1 a 5), comentario (opcional), criadoEm' },
  { nome: 'notificacoes', desc: 'Alertas de novo excedente compatível, match confirmado e nova mensagem.', campos: 'usuarioId, tipo, titulo, corpo, referenciaId, lida, criadoEm' },
];

function campoParaJsonSchema(def) {
  const d = { description: def.desc };
  switch (def.tipo) {
    case 'objectId':
      return { bsonType: 'objectId', ...d };
    case 'string': {
      const s = { bsonType: 'string' };
      if (def.valores) s.enum = def.valores;
      if (def.minLength !== undefined) s.minLength = def.minLength;
      if (def.maxLength !== undefined) s.maxLength = def.maxLength;
      if (def.pattern) s.pattern = def.pattern;
      return { ...s, ...d };
    }
    case 'number': {
      const s = { bsonType: 'number' };
      if (def.minimum !== undefined) s.minimum = def.minimum;
      if (def.exclusiveMinimum) s.exclusiveMinimum = true;
      if (def.maximum !== undefined) s.maximum = def.maximum;
      return { ...s, ...d };
    }
    case 'boolean':
      return { bsonType: 'bool', ...d };
    case 'date':
      return { bsonType: 'date', ...d };
    case 'ponto':
      return {
        bsonType: 'object',
        required: ['type', 'coordinates'],
        additionalProperties: false,
        properties: {
          type: { bsonType: 'string', enum: ['Point'] },
          coordinates: { bsonType: 'array', minItems: 2, maxItems: 2, items: { bsonType: 'number' }, description: '[longitude, latitude]' },
        },
        ...d,
      };
    case 'array<string>': {
      const s = { bsonType: 'array', items: def.valores ? { bsonType: 'string', enum: def.valores } : { bsonType: 'string' } };
      if (def.maxItems !== undefined) s.maxItems = def.maxItems;
      return { ...s, ...d };
    }
    case 'array<objectId>': {
      const s = { bsonType: 'array', items: { bsonType: 'objectId' } };
      if (def.minItems !== undefined) s.minItems = def.minItems;
      if (def.maxItems !== undefined) s.maxItems = def.maxItems;
      return { ...s, ...d };
    }
    case 'objeto':
      return { ...camposParaJsonSchema(def.campos), ...d };
    default:
      throw new Error(`Tipo desconhecido: ${def.tipo}`);
  }
}

function camposParaJsonSchema(campos) {
  const properties = {};
  const required = [];
  for (const [nome, def] of Object.entries(campos)) {
    properties[nome] = campoParaJsonSchema(def);
    if (def.obrigatorio) required.push(nome);
  }
  const esquema = { bsonType: 'object' };
  if (required.length) esquema.required = required;
  esquema.additionalProperties = false;
  esquema.properties = properties;
  return esquema;
}

function jsonSchemaDe(nomeColecao) {
  return camposParaJsonSchema(colecoes[nomeColecao].campos);
}

module.exports = { colecoes, indices, colecoesFuturas, jsonSchemaDe, CATEGORIAS, UNIDADES, URGENCIAS, MODALIDADES, PERFIS, STATUS_EXCEDENTE, STATUS_MATCH };
