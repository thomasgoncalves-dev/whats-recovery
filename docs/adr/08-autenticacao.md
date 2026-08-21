# ADR 0008 - Autenticação

**Status:** Aceito · 21/08/2026

## Contexto
Monolito modular com instância única, poucos usuários,
front e back no mesmo domínio, e um requisito de revogação implícito.
Caminhos indicados JWT ou sessão.

## Decisão
Sessão com cookie resolve tudo isso sem código de token, e
revogar é invalidar a sessão.

## Alternativas descartadas
- **JWT:** só faz sentido em um cenário futuro, se aplicação
obtiver mutiplas instâncias, clientes de tipos dieferentes ou APIs
de terceiros consumindo.

