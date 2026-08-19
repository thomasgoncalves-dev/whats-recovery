# ADR 0004 - Contato único por telefone normalizado

**Status:** Aceito · 11/08/2026

## Contexto
A base do supermercado é reimportada a cada campanha e o mesmo
cliente aparece em CSVs diferentes. Precisa ficar definido se
isso gera um Contato ou vários.

## Decisão
Contato é único por telefone normalizado em E.164 (índice único).
O relacionamento com Importação registra a primeira origem.
Reimportar a mesma base não duplica contatos.

## Consequências
- Reimportação é idempotente.
- Perde-se o histórico de em quais importações o contato apareceu.
  Aceitável: não é requisito. Se virar, entra uma n-n
  (contato_importacao) sem quebrar o resto.
- A garantia "ninguém recebe duas mensagens na mesma campanha"
  passa a depender só do índice único em (campanha_id, contato_id).

## Alternativas descartadas
- **n-n via contato_importacao:** preserva histórico, custa uma
  tabela sem requisito que a justifique.
- **Contato duplicado por importação:** importação mais simples,
  mas contamina a base e joga o dedupe para o momento do disparo.