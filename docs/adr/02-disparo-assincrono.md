# ADR 0002 - Disparo assíncrono e retomável

**Status:** Aceito · 19/08/2026

## Contexto
O RNF04 exige resposta inferior a 3 segundos. Uma campanha de
mil contatos, com o intervalo entre mensagens que o RNF03 exige
para evitar bloqueio do número, leva horas para concluir. Uma
requisição HTTP não pode sustentar essa duração: o navegador,
o proxy reverso e o próprio usuário desistem antes.

## Decisão
A requisição que inicia a campanha apenas persiste os registros
de Envio em estado PENDENTE, muda a campanha para EM_EXECUCAO
e retorna. O processamento roda em background, fora do ciclo da
requisição. O progresso é consultado por endpoint próprio.

## Consequências
- O RNF04 passa a ser atendido: a requisição de início faz
  inserção em lote e devolve em milissegundos.
- Todo o estado da execução vive no banco, não em memória de
  requisição. Reinício da aplicação não perde envios pendentes.
- O frontend precisa consultar o progresso periodicamente, o que
  adiciona um endpoint e uma tela que não existiriam no modelo
  síncrono.
- Erro no meio da campanha não retorna ao usuário na hora. A
  observabilidade passa a depender do status por envio e da
  mensagem de erro persistida.

## Alternativas descartadas
- **Envio síncrono na requisição:** viola o RNF04 e estoura
  timeout de proxy e de navegador muito antes do fim.
- **Disparar tudo e devolver 202 sem persistir estado:** rápido
  de escrever, mas sem os registros de Envio não existe
  progresso, retomada nem dashboard.