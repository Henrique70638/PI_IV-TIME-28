// Autor: Rafaela Jacobsen Braga - RA: 25004280

import { ErroApp } from '../../../shared/erros';

export const CATEGORIAS = ['frutas', 'verduras', 'legumes', 'mudas'] as const;
export const MODALIDADES = ['doacao', 'venda'] as const;

export type CategoriaExcedente = (typeof CATEGORIAS)[number];
export type ModalidadeExcedente = (typeof MODALIDADES)[number];

export interface FiltrosBusca {
  latitude: number;
  longitude: number;
  raioKm: number;
  limite: number;
  categoria?: CategoriaExcedente;
  modalidade?: ModalidadeExcedente;
  busca?: string;
}

type Entrada = Record<string, unknown>;

function lerTexto(entrada: Entrada, nome: string): string | undefined {
  const valor = entrada[nome];
  if (valor === undefined) return undefined;
  if (typeof valor !== 'string') {
    throw new ErroApp(400, `O parâmetro ${nome} deve ser informado uma única vez.`);
  }
  return valor.trim();
}

function lerNumero(
  entrada: Entrada,
  nome: string,
  minimo: number,
  maximo: number,
  padrao?: number,
): number {
  const texto = lerTexto(entrada, nome);
  if (texto === undefined && padrao !== undefined) return padrao;
  if (!texto) throw new ErroApp(400, `Informe o parâmetro ${nome}.`);
  const numero = Number(texto);
  if (!Number.isFinite(numero) || numero < minimo || numero > maximo) {
    throw new ErroApp(400, `${nome} deve estar entre ${minimo} e ${maximo}.`);
  }
  return numero;
}

// Valida os filtros recebidos antes de consultar o banco.
export function validarFiltrosBusca(entrada: Entrada): FiltrosBusca {
  const latitude = lerNumero(entrada, 'latitude', -90, 90);
  const longitude = lerNumero(entrada, 'longitude', -180, 180);
  const raioKm = lerNumero(entrada, 'raioKm', 0.1, 50, 5);
  const limite = lerNumero(entrada, 'limite', 1, 50, 30);
  if (!Number.isInteger(limite)) {
    throw new ErroApp(400, 'O parâmetro limite deve ser inteiro.');
  }

  const categoriaInformada = lerTexto(entrada, 'categoria')?.toLowerCase();
  // O protótipo chama a categoria de "Plantas", mas o banco usa "mudas".
  const categoriaNormalizada = categoriaInformada === 'plantas' ? 'mudas' : categoriaInformada;
  let categoria: CategoriaExcedente | undefined;
  if (categoriaNormalizada && categoriaNormalizada !== 'todas') {
    if (!CATEGORIAS.some((item) => item === categoriaNormalizada)) {
      throw new ErroApp(400, 'Categoria inválida.');
    }
    categoria = categoriaNormalizada as CategoriaExcedente;
  }

  const modalidadeInformada = lerTexto(entrada, 'modalidade')?.toLowerCase();
  let modalidade: ModalidadeExcedente | undefined;
  if (modalidadeInformada && modalidadeInformada !== 'todas') {
    if (!MODALIDADES.some((item) => item === modalidadeInformada)) {
      throw new ErroApp(400, 'Modalidade inválida.');
    }
    modalidade = modalidadeInformada as ModalidadeExcedente;
  }

  const buscaInformada = lerTexto(entrada, 'busca');
  if (buscaInformada && buscaInformada.length > 80) {
    throw new ErroApp(400, 'A busca deve ter no máximo 80 caracteres.');
  }

  return {
    latitude,
    longitude,
    raioKm,
    limite,
    ...(categoria && { categoria }),
    ...(modalidade && { modalidade }),
    ...(buscaInformada && { busca: buscaInformada }),
  };
}
