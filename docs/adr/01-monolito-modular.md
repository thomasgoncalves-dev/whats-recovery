# ADR 0001 - Monolito modular

**Status:** Aceito · 19/08/2026

## Contexto
O sistema tem um domínio único (campanhas de recuperação), um
perfil administrativo com poder de disparo e um desenvolvedor.
A carga prevista é de campanhas semanais de ~1.000 mensagens.
Era necessário definir o estilo arquitetural antes de iniciar
a implementação.

## Decisão
Monolito modular em camadas, com separação por pacotes de
domínio (campanha, contato, importacao, envio) e um único
artefato de deploy.

## Consequências
- Deploy, observabilidade e ambiente local ficam simples: uma
  aplicação, um banco, um processo.
- Transações abrangem o domínio inteiro sem consistência
  eventual nem coordenação distribuída.
- Falha na aplicação derruba toda a operação. Aceitável: a
  campanha é retomável e nenhum envio se perde, pois o estado
  vive no banco (ver ADR 0003).
- Escalar exige subir instâncias inteiras. Sem problema no
  volume atual, se mudar, a separação por pacotes facilita
  extrair um módulo depois.

## Alternativas descartadas
- **Microsserviços:** exigiriam service discovery, comunicação
  entre serviços e deploys independentes para um domínio que
  não tem fronteiras naturais nem times separados. Custo
  operacional sem contrapartida.
- **Monolito sem modularização:** mais rápido no início, mas
  sem fronteiras de pacote qualquer extração futura vira
  reescrita.