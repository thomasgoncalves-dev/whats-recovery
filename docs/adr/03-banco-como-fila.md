# ADR 0003 - A tabela envio como fila

**Status:** Aceito · 19/08/2026

## Contexto
Definido o disparo assíncrono (ADR 0002), era preciso escolher
o mecanismo que processa os envios pendentes. A operação é de
mil mensagens semanais, executada por um único administrador,
em uma aplicação com instância única.

## Decisão
A própria tabela `envio` é a fila. Um job agendado varre os
registros em estado PENDENTE em lotes pequenos, marca cada um
como ENVIANDO antes de chamar o gateway e grava o resultado.
A seleção do lote usa bloqueio no banco para impedir que dois
ciclos peguem o mesmo registro.

## Consequências
- A execução é retomável de graça: se a aplicação cair no envio
  400, os 600 restantes continuam PENDENTE e voltam a ser
  processados na subida.
- As métricas do dashboard saem de agregações na mesma tabela,
  sem sistema de telemetria separado.
- Existe latência de até um ciclo do agendador entre iniciar a
  campanha e a primeira mensagem sair. Irrelevante para uma
  operação que já espeja intervalos entre mensagens.
- Consulta periódica ao banco tem custo constante mesmo sem
  campanha ativa. Desprezível neste volume.
- Estado ENVIANDO pode ficar preso se a aplicação cair no meio
  da chamada ao gateway. É preciso um mecanismo que devolva
  para PENDENTE os registros travados além de um tempo limite.

## Alternativas descartadas
- **@Async ou ExecutorService:** a fila vive em memória. Reinício
  da aplicação perde tudo que ainda não saiu, e não há como
  saber o que se perdeu.
- **RabbitMQ ou SQS:** resolveria o problema, mas adiciona
  infraestrutura, duplica o estado (fila e banco) e deixa as
  métricas em dois lugares. Custo operacional sem contrapartida
  para uma instância e um usuário.