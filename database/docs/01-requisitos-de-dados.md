# 1. Requisitos de dados

Este documento parte das funcionalidades do MVP definidas no relatório de ideação (seção 3.2.1, "Lista de funcionalidades do MVP") e levanta quais dados o banco precisa guardar para sustentá-las.

## 1.1 Funcionalidades do MVP e dados necessários

| Funcionalidade do MVP | Dados necessários | Onde ficam |
|---|---|---|
| Cadastro/login (ofertante, interessado ou ambos) | Identidade (e-mail e senha), nome, perfil de uso, bairro, cidade, localização | Firebase Authentication + `usuarios` + `usuarios/{uid}/privado/perfil` |
| Cadastro de excedente | Produto, categoria, quantidade, unidade, urgência, modalidade (venda ou doação), localização aproximada, fotos | `excedentes` (fotos no Firebase Storage) |
| Busca e listagem de excedentes | Ofertas disponíveis com localização e categoria consultáveis | `excedentes` |
| Filtros básicos (categoria e localização) | Categoria e geohash da oferta; localização e raio do interessado | `excedentes`, `usuarios/{uid}/privado/perfil` |
| Visualização detalhada da oferta | Todos os dados da oferta e o nome do ofertante | `excedentes`, `usuarios` |
| Mecanismo de match (localização e categoria) | Critérios usados, distância calculada, oferta e partes envolvidas | `matches` |
| Contato direto (chat) | Mensagens trocadas entre as duas partes | `matches/{id}/mensagens` |

## 1.2 Indicadores do MVP que o banco precisa permitir calcular

O relatório (seção 3.1.5 e documento de MVP) prevê estes indicadores para validar as hipóteses:

| Indicador | Como é obtido |
|---|---|
| Número de excedentes cadastrados | Contagem de `excedentes` |
| Número de matches gerados | Contagem de `matches` |
| Número de negociações concluídas | Contagem de `matches` com `status = concluido` |
| Relevância dos matches (percepção dos usuários) | Coletada em entrevista; o campo `criterios` registra o que justificou cada match |
| Disposição em continuar usando a plataforma | Coletada em entrevista (fora do banco) |

O script `scripts/metricas.js` calcula os três primeiros.

## 1.3 Premissas adotadas

Estas decisões de modelagem não estavam explícitas nos documentos anteriores e precisam ser confirmadas pelo grupo:

1. **Quando nasce um match.** No MVP, publicar a oferta representa o interesse do ofertante. O match é criado quando o interessado manifesta interesse ("Tenho interesse") em uma oferta que atende aos critérios (localização e categoria). O campo `status` aceita evoluir para um fluxo com aceite explícito do ofertante, se o grupo decidir.
2. **Critério de categoria.** Considera-se compatível quando a categoria da oferta coincide com a categoria buscada pelo interessado (chip de categoria na tela de busca).
3. **Critério de localização.** Considera-se compatível quando a oferta está dentro do raio de busca do interessado. O protótipo usa "Até 5 km" como valor de exemplo.
4. **Quantidade, urgência e preferências.** Quantidade e urgência são coletadas no cadastro da oferta (como na especificação das telas), mas **não são critérios de match no MVP**. Preferências só existem como campo futuro. Todos continuam sendo hipóteses a validar com usuários reais.
5. **Fontes de receita.** Continuam sendo hipóteses. O banco não guarda preços nem dados de pagamento no MVP.
6. **Avaliação e notificações.** Estão fora do MVP. As coleções ficam apenas documentadas como futuras. Atenção: as telas do protótipo "Detalhe da Oferta" e "Chat" exibem a nota do ofertante (ex.: 4,8 · 12 avaliações). Como o sistema de avaliação não faz parte do MVP, o grupo deve decidir entre ocultar esse trecho nas telas do MVP ou manter como exemplo da versão completa.
7. **Privacidade.** O endereço exato nunca é armazenado na oferta, apenas coordenadas arredondadas e bairro. A localização precisa do usuário fica em um documento privado. E-mail e senha ficam somente no Firebase Authentication.
