// Autor: Rafaela Jacobsen Braga - RA: 25004280
import type { ObjectId } from 'mongodb';

export type Categoria = 'frutas' | 'verduras' | 'legumes' | 'mudas';
export type Modalidade = 'doacao' | 'venda';

export interface UsuarioConexao {
  _id: ObjectId;
  nome: string;
  perfil: 'ofertante' | 'interessado' | 'ambos';
  localizacao: { type: 'Point'; coordinates: number[] };
  avaliacaoMedia?: number;
  totalAvaliacoes?: number;
}

export interface OfertaConexao {
  _id: ObjectId;
  ofertante: { _id: ObjectId; nome: string };
  produto: string;
  categoria: Categoria;
  modalidade: Modalidade;
  quantidade: number;
  unidade: 'kg' | 'un' | 'maco' | 'cacho' | 'muda';
  status: 'disponivel' | 'concluido' | 'removido';
  localizacao: {
    bairro: string;
    cidade: string;
    ponto: { type: 'Point'; coordinates: number[] };
  };
}

export interface MatchConexao {
  _id: ObjectId;
  excedenteId: ObjectId;
  ofertanteId: ObjectId;
  interessadoId: ObjectId;
  ofertanteNome: string;
  interessadoNome: string;
  participantes: ObjectId[];
  status: 'conectado' | 'concluido' | 'cancelado';
  criterios: { localizacao: boolean; categoria: boolean; distanciaKm: number };
  excedenteResumo: {
    produto: string;
    categoria: Categoria;
    modalidade: Modalidade;
    quantidade: number;
    unidade: OfertaConexao['unidade'];
  };
  criadoEm: Date;
  atualizadoEm: Date;
}

export interface CriarMatchEntrada {
  excedenteId: ObjectId;
  raioKm: number;
  categoria?: Categoria;
}

export interface ConfirmacaoMatch {
  id: string;
  status: MatchConexao['status'];
  nomeOfertante: string;
  nomeProduto: string;
  quantidade: number;
  unidade: OfertaConexao['unidade'];
  modalidade: Modalidade;
  localizacao: string;
  cidade: string;
  distanciaKm: number;
  avaliacaoOfertante?: number;
  totalAvaliacoes?: number;
}

export interface RepositorioConexao {
  buscarUsuario(id: ObjectId): Promise<UsuarioConexao | null>;
  buscarOferta(id: ObjectId): Promise<OfertaConexao | null>;
  buscarDuplicado(excedenteId: ObjectId, interessadoId: ObjectId): Promise<boolean>;
  inserirMatch(match: MatchConexao): Promise<void>;
  buscarMatchAutorizado(matchId: ObjectId, usuarioId: ObjectId): Promise<MatchConexao | null>;
}
