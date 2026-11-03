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

const localizacaoExcedente = {
  tipo: 'map',
  obrigatorio: true,
  desc: 'Localização aproximada da oferta (nunca o endereço exato).',
  campos: {
    bairro: { tipo: 'string', obrigatorio: true, desc: 'Bairro exibido na oferta.' },
    cidade: { tipo: 'string', obrigatorio: true, desc: 'Cidade da oferta.' },
    geoAproximada: { tipo: 'geopoint', obrigatorio: true, desc: 'Coordenadas arredondadas (cerca de 100 m) usadas para calcular a distância.' },
    geohash: { tipo: 'string', obrigatorio: true, desc: 'Geohash de 10 caracteres de geoAproximada, usado na busca por proximidade.' },
  },
};

const colecoes = {
  usuarios: {
    caminho: 'usuarios/{uid}',
    mvp: true,
    desc: 'Perfil público do usuário. O documento usa o UID do Firebase Authentication; e-mail e senha ficam apenas no Authentication.',
    campos: {
      nome: { tipo: 'string', obrigatorio: true, regra: '1 a 60 caracteres', desc: 'Nome de exibição (ex.: "Roberto C.").' },
      perfil: { tipo: 'string', obrigatorio: true, valores: PERFIS, desc: 'Como o usuário usa o CULT+.' },
      bairro: { tipo: 'string', obrigatorio: true, desc: 'Bairro aproximado, exibido para outros usuários.' },
      cidade: { tipo: 'string', obrigatorio: true, desc: 'Cidade do usuário.' },
      avatar: { tipo: 'string', obrigatorio: false, desc: 'Caminho/URL da foto de perfil no Storage.' },
      avaliacaoMedia: { tipo: 'number', obrigatorio: false, mvp: false, regra: '1 a 5', desc: 'Média das avaliações recebidas. Gravada somente pelo servidor; faz parte da funcionalidade futura de avaliação.' },
      totalAvaliacoes: { tipo: 'number', obrigatorio: false, mvp: false, desc: 'Quantidade de avaliações recebidas. Funcionalidade futura.' },
      criadoEm: { tipo: 'timestamp', obrigatorio: true, desc: 'Data de criação do perfil (imutável).' },
    },
  },

  'usuarios/{uid}/privado': {
    caminho: 'usuarios/{uid}/privado/perfil',
    mvp: true,
    desc: 'Dados privados do usuário, legíveis apenas pelo próprio. Documento único com ID fixo "perfil".',
    campos: {
      localizacao: {
        tipo: 'map',
        obrigatorio: true,
        desc: 'Centro das buscas do usuário.',
        campos: {
          geo: { tipo: 'geopoint', obrigatorio: true, desc: 'Coordenadas do usuário.' },
          geohash: { tipo: 'string', obrigatorio: true, desc: 'Geohash de 10 caracteres de geo.' },
        },
      },
      preferencias: {
        tipo: 'map',
        obrigatorio: false,
        mvp: false,
        desc: 'Preferências do interessado. Critério de match previsto para versões futuras (hipótese a validar).',
        campos: {
          categorias: { tipo: 'array<string>', obrigatorio: false, valores: CATEGORIAS, desc: 'Categorias de interesse recorrente.' },
        },
      },
      atualizadoEm: { tipo: 'timestamp', obrigatorio: true, desc: 'Última atualização.' },
    },
  },

  excedentes: {
    caminho: 'excedentes/{excedenteId}',
    mvp: true,
    desc: 'Oferta publicada por um ofertante (venda ou doação).',
    campos: {
      ofertanteId: { tipo: 'string', obrigatorio: true, desc: 'UID do ofertante (imutável).' },
      ofertanteNome: { tipo: 'string', obrigatorio: true, desc: 'Nome do ofertante copiado de usuarios (desnormalização para listagem).' },
      produto: { tipo: 'string', obrigatorio: true, regra: '1 a 80 caracteres', desc: 'Nome do produto (ex.: "Manga Tommy").' },
      descricao: { tipo: 'string', obrigatorio: false, regra: 'até 500 caracteres', desc: 'Descrição livre.' },
      categoria: { tipo: 'string', obrigatorio: true, valores: CATEGORIAS, desc: 'Categoria do produto. Critério de match do MVP.' },
      quantidade: { tipo: 'number', obrigatorio: true, regra: 'maior que 0', desc: 'Quantidade disponível. Coletada no cadastro; ainda não é critério de match.' },
      unidade: { tipo: 'string', obrigatorio: true, valores: UNIDADES, desc: 'Unidade da quantidade.' },
      urgencia: { tipo: 'string', obrigatorio: true, valores: URGENCIAS, desc: 'Urgência para aproveitar o produto. Coletada no cadastro; ainda não é critério de match.' },
      modalidade: { tipo: 'string', obrigatorio: true, valores: MODALIDADES, desc: 'Venda ou doação.' },
      localizacao: localizacaoExcedente,
      fotos: { tipo: 'array<string>', obrigatorio: false, regra: 'até 3 itens', desc: 'Caminhos/URLs das fotos no Storage.' },
      status: { tipo: 'string', obrigatorio: true, valores: STATUS_EXCEDENTE, desc: 'Situação da oferta. Apenas "disponivel" aparece na busca.' },
      criadoEm: { tipo: 'timestamp', obrigatorio: true, desc: 'Data de publicação (imutável).' },
      atualizadoEm: { tipo: 'timestamp', obrigatorio: true, desc: 'Última atualização.' },
    },
  },

  matches: {
    caminho: 'matches/{excedenteId}_{interessadoId}',
    mvp: true,
    desc: 'Conexão entre uma oferta e um interessado. O ID determinístico impede duplicidade. É também a "conversa" do chat.',
    campos: {
      excedenteId: { tipo: 'string', obrigatorio: true, desc: 'Oferta conectada.' },
      ofertanteId: { tipo: 'string', obrigatorio: true, desc: 'UID do ofertante.' },
      interessadoId: { tipo: 'string', obrigatorio: true, desc: 'UID do interessado.' },
      ofertanteNome: { tipo: 'string', obrigatorio: true, desc: 'Nome do ofertante (desnormalização para a lista de conversas).' },
      interessadoNome: { tipo: 'string', obrigatorio: true, desc: 'Nome do interessado (desnormalização para a lista de conversas).' },
      participantes: { tipo: 'array<string>', obrigatorio: true, regra: '[ofertanteId, interessadoId]', desc: 'Usado nas regras de segurança e na consulta "minhas conversas".' },
      status: { tipo: 'string', obrigatorio: true, valores: STATUS_MATCH, desc: 'Situação da conexão.' },
      criterios: {
        tipo: 'map',
        obrigatorio: true,
        desc: 'Registro dos critérios que justificaram o match. Permite avaliar as hipóteses do MVP.',
        campos: {
          localizacao: { tipo: 'boolean', obrigatorio: true, desc: 'Oferta dentro do raio de busca do interessado.' },
          categoria: { tipo: 'boolean', obrigatorio: true, desc: 'Categoria da oferta coincide com a categoria buscada.' },
          distanciaKm: { tipo: 'number', obrigatorio: true, desc: 'Distância calculada no momento do match.' },
        },
      },
      excedenteResumo: {
        tipo: 'map',
        obrigatorio: true,
        desc: 'Cópia dos dados da oferta no momento do match (cabeçalho do chat).',
        campos: {
          produto: { tipo: 'string', obrigatorio: true, desc: 'Nome do produto.' },
          categoria: { tipo: 'string', obrigatorio: true, valores: CATEGORIAS, desc: 'Categoria.' },
          modalidade: { tipo: 'string', obrigatorio: true, valores: MODALIDADES, desc: 'Venda ou doação.' },
          quantidade: { tipo: 'number', obrigatorio: true, desc: 'Quantidade.' },
          unidade: { tipo: 'string', obrigatorio: true, valores: UNIDADES, desc: 'Unidade.' },
        },
      },
      ultimaMensagem: {
        tipo: 'map',
        obrigatorio: false,
        desc: 'Resumo da última mensagem, para a lista de conversas.',
        campos: {
          texto: { tipo: 'string', obrigatorio: true, desc: 'Texto.' },
          autorId: { tipo: 'string', obrigatorio: true, desc: 'UID do autor.' },
          criadoEm: { tipo: 'timestamp', obrigatorio: true, desc: 'Data de envio.' },
        },
      },
      criadoEm: { tipo: 'timestamp', obrigatorio: true, desc: 'Momento em que o interessado manifestou interesse (imutável).' },
      atualizadoEm: { tipo: 'timestamp', obrigatorio: true, desc: 'Última atividade (criação, mensagem ou mudança de status).' },
      concluidoEm: { tipo: 'timestamp', obrigatorio: false, desc: 'Momento em que a negociação foi concluída.' },
    },
  },

  'matches/{matchId}/mensagens': {
    caminho: 'matches/{matchId}/mensagens/{mensagemId}',
    mvp: true,
    desc: 'Mensagens do chat entre ofertante e interessado. Imutáveis depois de enviadas.',
    campos: {
      autorId: { tipo: 'string', obrigatorio: true, desc: 'UID de quem enviou.' },
      texto: { tipo: 'string', obrigatorio: true, regra: '1 a 1000 caracteres', desc: 'Conteúdo da mensagem.' },
      criadoEm: { tipo: 'timestamp', obrigatorio: true, desc: 'Data de envio.' },
    },
  },
};

const colecoesFuturas = [
  {
    caminho: 'avaliacoes/{avaliacaoId}',
    desc: 'Avaliação mútua após a negociação.',
    campos: 'matchId, avaliadorId, avaliadoId, nota (1 a 5), comentario (opcional), criadoEm',
  },
  {
    caminho: 'usuarios/{uid}/notificacoes/{notificacaoId}',
    desc: 'Alertas de novo excedente compatível, match confirmado e nova mensagem.',
    campos: 'tipo, titulo, corpo, referenciaId, lida, criadoEm',
  },
];

module.exports = { colecoes, colecoesFuturas, CATEGORIAS, UNIDADES, URGENCIAS, MODALIDADES, PERFIS, STATUS_EXCEDENTE, STATUS_MATCH };
