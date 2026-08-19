# ADR 0006 - Política de envio isolada

**Status:** Aceito · 19/08/2026

## Contexto
O RNF03 exige um padrão de envio que não caracterize disparo
automatizado, sob risco de bloqueio do número. Os parâmetros
que definem esse padrão (intervalo entre mensagens, variação
aleatória, tamanho do lote, teto diário, janela de horário e
espera entre tentativas) são heurísticos: vão mudar conforme
a operação acumula experiência, e não há valor comprovadamente
correto.

## Decisão
Esses parâmetros ficam concentrados em uma classe própria, que
responde quando o próximo envio pode ocorrer e quanto esperar.
Os valores vêm de configuração externa. A classe não depende
de banco nem do gateway.

## Consequências
- A regra fica testável com relógio controlado, sem esperar
  segundos reais em teste e sem WhatsApp.
- Ajustar um intervalo depois de um susto com bloqueio é mudar
  configuração, não caçar constante espalhada pelo código.
- O worker fica sem regra de negócio: pergunta à política e
  obedece.
- Política mal calibrada não produz erro visível, apenas
  bloqueio do número dias depois. Por isso a decisão de cada
  espera deve ir para log, senão não há como investigar
  quando acontecer.

## Alternativas descartadas
- **Sleep fixo dentro do worker:** intestável, invisível em
  configuração e impossível de ajustar sem novo deploy.
- **Delegar o controle ao provedor:** a aplicação perde a
  capacidade de reagir, e o risco de bloqueio continua sendo
  do número do cliente.