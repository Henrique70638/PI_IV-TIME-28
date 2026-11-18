import { ErroApp } from '../../../shared/erros';

export function textoObrigatorio(valor: unknown, campo: string, maximo?: number): string {
  if (typeof valor !== 'string' || valor.trim() === '')
    throw new ErroApp(400, `Informe ${campo}`);

  const texto = valor.trim();

  if (maximo !== undefined && texto.length > maximo)
    throw new ErroApp(400, `O campo ${campo} pode ter no máximo ${maximo} caracteres`);

  return texto;
}

export function valorDaLista<T extends string>(valor: unknown, lista: readonly T[], campo: string): T {
  if (typeof valor !== 'string' || !lista.includes(valor as T))
    throw new ErroApp(400, `Valor inválido para ${campo}. Use: ${lista.join(', ')}`);

  return valor as T;
}

export function numeroEntre(valor: unknown, campo: string, minimo: number, maximo: number): number {
  if (typeof valor !== 'number' || Number.isNaN(valor) || valor < minimo || valor > maximo)
    throw new ErroApp(400, `Valor inválido para ${campo}`);

  return valor;
}