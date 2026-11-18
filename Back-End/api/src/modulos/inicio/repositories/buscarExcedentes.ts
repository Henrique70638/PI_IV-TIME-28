// Autor: Rafaela Jacobsen Braga - RA: 25004280

import type { Document } from 'mongodb';
import { getBanco } from '../../../shared/banco';
import type { FiltrosBusca } from '../types/filtrosBusca';

// Escapa caracteres especiais para que a busca seja texto literal, não regex arbitrária.
function escaparRegex(texto: string): string {
  return texto.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export function montarPipelineBusca(filtros: FiltrosBusca): Document[] {
  const query: Document = { status: 'disponivel' };
  if (filtros.categoria) query.categoria = filtros.categoria;
  if (filtros.modalidade) query.modalidade = filtros.modalidade;
  if (filtros.busca) {
    query.produto = { $regex: escaparRegex(filtros.busca), $options: 'i' };
  }

  return [
    {
      $geoNear: {
        key: 'localizacao.ponto',
        near: {
          type: 'Point',
          coordinates: [filtros.longitude, filtros.latitude],
        },
        distanceField: 'distanciaM',
        maxDistance: filtros.raioKm * 1000,
        spherical: true,
        query,
      },
    },
    { $limit: filtros.limite },
    {
      $project: {
        _id: 0,
        id: { $toString: '$_id' },
        produto: 1,
        categoria: 1,
        quantidade: 1,
        unidade: 1,
        modalidade: 1,
        fotos: 1,
        ofertanteNome: '$ofertante.nome',
        bairro: '$localizacao.bairro',
        cidade: '$localizacao.cidade',
        distanciaKm: { $round: [{ $divide: ['$distanciaM', 1000] }, 1] },
      },
    },
  ];
}

export interface ExcedenteResultado {
  id: string;
  produto: string;
  categoria: string;
  quantidade: number;
  unidade: string;
  modalidade: string;
  fotos?: string[];
  ofertanteNome: string;
  bairro: string;
  cidade: string;
  distanciaKm: number;
}

export async function buscarExcedentes(filtros: FiltrosBusca): Promise<ExcedenteResultado[]> {
  return getBanco()
    .collection('excedentes')
    .aggregate<ExcedenteResultado>(montarPipelineBusca(filtros))
    .toArray();
}
