# WhatsApp Recovery

## Objetivo
Desenvolver um sistema seguro que recupere clientes há mais de 40 dias sem comprar através de uma planilha CSV com nome e telefone pelo WhatsApp, substutuindo um trabalho manual imposssível de realizar.

## Problemas Identificados
- Clientes sendo perdidos sem poder de reação.
- Tarefa humanamente inviável, enviar mensagens para mil pessoas semanalmente sobrecarregaria qualquer funcionário.

## Usuários do Sistema
- Admin
- Usuários

## Requisitos Funcionais
- RF01 - Autenticar usuário.
- RF02 - Importar planilha CSV de contatos.
- RF03 - Compor mensagem de campanha.
- RF04 - Confirmar envio.
- RF05 - Realizar envio inteligente.
- RF06 - Pausar, retomar e cancelar campanha.
- RF07 - Retornar feedback de envios.
- RF08 - Emitir dashboards com métricas importantes, como: quantos envios foram sucedidos, falhas, envio diário, semanal e mensal.
  
## Requisitos Não Funcionais
- RNF01 - O sistema deve possuir autenticação.
- RNF02 - O sistema deve ser web e responsivo para dispositivos móveis.
- RNF03 - Lógica inteligente que simula envio humano para evitar bans no número logado.
- RNF04 - < 3s nas operações de interface, importação e disparo são assíncronos.
- RNF05 - Executar disparo de forma assíncrona e retomável.
- RNF06 - Acompanhar progresso em tempo real (enviados, falhas, restantes).

## Regras de Negócio
- RN01 - É permitido somente um disparo por vez.
- RN02 - Apenas administradores podem pausar o envio.

## Escopo e Premissas

### Premissas
- PR01 - A seleção dos clientes inativos (sem compra há mais de
  40 dias) é feita externamente na plataforma Mercafácil, que
  exporta o CSV já filtrado. O sistema não calcula recência de
  compra nem acessa o histórico de vendas.
- PR02 - O CSV de entrada contém apenas nome e telefone, sem
  garantia de formatação (telefones com máscara, sem DDD, com
  8 ou 9 dígitos).
- PR03 - O envio depende de um número de WhatsApp autenticado e
  de uma API gateway de terceiros, fora do controle do sistema.

### Fora de escopo
- Cálculo do critério de inatividade.
- Integração direta com o ERP ou com o Mercafácil.
- Recebimento e tratamento de respostas dos clientes.
- Atribuição de receita às campanhas (medida na plataforma
  do supermercado).
