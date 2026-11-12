-- =====================================================================
-- Fila Já - demonstração de controle de transações (TCL) para a apresentação
-- Rodar logado como admin_fila (o atendente não tem acesso à tabela sequencias,
-- de propósito). Este script ALTERA dados.
-- (O último CALL gera um erro de propósito: é a demonstração do ROLLBACK.)
-- =====================================================================
USE fila_ja;

-- ---- Cenário 1: ROLLBACK manual (nada fica gravado, nem o ID gerado) ----
SELECT proximo_id AS proximo_id_pacientes_antes FROM sequencias WHERE entidade = 'pacientes';
SELECT COUNT(*) AS pacientes_antes FROM pacientes;

START TRANSACTION;
INSERT INTO pacientes (id_paciente, nome, cpf, data_nascimento)
VALUES (gerar_id('pacientes'), 'Paciente Teste TCL', '99999999999', '2000-01-01');
SELECT COUNT(*) AS pacientes_dentro_da_transacao FROM pacientes;
ROLLBACK;

SELECT COUNT(*) AS pacientes_depois_do_rollback FROM pacientes;
SELECT proximo_id AS proximo_id_pacientes_depois FROM sequencias WHERE entidade = 'pacientes';

-- ---- Cenário 2: COMMIT por uma procedure (entrada na fila) ----
CALL sp_entrar_na_fila(2, 2, 2, 4, @id_fila, @senha);
SELECT @id_fila AS id_fila, @senha AS senha;
SELECT * FROM vw_fila_atendimento WHERE id_fila = @id_fila;

-- ---- Cenário 3: erro dentro da procedure -> ROLLBACK automático ----
-- O mesmo paciente já tem senha ativa nesse serviço: a procedure dispara o erro,
-- o handler executa ROLLBACK e nenhuma senha nem ID novo é consumido.
SELECT proximo_id AS proximo_id_fila_antes FROM sequencias WHERE entidade = 'fila';
CALL sp_entrar_na_fila(2, 2, 2, 4, @id_fila2, @senha2);
