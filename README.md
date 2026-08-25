# Whats Recovery

Sistema de campanhas de recuperação de clientes inativos via WhatsApp.
Importa uma base de contatos em CSV, dispara mensagens em ritmo
controlado e acompanha o resultado de cada envio.

## O problema

Um supermercado regional identifica mensalmente cerca de mil clientes
sem compra há mais de 40 dias. Contatar essa base manualmente é
inviável: um funcionário levaria dias, e o envio em rajada por
ferramentas comuns leva ao bloqueio do número de WhatsApp da empresa.

O sistema resolve os dois lados: automatiza o disparo e controla o
ritmo para que o padrão de envio não caracterize automação.

A versão anterior deste sistema opera em produção. Este repositório é
uma reescrita, com a modelagem e as decisões de arquitetura feitas do
zero e documentadas.

## Status

Em desenvolvimento. A modelagem e as decisões de arquitetura estão
concluídas e documentadas; a implementação está em andamento.

| Etapa | Situação |
|---|---|
| Requisitos, casos de uso e modelo de domínio | Concluído |
| Máquinas de estado e invariantes | Concluído |
| Decisões de arquitetura (ADRs) | Concluído |
| Esquema do banco e migration inicial | Concluído |
| Entidades e repositórios | Em andamento |
| Importação de CSV | Pendente |
| Motor de disparo | Pendente |
| API REST e autenticação | Pendente |
| Dashboard de métricas | Pendente |

## Arquitetura

Monolito modular em Spring Boot, com pacotes organizados por
funcionalidade e não por camada. Cada módulo expõe apenas seu serviço;
repositórios e entidades têm visibilidade restrita ao pacote, de modo
que a fronteira entre módulos é garantida pelo compilador.

O disparo é assíncrono e retomável. A requisição que inicia a campanha
apenas cria os registros de envio pendentes e retorna. Um processo em
background consome esses registros em lotes, respeitando a política de
ritmo. Se a aplicação reinicia no meio de uma campanha, os envios
restantes continuam pendentes no banco e a execução retoma sozinha.

A tabela de envios funciona como fila. Isso elimina um broker da
infraestrutura, torna a execução retomável por construção e faz com
que as métricas do dashboard saiam de agregações na mesma tabela que
já registra o estado.

### Decisões documentadas

| ADR | Decisão |
|---|---|
| [0001](docs/adr/01-monolito-modular.md) | Monolito modular, não microsserviços |
| [0002](docs/adr/02-disparo-assincrono.md) | Disparo assíncrono e retomável |
| [0003](docs/adr/03-banco-como-fila.md) | A tabela de envio como fila |
| [0004](docs/adr/04-contato-unico-por-telefone.md) | Contato único por telefone normalizado |
| [0005](docs/adr/05-gateway-whatsapp.md) | Gateway do WhatsApp atrás de interface |
| [0006](docs/adr/06-politica-envio.md) | Política de envio isolada |
| [0007](docs/adr/07-estrutura-pacotes.md) | Pacote por funcionalidade, não por camada |
| [0008](docs/adr/08-autenticacao.md) | Autenticação por sessão com cookie, não JWT |

## Modelo de domínio

- **Campanha** é o agregado central. Guarda a mensagem, o estado da
  execução e quem disparou.
- **Envio** é a associativa entre campanha e contato. Registra estado,
  tentativas, identificador retornado pelo gateway e erro. É a tabela
  que mais cresce e a fonte de todas as métricas.
- **Contato** é único por telefone normalizado em E.164. Guarda também
  o telefone original do CSV, para investigar linhas rejeitadas.
- **Importação** registra o resultado de cada carga: linhas lidas,
  válidas e inválidas.
- **Telefone** é value object. A base vem suja, com máscara, sem DDD e
  com oito ou nove dígitos; isolar a normalização evita espalhar
  tratamento de string pelo código.

Duas invariantes são garantidas no banco, não em código de aplicação:

- Apenas uma campanha em execução por vez, via índice único parcial
  sobre o estado. Uma verificação condicional no serviço não resolve,
  porque duas requisições simultâneas a atravessam juntas.
- Nenhum contato recebe duas mensagens na mesma campanha, via índice
  único sobre o par campanha e contato.

Diagramas e detalhamento em [docs](docs/).

## Stack

Java 25, Spring Boot 4.1, Spring Data JPA, Spring Security, PostgreSQL
16, Flyway, Docker Compose, JUnit 5 e Mockito.

## Como rodar

Requisitos: JDK 25 ou superior e Docker.

```bash
git clone https://github.com/thomasgoncalves-dev/whats-recovery.git
cd whats-recovery

docker compose up -d

cd backend
./mvnw spring-boot:run
```

O Flyway cria o esquema na primeira subida. A aplicação sobe em
`http://localhost:8080`.

Não será necessário um número de WhatsApp real para executar o
projeto: o gateway fica atrás de uma interface ([ADR 0005](docs/adr/05-gateway-whatsapp.md)),
com uma implementação fake por padrão em desenvolvimento, simulando
latência, sucesso e falha sem sair da máquina; a implementação real é
ativada por profile. Esse componente ainda não foi implementado — veja
"Motor de disparo" na tabela de status acima.

Para recriar o banco do zero:

```bash
docker compose down -v && docker compose up -d
```

## Dados

O repositório não contém base real de clientes. Arquivos chamados
`teste-contatos.csv` estão no `.gitignore`; o exemplo em
[docs/teste-contatos.csv](docs/teste-contatos.csv), sintético, foi
versionado à parte. Telefones de clientes são dado pessoal de terceiro
e não vão para repositório público.
