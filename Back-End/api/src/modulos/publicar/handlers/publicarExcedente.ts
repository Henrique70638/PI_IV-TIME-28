//Autora: Laura Lugli Fonseca Pereira RA: 25000739
import { Request, Response, NextFunction } from 'express';
import { ObjectId } from 'mongodb';
import { ErroApp } from '../../../shared/erros';
import { CATEGORIAS, UNIDADES, URGENCIAS, MODALIDADES, Excedente } from '../types/excedente';
import { inserirExcedente } from '../repositories/excedenteRepository';
import { textoObrigatorio, valorDaLista, numeroEntre } from './validacoes';

//arredonda a coordenada para uns 100 metros e não mostra o endereço exato
function arredondar(coordenada: number): number {
  return Math.round(coordenada * 1000) / 1000;
}

//recebe os dados da tela, valida e salva o excedente
export async function publicarExcedente(req: Request, res: Response, next: NextFunction) {
  try {
    const dados = req.body;

    //temporário
    if (typeof dados.ofertanteId !== 'string' || !ObjectId.isValid(dados.ofertanteId))
      throw new ErroApp(400, 'Ofertante inválido');

    const ofertanteNome = textoObrigatorio(dados.ofertanteNome, 'o nome do ofertante');
    const produto = textoObrigatorio(dados.produto, 'o nome do produto', 80);
    const categoria = valorDaLista(dados.categoria, CATEGORIAS, 'categoria');
    const unidade = valorDaLista(dados.unidade, UNIDADES, 'unidade');
    const urgencia = valorDaLista(dados.urgencia, URGENCIAS, 'urgência');
    const modalidade = valorDaLista(dados.modalidade, MODALIDADES, 'modalidade');

    if (typeof dados.quantidade !== 'number' || dados.quantidade <= 0)
      throw new ErroApp(400, 'A quantidade deve ser maior que zero');

    //descrição é opcional, só valida se veio
    let descricao: string | undefined;
    if (dados.descricao !== undefined && dados.descricao !== '') {
      if (typeof dados.descricao !== 'string' || dados.descricao.length > 500)
        throw new ErroApp(400, 'A descrição pode ter no máximo 500 caracteres');
      descricao = dados.descricao.trim();
    }

    const bairro = textoObrigatorio(dados.bairro, 'o bairro');
    const cidade = textoObrigatorio(dados.cidade, 'a cidade');
    const latitude = numeroEntre(dados.latitude, 'latitude', -90, 90);
    const longitude = numeroEntre(dados.longitude, 'longitude', -180, 180);

    //fotos também são opcionais, no máximo 3
    let fotos: string[] | undefined;
    if (dados.fotos !== undefined) {
      if (!Array.isArray(dados.fotos) || dados.fotos.length > 3 ||
          !dados.fotos.every((foto: unknown) => typeof foto === 'string'))
        throw new ErroApp(400, 'Envie no máximo 3 fotos');
      fotos = dados.fotos;
    }

    const agora = new Date();

    //monta o excedente no formato do banco 
    const excedente: Excedente = {
      ofertante: { _id: new ObjectId(dados.ofertanteId), nome: ofertanteNome },
      produto,
      categoria,
      quantidade: dados.quantidade,
      unidade,
      urgencia,
      modalidade,
      localizacao: {
        bairro,
        cidade,
        ponto: { type: 'Point', coordinates: [arredondar(longitude), arredondar(latitude)] },
      },
      status: 'disponivel',
      criadoEm: agora,
      atualizadoEm: agora,
    };
    
    //só coloca os opcionais se vieram
    if (descricao) excedente.descricao = descricao;
    if (fotos) excedente.fotos = fotos;

    const salvo = await inserirExcedente(excedente);
    res.status(201).json(salvo);
  } catch (erro) {
    //manda o erro para a central de erros
    next(erro);
  }
}