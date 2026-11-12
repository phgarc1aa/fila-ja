-- =====================================================================
-- Fila Já - 01: criação do banco e das tabelas
-- Executar como administrador do MySQL (ex.: root). O root é usado SOMENTE
-- para instalar o banco; a aplicação nunca usa o root (ver 08_usuarios_permissoes.sql).
-- Ordem de execução: 01 -> 02 -> 03 -> 04 -> 05 -> 06 -> 07 -> 08
-- =====================================================================

DROP DATABASE IF EXISTS fila_ja;
CREATE DATABASE fila_ja
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE fila_ja;

-- Grupos de usuários: base do controle de permissões do sistema.
CREATE TABLE grupos_usuarios (
    id_grupo   INT          NOT NULL,
    nome       VARCHAR(50)  NOT NULL,
    descricao  VARCHAR(255) NULL,
    PRIMARY KEY (id_grupo),
    UNIQUE KEY uk_grupos_nome (nome)
) ENGINE=InnoDB;

-- Usuários do sistema (funcionários); cada um pertence a um grupo.
CREATE TABLE usuarios (
    id_usuario INT          NOT NULL,
    nome       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL,
    senha      VARCHAR(255) NOT NULL,
    id_grupo   INT          NOT NULL,
    ativo      TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (id_usuario),
    UNIQUE KEY uk_usuarios_email (email),
    KEY fk_usuarios_grupos (id_grupo),
    CONSTRAINT fk_usuarios_grupos
        FOREIGN KEY (id_grupo) REFERENCES grupos_usuarios (id_grupo)
) ENGINE=InnoDB;

CREATE TABLE pacientes (
    id_paciente     INT          NOT NULL,
    nome            VARCHAR(100) NOT NULL,
    cpf             CHAR(11)     NOT NULL,
    data_nascimento DATE         NOT NULL,
    telefone        VARCHAR(20)  NULL,
    email           VARCHAR(100) NULL,
    data_cadastro   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_paciente),
    UNIQUE KEY uk_pacientes_cpf (cpf)
) ENGINE=InnoDB;

CREATE TABLE ubs (
    id_ubs   INT          NOT NULL,
    nome     VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    telefone VARCHAR(20)  NULL,
    ativo    TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (id_ubs)
) ENGINE=InnoDB;

CREATE TABLE servicos (
    id_servico INT          NOT NULL,
    nome       VARCHAR(100) NOT NULL,
    descricao  VARCHAR(255) NULL,
    ativo      TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (id_servico),
    UNIQUE KEY uk_servicos_nome (nome)
) ENGINE=InnoDB;

-- Relação N:N entre UBS e serviços oferecidos.
CREATE TABLE ubs_servico (
    id_ubs     INT NOT NULL,
    id_servico INT NOT NULL,
    PRIMARY KEY (id_ubs, id_servico),
    KEY fk_ubs_servico_servicos (id_servico),
    CONSTRAINT fk_ubs_servico_ubs
        FOREIGN KEY (id_ubs) REFERENCES ubs (id_ubs),
    CONSTRAINT fk_ubs_servico_servicos
        FOREIGN KEY (id_servico) REFERENCES servicos (id_servico)
) ENGINE=InnoDB;

-- Contador por entidade, usado pela função gerar_id() no lugar de AUTO_INCREMENT.
CREATE TABLE sequencias (
    entidade   VARCHAR(50) NOT NULL,
    proximo_id INT         NOT NULL DEFAULT 1,
    PRIMARY KEY (entidade)
) ENGINE=InnoDB;

CREATE TABLE fila (
    id_fila      INT         NOT NULL,
    id_paciente  INT         NOT NULL,
    id_ubs       INT         NOT NULL,
    id_servico   INT         NOT NULL,
    id_usuario   INT         NOT NULL,
    senha        VARCHAR(20) NOT NULL,
    data_entrada DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status       ENUM('AGUARDANDO','CHAMADO','EM_ATENDIMENTO','FINALIZADO','CANCELADO')
                 NOT NULL DEFAULT 'AGUARDANDO',
    PRIMARY KEY (id_fila),
    UNIQUE KEY uk_fila_ubs_senha (id_ubs, senha),
    KEY fk_fila_paciente (id_paciente),
    KEY fk_fila_usuario (id_usuario),
    CONSTRAINT fk_fila_paciente
        FOREIGN KEY (id_paciente) REFERENCES pacientes (id_paciente),
    CONSTRAINT fk_fila_ubs_servico
        FOREIGN KEY (id_ubs, id_servico) REFERENCES ubs_servico (id_ubs, id_servico),
    CONSTRAINT fk_fila_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE atendimentos (
    id_atendimento INT      NOT NULL,
    id_fila        INT      NOT NULL,
    id_usuario     INT      NOT NULL,
    data_inicio    DATETIME NULL,
    data_fim       DATETIME NULL,
    observacoes    TEXT     NULL,
    PRIMARY KEY (id_atendimento),
    UNIQUE KEY uk_atendimentos_fila (id_fila),
    KEY fk_atendimentos_usuario (id_usuario),
    CONSTRAINT fk_atendimentos_fila
        FOREIGN KEY (id_fila) REFERENCES fila (id_fila),
    CONSTRAINT fk_atendimentos_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario)
) ENGINE=InnoDB;

-- Auditoria das mudanças de status da fila (preenchida por trigger).
CREATE TABLE historico_fila (
    id_historico    INT         NOT NULL,
    id_fila         INT         NOT NULL,
    id_usuario      INT         NOT NULL,
    status_anterior VARCHAR(20) NULL,
    status_novo     VARCHAR(20) NOT NULL,
    data_alteracao  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_historico),
    KEY fk_historico_fila (id_fila),
    KEY fk_historico_usuario (id_usuario),
    CONSTRAINT fk_historico_fila
        FOREIGN KEY (id_fila) REFERENCES fila (id_fila),
    CONSTRAINT fk_historico_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario)
) ENGINE=InnoDB;
