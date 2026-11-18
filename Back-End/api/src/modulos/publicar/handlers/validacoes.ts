//Autora: Laura Lugli Fonseca Pereira RA: 25000739
import { ErroApp } from '../../../shared/erros';
//confere se veio um texto não vazio e devolve ele sem espaços nas pontas
export function textoObrigatorio(valor: unknown, campo: string, maximo?: number): string {
    if (typeof valor !== 'string' || valor.trim() === '')
        throw new ErroApp(400, `Informe ${campo}`);

    const texto = valor.trim();

    //só confere o tamanho se tiver limite
    if (maximo !== undefined && texto.length > maximo)
        throw new ErroApp(400, `O campo ${campo} pode ter no máximo ${maximo} caracteres`);

    return texto;
}

//confere se o valor está em uma das listas de valores aceitos
export function valorDaLista<T extends string>(valor: unknown, lista: readonly T[], campo: string): T {
    if (typeof valor !== 'string' || !lista.includes(valor as T))
        throw new ErroApp(400, `Valor inválido para ${campo}. Use: ${lista.join(', ')}`);

    return valor as T;
}

//confere se é um número dentro do intervalo
export function numeroEntre(valor: unknown, campo: string, minimo: number, maximo: number): number {
    if (typeof valor !== 'number' || Number.isNaN(valor) || valor < minimo || valor > maximo)
        throw new ErroApp(400, `Valor inválido para ${campo}`);

    return valor;
}