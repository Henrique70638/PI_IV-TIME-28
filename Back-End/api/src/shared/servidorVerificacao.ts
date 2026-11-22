//Autora: Laura Lugli Fonseca Pereira RA:25000739

import { spawn } from 'node:child_process'
import path from 'node:path'
import { ErroApp } from './erros'

//pasta do cliente java já compilado 
const pastaCliente = path.resolve(process.cwd(), '../../Servidor/auth/Cliente/bin')

//se o java nao responder nesse tempo desiste
const tempoLimite = 5000

export interface DadosVerificacao {
  nome: string
  email: string
  senha: string
  perfil: string
  bairro: string
}

//tira as quebras de linha pra não bagunçar as respostas do menu
function limpar(texto: string): string {
  return String(texto ?? '').replace(/[\r\n]/g, ' ')
}

//abre o cliente java e digita as opções 
export function verificarNoServidor(dados: DadosVerificacao): Promise<void> {
  return new Promise((resolve, reject) => {
    const java = spawn('java', ['-cp', pastaCliente, 'auth.Cliente'])

    let saida = ''
    const relogio = setTimeout(() => java.kill(), tempoLimite)

    //vai juntando tudo que o cliente imprime
    java.stdout.on('data', (pedaco) => {
      saida += pedaco.toString()
    })

    //cai aqui se nem der pra abrir o java
    java.on('error', () => {
      clearTimeout(relogio)
      reject(new ErroApp(503, 'Servidor de verificação indisponível'))
    })

    //quando o cliente fecha procura a linha do resultado
    java.on('close', () => {
      clearTimeout(relogio)

      const achou = saida.match(/Resultado atual: (valido|invalido): (.*)/)

      //sem resultado quer dizer que o servidor java ta desligado
      if (!achou) {
        reject(new ErroApp(503, 'Servidor de verificação indisponível'))
        return
      }

      //o servidor recusou e manda o motivo pro app
      if (achou[1] === 'invalido') {
        reject(new ErroApp(400, achou[2].trim()))
        return
      }

      resolve()
    })

    const respostas = [
      'V',
      limpar(dados.nome),
      limpar(dados.email),
      limpar(dados.senha),
      limpar(dados.perfil),
      limpar(dados.bairro),
      '=',
      'T',
    ]
    java.stdin.write(respostas.join('\n') + '\n')
    java.stdin.end()
  })
}