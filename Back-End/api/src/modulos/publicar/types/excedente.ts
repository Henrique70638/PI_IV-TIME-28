import { ObjectId } from 'mongodb';

export const CATEGORIAS = ['frutas', 'verduras', 'legumes', 'mudas'] as const;
export const UNIDADES = ['kg', 'un', 'maco', 'cacho', 'muda'] as const;
export const URGENCIAS = ['hoje', 'alguns_dias', 'sem_pressa'] as const;
export const MODALIDADES = ['doacao', 'venda'] as const;
export const STATUS_EXCEDENTE = ['disponivel', 'concluido', 'removido'] as const;

export type Categoria = typeof CATEGORIAS[number];
export type Unidade = typeof UNIDADES[number];
export type Urgencia = typeof URGENCIAS[number];
export type Modalidade = typeof MODALIDADES[number];
export type StatusExcedente = typeof STATUS_EXCEDENTE[number];

export interface PontoGeo {
    type: 'Point';
    coordinates: [number, number];
}

export interface Excedente {
    _id?: ObjectId;
    ofertante: {
        _id: ObjectId;
        nome: string;
    };
    produto: string;
    descricao?: string;
    categoria: Categoria;
    quantidade: number;
    unidade: Unidade;
    urgencia: Urgencia;
    modalidade: Modalidade;
    localizacao: {
        bairro: string;
        cidade: string;
        ponto: PontoGeo;
    };
    fotos?: string[];
    status: StatusExcedente;
    criadoEm: Date;
    atualizadoEm: Date;
}