# ADR 0005 - Gateway do WhatsApp atrás de interface

**Status:** Aceito · 19/08/2026

## Contexto
O envio depende de uma API de terceiro e de um número de
WhatsApp autenticado, ambos fora do controle da aplicação.
Se o código chamar o provedor diretamente, nenhum teste roda
sem rede e ninguém consegue executar o projeto localmente sem
antes conectar um número real.

## Decisão
O domínio depende de uma interface própria, que recebe telefone
e mensagem e devolve o identificador externo ou o motivo da
falha. Duas implementações: a real, que fala com o provedor, e
uma fake ativada por profile, que simula sucesso, latência e
falha sem sair da máquina.

## Consequências
- Testes de domínio e de integração rodam sem WhatsApp e sem
  rede, em pipeline de CI.
- Qualquer pessoa clona o repositório e executa a aplicação
  inteira com a fake, incluindo quem estiver avaliando o
  projeto. Sem isso, o repositório é código que ninguém roda.
- Trocar de provedor fica restrito a uma classe, sem tocar em
  domínio nem em worker.
- Custo de manter duas implementações, e risco de a fake
  divergir do comportamento real. Mitigado fazendo a fake
  simular também os erros que importam, não só o caminho feliz.

## Alternativas descartadas
- **Chamar o SDK do provedor direto no serviço:** acopla o
  domínio a um terceiro e torna o teste dependente de rede e
  de um número autenticado.
- **Mock apenas nos testes unitários:** resolve o teste, mas
  não permite executar a aplicação localmente, que é metade
  do problema.