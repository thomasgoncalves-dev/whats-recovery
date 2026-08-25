create table usuario (
    id bigint generated always as identity primary key,
    nome varchar(120) not null,
    email varchar(160) not null,
    senha_hash varchar(72) not null,
    papel varchar(20) not null,
    ativo boolean not null default true,
    criado_em timestamptz not null default now(),
    constraint uk_usuario_email unique (email),
    constraint ck_usuario_papel check (papel in ('ADMIN', 'USER'))
);

create table importacao (
    id bigint generated always as identity primary key,
    nome_arquivo varchar(255) not null,
    linhas_lidas integer not null,
    linhas_validas integer not null,
    linhas_invalidas integer not null,
    importado_por_id bigint not null references usuario(id),
    criado_em timestamptz not null default now(),
    constraint ck_importacao_linhas
        check (linhas_validas + linhas_invalidas <= linhas_lidas)
);

create table contato (
    id bigint generated always as identity primary key,
    nome varchar(160) not null,
    telefone varchar(16) not null,
    telefone_original varchar(40) not null,
    opt_out boolean not null default false,
    importacao_id bigint not null references importacao (id),
    criado_em timestamptz not null default now(),
    constraint uk_contato_telefone unique (telefone),
    constraint ck_contato_telefone_e164 check (telefone ~ '^\+[1-9][0-9]{7,14}$')
);

create table campanha (
    id bigint generated always as identity primary key,
    mensagem text not null,
    status varchar(20) not null,
    criado_por_id bigint not null references usuario(id),
    total_destinatarios integer not null default 0,
    criado_em timestamptz not null default now(),
    iniciado_em timestamptz,
    finalizado_em timestamptz,
    constraint ck_campanha_status check (
        status in ('RASCUNHO', 'EM_EXECUCAO', 'PAUSADA', 'CONCLUIDA', 'CANCELADA')
    ),
    constraint ck_campanha_mensagem check (length(trim(mensagem)) > 0)
);

-- RN01: apenas uma campanha em execução por vez.
-- indice unico parcial: todas as linhas filtradas tem o mesmo
-- valor em status, logo o banco permite no maximo uma.
create unique index uk_campanha_unica_em_execucao
    on campanha (status)
    where status = 'EM_EXECUCAO';

create table envio (
    id bigint generated always as identity primary key,
    campanha_id bigint not null references campanha (id),
    contato_id bigint not null references contato (id),
    status varchar(20) not null default 'PENDENTE',
    tentativas smallint not null default 0,
    id_externo_mensagem varchar(120),
    mensagem_erro varchar(500),
    criado_em timestamptz not null default now(),
    atualizado_em timestamptz not null default now(),
    proxima_tentativa_em timestamptz,
    enviado_em timestamptz,
    constraint uk_envio_campanha_contato unique (campanha_id, contato_id),
    constraint ck_envio_status check (
        status in ('PENDENTE', 'ENVIANDO', 'ENVIADO', 'ENTREGUE', 'FALHA')
    ),
    constraint ck_envio_tentativas check (tentativas >= 0)
);

-- consulta do despachante: proximo lote elegivel
create index ix_envio_fila
    on envio (campanha_id, proxima_tentativa_em)
    where status = 'PENDENTE';

-- deteccao de envio travado em ENVIANDO apos queda da aplicacao
create index ix_envio_travado
    on envio (atualizado_em)
    where status = 'ENVIANDO';

-- agregacao do dashboard (RF07)
create index ix_envio_campanha_status on envio (campanha_id, status);