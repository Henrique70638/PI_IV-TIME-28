/*
 * Autor: Henrique Leite de Camargo
 * RA: 25005997
 * Data: 18/11/2026
 */

import { spawn } from 'child_process';
import { env } from './env';
import { ErroApp } from './erros';

export interface DadosParaServidor {
  nome: string;
  email: string;
  senha: string;
  perfil: string;
  bairro: string;
}

export interface RespostaDoServidor {
  valido: boolean;
  mensagem: string;
}

function indisponivel(): ErroApp {
  return new ErroApp(503, 'Servidor de validação indisponível');
}

function semQuebras(valor: string): string {
  return valor.replace(/[\r\n]+/g, ' ');
}

export function validarCadastroNoServidor(dados: DadosParaServidor): Promise<RespostaDoServidor> {
  return new Promise((resolve, reject) => {
    const filho = spawn(
      env.javaComando,
      [
        '-cp',
        env.servidorJavaClasses,
        'ClienteBackend',
        env.servidorJavaHost,
        String(env.servidorJavaPorta),
      ],
      { timeout: 10000 },
    );

    let saida = '';
    filho.stdout.on('data', (parte: Buffer) => {
      saida += parte.toString('utf8');
    });
    filho.stdin.on('error', () => undefined);
    filho.on('error', () => reject(indisponivel()));
    filho.on('close', () => {
      try {
        const resposta = JSON.parse(saida.trim());
        if (typeof resposta.valido !== 'boolean') throw new Error('resposta inesperada');
        resolve({ valido: resposta.valido, mensagem: String(resposta.mensagem ?? '') });
      } catch {
        reject(indisponivel());
      }
    });

    const linhas = [dados.nome, dados.email, dados.senha, dados.perfil, dados.bairro].map(semQuebras);
    filho.stdin.end(linhas.join('\n') + '\n');
  });
}
