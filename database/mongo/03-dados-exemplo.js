/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 03/11/2026
 *
 * ARQUIVO GERADO por scripts/gerar-mongo.js. Não editar à mão.
 */

(() => {
  const bd = db.getSiblingDB('cultmais');

  bd.usuarios.deleteMany({ _id: { $in: [ObjectId("a10000000000000000000001"), ObjectId("a10000000000000000000002"), ObjectId("a10000000000000000000003"), ObjectId("a10000000000000000000004")] } });
  bd.usuarios.insertMany([
    {
      _id: ObjectId("a10000000000000000000001"),
      nome: "Roberto C.",
      email: "roberto@example.com",
      senhaHash: "$2a$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      perfil: "ofertante",
      bairro: "Jardim das Flores",
      cidade: "Campinas",
      localizacao: { type: "Point", coordinates: [-47.0651, -22.9208] },
      criadoEm: ISODate("2026-10-20T14:00:00.000Z")
    },
    {
      _id: ObjectId("a10000000000000000000002"),
      nome: "Marina S.",
      email: "marina@example.com",
      senhaHash: "$2a$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      perfil: "interessado",
      bairro: "Jardim das Flores",
      cidade: "Campinas",
      localizacao: { type: "Point", coordinates: [-47.065, -22.91] },
      criadoEm: ISODate("2026-10-21T13:00:00.000Z")
    },
    {
      _id: ObjectId("a10000000000000000000003"),
      nome: "Carla M.",
      email: "carla@example.com",
      senhaHash: "$2a$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      perfil: "ambos",
      bairro: "Vila Esperança",
      cidade: "Campinas",
      localizacao: { type: "Point", coordinates: [-47.058, -22.903] },
      criadoEm: ISODate("2026-10-22T15:00:00.000Z")
    },
    {
      _id: ObjectId("a10000000000000000000004"),
      nome: "João P.",
      email: "joao@example.com",
      senhaHash: "$2a$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      perfil: "ofertante",
      bairro: "Parque Verde",
      cidade: "Campinas",
      localizacao: { type: "Point", coordinates: [-47.065, -22.888] },
      criadoEm: ISODate("2026-10-22T16:00:00.000Z")
    }
  ]);
  print('usuarios: ' + bd.usuarios.countDocuments() + ' documentos');

  bd.excedentes.deleteMany({ _id: { $in: [ObjectId("b20000000000000000000001"), ObjectId("b20000000000000000000002"), ObjectId("b20000000000000000000003"), ObjectId("b20000000000000000000004"), ObjectId("b20000000000000000000005"), ObjectId("b20000000000000000000006"), ObjectId("b20000000000000000000007")] } });
  bd.excedentes.insertMany([
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
    },
    {
      _id: ObjectId("b20000000000000000000002"),
      ofertante: { _id: ObjectId("a10000000000000000000004"), nome: "João P." },
      produto: "Limão Taiti",
      descricao: "Limões do pé do quintal, sem agrotóxicos.",
      categoria: "frutas",
      quantidade: 3,
      unidade: "kg",
      urgencia: "alguns_dias",
      modalidade: "doacao",
      localizacao: {
        bairro: "Parque Verde",
        cidade: "Campinas",
        ponto: { type: "Point", coordinates: [-47.065, -22.888] }
      },
      fotos: ["excedentes/2/1.jpg"],
      status: "disponivel",
      criadoEm: ISODate("2026-10-28T10:00:00.000Z"),
      atualizadoEm: ISODate("2026-10-28T10:00:00.000Z")
    },
    {
      _id: ObjectId("b20000000000000000000003"),
      ofertante: { _id: ObjectId("a10000000000000000000003"), nome: "Carla M." },
      produto: "Banana prata",
      descricao: "Dois cachos maduros.",
      categoria: "frutas",
      quantidade: 2,
      unidade: "cacho",
      urgencia: "hoje",
      modalidade: "venda",
      localizacao: {
        bairro: "Vila Esperança",
        cidade: "Campinas",
        ponto: { type: "Point", coordinates: [-47.036, -22.91] }
      },
      fotos: ["excedentes/3/1.jpg"],
      status: "disponivel",
      criadoEm: ISODate("2026-10-28T17:00:00.000Z"),
      atualizadoEm: ISODate("2026-10-28T17:00:00.000Z")
    },
    {
      _id: ObjectId("b20000000000000000000004"),
      ofertante: { _id: ObjectId("a10000000000000000000004"), nome: "João P." },
      produto: "Laranja pera",
      descricao: "Laranjas doces, boas para suco.",
      categoria: "frutas",
      quantidade: 8,
      unidade: "kg",
      urgencia: "alguns_dias",
      modalidade: "venda",
      localizacao: {
        bairro: "Parque Verde",
        cidade: "Campinas",
        ponto: { type: "Point", coordinates: [-47.065, -22.944] }
      },
      fotos: ["excedentes/4/1.jpg"],
      status: "disponivel",
      criadoEm: ISODate("2026-10-27T12:00:00.000Z"),
      atualizadoEm: ISODate("2026-10-27T12:00:00.000Z")
    },
    {
      _id: ObjectId("b20000000000000000000005"),
      ofertante: { _id: ObjectId("a10000000000000000000003"), nome: "Carla M." },
      produto: "Maçã",
      descricao: "Maçãs de uma árvore pequena.",
      categoria: "frutas",
      quantidade: 4,
      unidade: "kg",
      urgencia: "sem_pressa",
      modalidade: "doacao",
      localizacao: {
        bairro: "Vila Esperança",
        cidade: "Campinas",
        ponto: { type: "Point", coordinates: [-47.107, -22.91] }
      },
      fotos: ["excedentes/5/1.jpg"],
      status: "disponivel",
      criadoEm: ISODate("2026-10-27T18:00:00.000Z"),
      atualizadoEm: ISODate("2026-10-27T18:00:00.000Z")
    },
    {
      _id: ObjectId("b20000000000000000000006"),
      ofertante: { _id: ObjectId("a10000000000000000000001"), nome: "Roberto C." },
      produto: "Alface crespa",
      descricao: "Horta de casa, colhida na hora.",
      categoria: "verduras",
      quantidade: 12,
      unidade: "maco",
      urgencia: "hoje",
      modalidade: "doacao",
      localizacao: {
        bairro: "Jardim das Flores",
        cidade: "Campinas",
        ponto: { type: "Point", coordinates: [-47.067, -22.919] }
      },
      fotos: ["excedentes/6/1.jpg"],
      status: "concluido",
      criadoEm: ISODate("2026-10-26T09:00:00.000Z"),
      atualizadoEm: ISODate("2026-10-26T09:00:00.000Z")
    },
    {
      _id: ObjectId("b20000000000000000000007"),
      ofertante: { _id: ObjectId("a10000000000000000000003"), nome: "Carla M." },
      produto: "Mudas de manjericão",
      descricao: "Mudas prontas para replantio.",
      categoria: "mudas",
      quantidade: 8,
      unidade: "muda",
      urgencia: "sem_pressa",
      modalidade: "doacao",
      localizacao: {
        bairro: "Vila Esperança",
        cidade: "Campinas",
        ponto: { type: "Point", coordinates: [-47.058, -22.903] }
      },
      fotos: ["excedentes/7/1.jpg"],
      status: "disponivel",
      criadoEm: ISODate("2026-10-25T16:00:00.000Z"),
      atualizadoEm: ISODate("2026-10-25T16:00:00.000Z")
    }
  ]);
  print('excedentes: ' + bd.excedentes.countDocuments() + ' documentos');

  bd.matches.deleteMany({ _id: { $in: [ObjectId("c30000000000000000000001"), ObjectId("c30000000000000000000002")] } });
  bd.matches.insertMany([
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
      excedenteResumo: {
        produto: "Manga Tommy",
        categoria: "frutas",
        modalidade: "doacao",
        quantidade: 5,
        unidade: "kg"
      },
      criadoEm: ISODate("2026-10-29T12:37:00.000Z"),
      atualizadoEm: ISODate("2026-10-29T12:41:00.000Z"),
      ultimaMensagem: {
        texto: "Combinado, obrigado! 🙌",
        autorId: ObjectId("a10000000000000000000002"),
        criadoEm: ISODate("2026-10-29T12:41:00.000Z")
      }
    },
    {
      _id: ObjectId("c30000000000000000000002"),
      excedenteId: ObjectId("b20000000000000000000006"),
      ofertanteId: ObjectId("a10000000000000000000001"),
      interessadoId: ObjectId("a10000000000000000000003"),
      ofertanteNome: "Roberto C.",
      interessadoNome: "Carla M.",
      participantes: [ObjectId("a10000000000000000000001"), ObjectId("a10000000000000000000003")],
      status: "concluido",
      criterios: { localizacao: true, categoria: true, distanciaKm: 2 },
      excedenteResumo: {
        produto: "Alface crespa",
        categoria: "verduras",
        modalidade: "doacao",
        quantidade: 12,
        unidade: "maco"
      },
      criadoEm: ISODate("2026-10-26T11:00:00.000Z"),
      atualizadoEm: ISODate("2026-10-26T20:10:00.000Z"),
      concluidoEm: ISODate("2026-10-26T20:10:00.000Z"),
      ultimaMensagem: {
        texto: "Retirei, muito obrigada!",
        autorId: ObjectId("a10000000000000000000003"),
        criadoEm: ISODate("2026-10-26T20:00:00.000Z")
      }
    }
  ]);
  print('matches: ' + bd.matches.countDocuments() + ' documentos');

  bd.mensagens.deleteMany({ _id: { $in: [ObjectId("d40000000000000000000001"), ObjectId("d40000000000000000000002"), ObjectId("d40000000000000000000003"), ObjectId("d40000000000000000000004"), ObjectId("d40000000000000000000005"), ObjectId("d40000000000000000000006"), ObjectId("d40000000000000000000007"), ObjectId("d40000000000000000000008")] } });
  bd.mensagens.insertMany([
    {
      _id: ObjectId("d40000000000000000000001"),
      matchId: ObjectId("c30000000000000000000001"),
      autorId: ObjectId("a10000000000000000000002"),
      texto: "Oi, Roberto! Tenho interesse nas mangas 😊",
      criadoEm: ISODate("2026-10-29T12:38:00.000Z")
    },
    {
      _id: ObjectId("d40000000000000000000002"),
      matchId: ObjectId("c30000000000000000000001"),
      autorId: ObjectId("a10000000000000000000001"),
      texto: "Oi! Que bom! Colhi hoje cedo, ainda tem bastante.",
      criadoEm: ISODate("2026-10-29T12:39:00.000Z")
    },
    {
      _id: ObjectId("d40000000000000000000003"),
      matchId: ObjectId("c30000000000000000000001"),
      autorId: ObjectId("a10000000000000000000002"),
      texto: "Posso retirar amanhã às 9h, aí na sua casa?",
      criadoEm: ISODate("2026-10-29T12:40:00.000Z")
    },
    {
      _id: ObjectId("d40000000000000000000004"),
      matchId: ObjectId("c30000000000000000000001"),
      autorId: ObjectId("a10000000000000000000001"),
      texto: "Pode sim! Te envio o endereço certinho por aqui.",
      criadoEm: ISODate("2026-10-29T12:41:00.000Z")
    },
    {
      _id: ObjectId("d40000000000000000000005"),
      matchId: ObjectId("c30000000000000000000001"),
      autorId: ObjectId("a10000000000000000000002"),
      texto: "Combinado, obrigado! 🙌",
      criadoEm: ISODate("2026-10-29T12:41:00.000Z")
    },
    {
      _id: ObjectId("d40000000000000000000006"),
      matchId: ObjectId("c30000000000000000000002"),
      autorId: ObjectId("a10000000000000000000003"),
      texto: "Olá! Posso buscar as alfaces hoje à tarde?",
      criadoEm: ISODate("2026-10-26T11:05:00.000Z")
    },
    {
      _id: ObjectId("d40000000000000000000007"),
      matchId: ObjectId("c30000000000000000000002"),
      autorId: ObjectId("a10000000000000000000001"),
      texto: "Pode sim, estou em casa até as 18h.",
      criadoEm: ISODate("2026-10-26T11:08:00.000Z")
    },
    {
      _id: ObjectId("d40000000000000000000008"),
      matchId: ObjectId("c30000000000000000000002"),
      autorId: ObjectId("a10000000000000000000003"),
      texto: "Retirei, muito obrigada!",
      criadoEm: ISODate("2026-10-26T20:00:00.000Z")
    }
  ]);
  print('mensagens: ' + bd.mensagens.countDocuments() + ' documentos');

})();
