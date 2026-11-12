-- =====================================================================
-- Fila Já - 03: funções
--  * gerar_id        -> geração de IDs (substitui AUTO_INCREMENT)
--  * fn_contar_fila  -> quantos pacientes aguardam um serviço numa UBS
--  * fn_tempo_espera -> minutos de espera desde a entrada na fila
-- =====================================================================
USE fila_ja;

-- gerar_id grava na tabela "sequencias" e, com o log binário ligado (padrão do
-- MySQL 8), o servidor recusa criar funções que alteram dados sem a declaração
-- DETERMINISTIC (erro 1418). Esta opção libera a criação para este projeto.
-- Requer privilégio administrativo (rodar como root/admin).
SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER $$

-- Gera o próximo ID de uma entidade de forma atômica: o UPDATE trava a linha da
-- entidade e LAST_INSERT_ID(expr) guarda o valor na sessão, sem condição de corrida
-- entre dois usuários. Se for chamada dentro de uma transação que sofre ROLLBACK,
-- o ID é devolvido (não gera "buracos").
DROP FUNCTION IF EXISTS gerar_id$$
CREATE FUNCTION gerar_id(p_entidade VARCHAR(50))
RETURNS INT
MODIFIES SQL DATA
BEGIN
    UPDATE sequencias
       SET proximo_id = LAST_INSERT_ID(proximo_id + 1)
     WHERE entidade = p_entidade;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Entidade não encontrada em sequencias';
    END IF;

    RETURN LAST_INSERT_ID() - 1;
END$$

-- Lê dados da tabela fila, por isso é READS SQL DATA (não DETERMINISTIC).
DROP FUNCTION IF EXISTS fn_contar_fila$$
CREATE FUNCTION fn_contar_fila(p_id_ubs INT, p_id_servico INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
      INTO v_total
      FROM fila
     WHERE id_ubs = p_id_ubs
       AND id_servico = p_id_servico
       AND status = 'AGUARDANDO';

    RETURN v_total;
END$$

DROP FUNCTION IF EXISTS fn_tempo_espera$$
CREATE FUNCTION fn_tempo_espera(p_id_fila INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_tempo INT;

    SELECT TIMESTAMPDIFF(MINUTE, data_entrada, CURRENT_TIMESTAMP)
      INTO v_tempo
      FROM fila
     WHERE id_fila = p_id_fila;

    RETURN v_tempo;
END$$

DELIMITER ;
