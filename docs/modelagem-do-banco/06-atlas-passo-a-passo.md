# 6. MongoDB Atlas, Compass e mongosh: passo a passo

Os nomes de botões e menus do Atlas mudam de tempos em tempos; se algo não estiver no lugar descrito, procure o equivalente.

## 6.1 Criar o cluster (uma pessoa do grupo)

1. Acesse https://www.mongodb.com/cloud/atlas e crie uma conta (ou entre com uma existente).
2. Crie uma organização e um projeto, por exemplo `PI-IV-TIME-28`.
3. Em **Database**, clique em **Create** e escolha o plano gratuito **M0**. Escolha uma região próxima (por exemplo, São Paulo, se disponível) e dê um nome ao cluster.
4. Aguarde a criação, que leva alguns minutos.
5. Convide os outros integrantes: no projeto, abra **Access Manager** (ou **Project Access**) e use **Invite to Project**, com o e-mail de cada um.

## 6.2 Usuário do banco e acesso pela rede

1. Em **Database Access**, crie dois usuários com senhas fortes, ambos restritos ao banco `cultmais` (use **Specific Privileges**, e não administrador do cluster):
   - `cultmais_admin`, com os papéis `readWrite` e `dbAdmin` em `cultmais`. É usado para executar os scripts de criação (atualizar validadores exige `dbAdmin`).
   - `cultmais_app`, apenas com `readWrite` em `cultmais`. É o usuário que o servidor Java usa.
2. Evite caracteres especiais na senha (`@`, `:`, `/`, `?`, `#`), ou codifique-os na string de conexão; esses caracteres quebram a URL.
3. Em **Network Access**, clique em **Add IP Address** e adicione o IP de cada integrante (botão **Add Current IP Address**). Liberar "Allow access from anywhere" (`0.0.0.0/0`) funciona em desenvolvimento, mas deve ser desfeito depois.

## 6.3 Obter a string de conexão

1. No cluster, clique em **Connect** e escolha **Drivers** (ou **Compass**).
2. Copie a string, no formato `mongodb+srv://USUARIO:SENHA@NOME-DO-CLUSTER.mongodb.net/`.
3. Troque `USUARIO` e `SENHA` pelos do passo 6.2: `cultmais_admin` para rodar os scripts deste documento e `cultmais_app` na variável `MONGODB_URI` do servidor.

Não coloque essa string em nenhum arquivo do repositório. No servidor Java, leia-a da variável de ambiente `MONGODB_URI`.

## 6.4 Criar o banco com o mongosh

1. Instale o **mongosh** (https://www.mongodb.com/try/download/shell) e confira com `mongosh --version`.
2. Abra o PowerShell na pasta `database\mongo` do repositório e execute, com a string do usuário `cultmais_admin` (as aspas são necessárias):

   ```
   mongosh "mongodb+srv://USUARIO:SENHA@NOME-DO-CLUSTER.mongodb.net/cultmais" --file 00-executar-tudo.js
   ```

3. A saída deve listar as quatro coleções criadas, os índices de cada uma e a contagem de documentos (4 usuários, 7 excedentes, 2 matches, 8 mensagens).

Se preferir, entre no mongosh de forma interativa e carregue o arquivo:

```
mongosh "mongodb+srv://USUARIO:SENHA@NOME-DO-CLUSTER.mongodb.net/cultmais"
load('00-executar-tudo.js')
```

Os scripts podem ser executados mais de uma vez: coleções existentes só têm o validador atualizado, índices existentes são mantidos e os dados de exemplo são recriados sem duplicar.

Depois, para ver as consultas, o fluxo e o desempenho:

```
mongosh "<string-de-conexao>" --file 04-consultas-mvp.js
mongosh "<string-de-conexao>" --file 05-fluxo-mvp.js
mongosh "<string-de-conexao>" --file 06-desempenho.js
mongosh "<string-de-conexao>" --file 07-metricas.js
```

## 6.5 Conferir no MongoDB Compass

1. Instale o **MongoDB Compass** (https://www.mongodb.com/products/compass), cole a string de conexão e conecte.
2. No banco `cultmais`, confira as quatro coleções.
3. Em cada coleção, as abas úteis para a avaliação do banco de dados:
   - **Indexes**: mostra os índices criados (incluindo o `2dsphere` em `excedentes`).
   - **Validation**: mostra o `$jsonSchema` aplicado.
   - **Explain Plan**: permite colar uma consulta (por exemplo, a busca por proximidade) e ver se usa `IXSCAN`.
   - **Schema**: mostra a distribuição dos tipos e valores dos campos.

## 6.6 Evidências para a avaliação (modelagem, performance, organização, ferramentas)

Guarde prints ou a saída dos seguintes itens, para apresentar ao professor de Banco de Dados:

- O diagrama (`docs/diagramas/der-conceitual.png`) e o dicionário de dados (`docs/04-dicionario-de-dados.md`).
- A aba **Validation** do Compass em uma coleção.
- A aba **Indexes** de `excedentes`.
- A saída de `06-desempenho.js` (índice versus varredura) ou o Explain Plan da busca por proximidade.
- O cluster no Atlas, mostrando as coleções e a quantidade de documentos.

## 6.7 Cuidados no plano gratuito (M0)

- O M0 tem limite de armazenamento (512 MB). O script de desempenho insere cerca de 20.000 documentos pequenos e os remove no final.
- O M0 limita operações por segundo; scripts com muitas escritas podem demorar mais que o esperado.
- Clusters M0 podem ser pausados por inatividade; se a conexão falhar depois de dias sem uso, verifique o estado do cluster no Atlas.
