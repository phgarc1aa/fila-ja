-- =====================================================================
-- Fila Já - 07: stored procedures (com controle de transação - TCL)
--
-- Padrão usado nas três procedures:
--   START TRANSACTION ... COMMIT;
--   DECLARE EXIT HANDLER FOR SQLEXCEPTION -> ROLLBACK + RESIGNAL
-- Qualquer erro no meio da operação desfaz tudo (atomicidade) e o erro volta
-- para a aplicação.
--
-- As procedures rodam com os privilégios de quem as criou (SQL SECURITY
-- DEFINER, o padrão). Por isso o usuário da aplicação só precisa de EXECUTE,
-- sem acesso direto às tabelas de controle (ver 08_usuarios_permissoes.sql).
-- =====================================================================
USE fila_ja;

DELIMITER $$

-- Entrada na fila: valida, gera o ID e a senha e insere, tudo numa transação.
-- O SELECT ... FOR UPDATE na UBS serializa quem emite senha na mesma unidade,
-- evitando duas senhas iguais quando dois atendentes cadastram ao mesmo tempo.
DROP PROCEDURE IF EXISTS sp_entrar_na_fila$$
CREATE PROCEDURE sp_entrar_na_fila(
    IN  p_id_paciente INT,
    IN  p_id_ubs      INT,
    IN  p_id_servico  INT,
    IN  p_id_usuario  INT,
    OUT p_id_fila     INT,
    OUT p_senha       VARCHAR(20)
)
BEGIN
    DECLARE v_ubs      INT DEFAULT NULL;
    DECLARE v_prefixo  CHAR(1);
    DECLARE v_numero   INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT id_ubs INTO v_ubs
      FROM ubs
     WHERE id_ubs = p_id_ubs AND ativo = 1
       FOR UPDATE;

    IF v_ubs IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UBS inexistente ou inativa';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pacientes WHERE id_paciente = p_id_paciente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Paciente não encontrado';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM ubs_servico us
          INNER JOIN servicos s ON s.id_servico = us.id_servico
         WHERE us.id_ubs = p_id_ubs
           AND us.id_servico = p_id_servico
           AND s.ativo = 1
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Serviço indisponível nesta UBS';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM fila
         WHERE id_paciente = p_id_paciente
           AND id_ubs = p_id_ubs
           AND id_servico = p_id_servico
           AND status IN ('AGUARDANDO', 'CHAMADO', 'EM_ATENDIMENTO')
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Paciente já possui senha ativa neste serviço';
    END IF;

    -- Prefixo da senha: A, B, C... conforme a posição da UBS (por id).
    SELECT CHAR(65 + MOD(COUNT(*), 26) USING utf8mb4)
      INTO v_prefixo
      FROM ubs
     WHERE id_ubs < p_id_ubs;

    SELECT COALESCE(MAX(CAST(SUBSTRING(senha, 2) AS UNSIGNED)), 0) + 1
      INTO v_numero
      FROM fila
     WHERE id_ubs = p_id_ubs
       AND senha LIKE CONCAT(v_prefixo, '%');

    SET p_id_fila = gerar_id('fila');
    SET p_senha   = CONCAT(v_prefixo, LPAD(v_numero, 3, '0'));

    INSERT INTO fila
        (id_fila, id_paciente, id_ubs, id_servico, id_usuario, senha, status)
    VALUES
        (p_id_fila, p_id_paciente, p_id_ubs, p_id_servico, p_id_usuario,
         p_senha, 'AGUARDANDO');

    COMMIT;
END$$

-- Chama o próximo paciente (o mais antigo AGUARDANDO). A linha fica travada
-- (FOR UPDATE) até o COMMIT, então dois atendentes não chamam o mesmo paciente.
DROP PROCEDURE IF EXISTS sp_chamar_paciente$$
CREATE PROCEDURE sp_chamar_paciente(
    IN p_id_ubs     INT,
    IN p_id_servico INT
)
BEGIN
    DECLARE v_id_fila INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT id_fila
      INTO v_id_fila
      FROM fila
     WHERE id_ubs = p_id_ubs
       AND id_servico = p_id_servico
       AND status = 'AGUARDANDO'
     ORDER BY data_entrada ASC, id_fila ASC
     LIMIT 1
       FOR UPDATE;

    IF v_id_fila IS NULL THEN
        COMMIT;
        SELECT 'Não existem pacientes aguardando.' AS mensagem;
    ELSE
        UPDATE fila
           SET status = 'CHAMADO'
         WHERE id_fila = v_id_fila;

        COMMIT;

        SELECT
            f.id_fila,
            f.senha,
            p.nome AS paciente,
            u.nome AS ubs,
            s.nome AS servico,
            f.status
        FROM fila f
        INNER JOIN pacientes p ON f.id_paciente = p.id_paciente
        INNER JOIN ubs       u ON f.id_ubs      = u.id_ubs
        INNER JOIN servicos  s ON f.id_servico  = s.id_servico
        WHERE f.id_fila = v_id_fila;
    END IF;
END$$

-- Finaliza o atendimento: o UPDATE dispara os triggers de histórico e de data_fim;
-- se qualquer um falhar, tudo é desfeito.
DROP PROCEDURE IF EXISTS sp_finalizar_atendimento$$
CREATE PROCEDURE sp_finalizar_atendimento(
    IN p_id_fila INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
          FROM atendimentos
         WHERE id_fila = p_id_fila
           AND data_fim IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Atendimento não encontrado ou já finalizado';
    END IF;

    UPDATE fila
       SET status = 'FINALIZADO'
     WHERE id_fila = p_id_fila;

    COMMIT;
END$$

DELIMITER ;
