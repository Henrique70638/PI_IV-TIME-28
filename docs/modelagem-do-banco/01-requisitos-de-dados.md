# 1. Requisitos de dados

Este documento parte das funcionalidades do MVP definidas no relatório de ideação (seção 3.2.1, "Lista de funcionalidades do MVP") e levanta quais dados o banco precisa guardar para sustentá-las.

## 1.1 Requisitos da disciplina que orientam o banco

O Plano de Ensino do Projeto Integrador IV (seção "Requisitos de projeto") define:

- Banco de dados: **MongoDB**, "ou algum outro determinado pelo professor de Banco de Dados".
- Aplicação cliente-servidor com obrigatoriedade em Java e testes unitários com JUnit.
- Na avaliação, o banco de dados vale 10% da nota, com os critérios **modelagem, performance, organização e uso de ferramentas**.

Por isso o banco foi modelado em MongoDB (hospedado no MongoDB Atlas), e a documentação destaca as decisões de modelagem, os índices e a medição de desempenho. O servidor Java é o único cliente do banco: o aplicativo não acessa o MongoDB diretamente.

## 1.2 Funcionalidades do MVP e dados necessários

| Funcionalidade do MVP | Dados necessários | Onde ficam |
|---|---|---|
| Cadastro/login (ofertante, interessado ou ambos) | Nome, e-mail, hash da senha, perfil, bairro, cidade, localização | `usuarios` |
| Cadastro de excedente | Produto, categoria, quantidade, unidade, urgência, modalidade (venda ou doação), localização aproximada, fotos | `excedentes` |
| Busca e listagem de excedentes | Ofertas disponíveis com localização e categoria consultáveis | `excedentes` |
| Filtros básicos (categoria e localização) | Categoria da oferta; localização e raio do interessado | `excedentes`, `usuarios` |
| Visualização detalhada da oferta | Dados da oferta e do ofertante | `excedentes`, `usuarios` |
| Mecanismo de match (localização e categoria) | Critérios usados, distância calculada, oferta e partes envolvidas | `matches` |
| Contato direto (chat) | Mensagens trocadas entre as duas partes | `mensagens` |

## 1.3 Indicadores do MVP que o banco precisa permitir calcular

| Indicador | Como é obtido |
|---|---|
| Número de excedentes cadastrados | Contagem de `excedentes` |
| Número de matches gerados | Contagem de `matches` |
| Número de negociações concluídas | Contagem de `matches` com `status = "concluido"` |
| Relevância dos matches (percepção dos usuários) | Coletada em entrevista; o campo `criterios` registra o que justificou cada match |
| Disposição em continuar usando a plataforma | Coletada em entrevista (fora do banco) |

O script `mongo/07-metricas.js` calcula os três primeiros.

## 1.4 Premissas adotadas

Estas decisões de modelagem não estavam explícitas nos documentos anteriores e precisam ser confirmadas pelo grupo:

1. **Quando nasce um match.** No MVP, publicar a oferta representa o interesse do ofertante. O match é criado quando o interessado manifesta interesse ("Tenho interesse") em uma oferta que atende aos critérios. O campo `status` aceita evoluir para um fluxo com aceite explícito do ofertante, se o grupo decidir.
2. **Critério de categoria.** Considera-se compatível quando a categoria da oferta coincide com a categoria buscada pelo interessado.
3. **Critério de localização.** Considera-se compatível quando a oferta está dentro do raio de busca do interessado. O protótipo usa "Até 5 km" como valor de exemplo.
4. **Quantidade, urgência e preferências.** Quantidade e urgência são coletadas no cadastro da oferta, mas **não são critérios de match no MVP**. Preferências só existem como campo futuro. Todos continuam sendo hipóteses a validar com usuários reais.
5. **Fontes de receita.** Continuam sendo hipóteses. O banco não guarda preços nem dados de pagamento no MVP.
6. **Avaliação e notificações.** Estão fora do MVP; as coleções ficam apenas documentadas como futuras. As telas "Detalhe da Oferta" e "Chat" do protótipo exibem a nota do ofertante (ex.: 4,8 · 12 avaliações). Como o sistema de avaliação não faz parte do MVP, o grupo deve decidir entre ocultar esse trecho nas telas do MVP ou mantê-lo como exemplo da versão completa.
7. **Autenticação e privacidade.** O servidor Java cuida do login e guarda apenas o hash BCrypt da senha. O e-mail, o hash e a localização do usuário são dados privados: a API não deve devolvê-los a outros usuários. A oferta guarda só coordenadas aproximadas (cerca de 100 m) e o bairro, nunca o endereço exato.
