-- =====================================================================
-- Fila Já - 06: triggers (todos AFTER UPDATE na tabela fila)
-- =====================================================================
USE fila_ja;

DELIMITER $$

-- Auditoria: grava toda mudança de status em historico_fila.
DROP TRIGGER IF EXISTS trg_historico_status_fila$$
CREATE TRIGGER trg_historico_status_fila
AFTER UPDATE ON fila
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO historico_fila
            (id_historico, id_fila, id_usuario, status_anterior, status_novo)
        VALUES
            (gerar_id('historico_fila'), NEW.id_fila, NEW.id_usuario,
             OLD.status, NEW.status);
    END IF;
END$$

-- Ao entrar em EM_ATENDIMENTO, abre automaticamente o registro de atendimento.
DROP TRIGGER IF EXISTS trg_iniciar_atendimento$$
CREATE TRIGGER trg_iniciar_atendimento
AFTER UPDATE ON fila
FOR EACH ROW
BEGIN
    IF OLD.status <> 'EM_ATENDIMENTO' AND NEW.status = 'EM_ATENDIMENTO' THEN
        INSERT INTO atendimentos
            (id_atendimento, id_fila, id_usuario, data_inicio)
        VALUES
            (gerar_id('atendimentos'), NEW.id_fila, NEW.id_usuario,
             CURRENT_TIMESTAMP);
    END IF;
END$$

-- Ao entrar em FINALIZADO, registra o horário de término do atendimento.
DROP TRIGGER IF EXISTS trg_finalizar_atendimento$$
CREATE TRIGGER trg_finalizar_atendimento
AFTER UPDATE ON fila
FOR EACH ROW
BEGIN
    IF OLD.status <> 'FINALIZADO' AND NEW.status = 'FINALIZADO' THEN
        UPDATE atendimentos
           SET data_fim = CURRENT_TIMESTAMP
         WHERE id_fila = NEW.id_fila;
    END IF;
END$$

DELIMITER ;
