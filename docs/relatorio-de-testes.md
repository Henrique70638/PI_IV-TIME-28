# Relatório de testes do servidor

Autor: Henrique Leite de Camargo (RA 25005997) · Data: 22/11/2026

## 1. Objetivo

Verificar o servidor Java de verificação de cadastro (`Servidor/auth`), que segue o modelo cliente-servidor da disciplina: comunicação por sockets, objetos serializados (`PedidoDeOperacao`, `PedidoDeResultado` e `Resultado`) e uma thread por cliente (`SupervisoraDeConexao`). O servidor confere os dados de cadastro e responde se são válidos, com o motivo.

## 2. Estratégia

Os testes são automatizados (JUnit 4) e **usam o servidor real**: a classe de testes sobe a `AceitadoraDeConexao` em uma porta livre e conversa com ela por socket, enviando objetos serializados, do mesmo jeito que o cliente Java usado pelo Back-End. Assim, a validação e a comunicação são testadas juntas.

Em cada teste:
1. abre-se uma conexão nova, porque o servidor guarda o resultado da última verificação por conexão;
2. envia-se um `PedidoDeOperacao` com os dados do cadastro;
3. envia-se um `PedidoDeResultado` e lê-se o `Resultado` devolvido;
4. envia-se `PedidoParaSair` e fecha-se a conexão.

## 3. Ambiente

- Java: OpenJDK 21 (LTS)
- JUnit 4.13.2 e Hamcrest 1.3, na pasta `Servidor/auth/lib`
- Arquivo de testes: `Servidor/auth/Teste/ServidorDeVerificacaoTest.java`

## 4. Casos de teste

| # | Caso | Entrada | Resultado esperado |
|---|---|---|---|
| 1 | Sem verificação prévia | Só `PedidoDeResultado` | Inválido: "Nenhum cadastro foi verificado" |
| 2 | Cadastro válido | Dados corretos | Válido: "Cadastro valido" |
| 3 | Nome em branco | `"   "` | "Informe um nome com ate 60 caracteres" |
| 4 | Nome nulo | `null` | "Informe um nome com ate 60 caracteres" |
| 5 | Limite do nome | 60 letras (aceita) e 61 letras (rejeita) | Válido com 60; mensagem do nome com 61 |
| 6 | E-mails inválidos | `abc`, `abc@`, `@dominio.com`, `abc@dominio`, `a b@dominio.com`, vazio | "E-mail invalido" em todos |
| 7 | E-mail nulo | `null` | "E-mail invalido" |
| 8 | Senha fora do limite | 7 caracteres, 73 caracteres e `null` | "A senha deve ter de 8 a 72 caracteres" |
| 9 | Senha nos limites | 8 e 72 caracteres | Válido |
| 10 | Os três perfis | `ofertante`, `interessado`, `ambos` | Válido |
| 11 | Perfil inválido ou nulo | `qualquer` e `null` | "Perfil invalido" |
| 12 | Bairro em branco ou nulo | `"  "` e `null` | "Informe seu bairro" |
| 13 | Vários campos inválidos | Todos os campos inválidos | Para no primeiro erro (nome) |
| 14 | Verificações seguidas | Cadastro válido e depois inválido, na mesma conexão | O resultado reflete a última verificação |
| 15 | Isolamento entre conexões | Duas conexões simultâneas | A segunda não vê o resultado da primeira |

A senha tem limite de 72 caracteres porque o BCrypt, usado para o hash no Back-End, só considera os primeiros 72.

## 5. Como executar

Na pasta `Servidor/auth`:

```
javac -encoding UTF-8 -d out\servidor Servidor\*.java
javac -encoding UTF-8 -cp "out\servidor;lib\*" -d out\teste Teste\*.java
java -cp "out\servidor;out\teste;lib\*" org.junit.runner.JUnitCore auth.ServidorDeVerificacaoTest
```

## 6. Resultado

```
JUnit version 4.13.2
...............
OK (15 tests)
```

**15 testes executados, 15 aprovados, 0 falhas.**

## 7. Limitações

- O teste cobre o servidor e o protocolo por socket. A integração do Back-End com o servidor (`servidorVerificacao.ts`, que abre o cliente Java) não tem teste automatizado.
- O cliente interativo (`Cliente`) e a interface de comando do servidor (`desativar`) não foram cobertos.
- Não foram feitos testes de carga.
