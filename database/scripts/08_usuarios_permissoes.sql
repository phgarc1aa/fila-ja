-- =====================================================================
-- Fila Já - 08: usuários do MySQL e controle de acesso (DCL)
-- Executar como administrador (root) - o root só instala; a aplicação
-- conecta com 'atendente_fila' e NUNCA com o root.
--
-- Estratégia (privilégio mínimo):
--  * admin_fila        - administração do banco fila_ja (DBA da aplicação).
--  * atendente_fila    - usuário usado pelo backend: lê cadastros, grava
--                        pacientes/UBS, muda status da fila e executa as
--                        procedures/funções. Sem DELETE, sem DDL, sem acesso
--                        às tabelas de controle (sequencias, historico_fila,
--                        atendimentos).
--  * profissional_fila - somente consulta (views) e finalização de atendimento.
--
-- As procedures/triggers/views são criadas por quem roda os scripts (SQL
-- SECURITY DEFINER, o padrão), então o usuário da aplicação consegue usá-los
-- sem precisar de permissão direta nas tabelas que eles alteram.
--
-- IMPORTANTE: troque as senhas abaixo antes de usar fora de ambiente de aula
-- e repita a senha no application.properties (ver application.properties.example).
-- =====================================================================

CREATE USER IF NOT EXISTS 'admin_fila'@'localhost'        IDENTIFIED BY 'Adm!Fila#2026';
CREATE USER IF NOT EXISTS 'atendente_fila'@'localhost'    IDENTIFIED BY 'Atd!Fila#2026';
CREATE USER IF NOT EXISTS 'profissional_fila'@'localhost' IDENTIFIED BY 'Prof!Fila#2026';

-- Garante as senhas acima mesmo se os usuários já existiam.
ALTER USER 'admin_fila'@'localhost'        IDENTIFIED BY 'Adm!Fila#2026';
ALTER USER 'atendente_fila'@'localhost'    IDENTIFIED BY 'Atd!Fila#2026';
ALTER USER 'profissional_fila'@'localhost' IDENTIFIED BY 'Prof!Fila#2026';

-- Recomeça do zero para o script poder ser executado várias vezes.
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'admin_fila'@'localhost';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'atendente_fila'@'localhost';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'profissional_fila'@'localhost';

-- ---------- Administrador: tudo, mas só no banco fila_ja ----------
GRANT ALL PRIVILEGES ON fila_ja.* TO 'admin_fila'@'localhost';

-- ---------- Atendente (usuário da aplicação) ----------
GRANT SELECT ON fila_ja.pacientes          TO 'atendente_fila'@'localhost';
GRANT SELECT ON fila_ja.ubs                TO 'atendente_fila'@'localhost';
GRANT SELECT ON fila_ja.servicos           TO 'atendente_fila'@'localhost';
GRANT SELECT ON fila_ja.fila               TO 'atendente_fila'@'localhost';
GRANT SELECT (id_usuario, email) ON fila_ja.usuarios TO 'atendente_fila'@'localhost';
GRANT SELECT ON fila_ja.vw_fila_atendimento TO 'atendente_fila'@'localhost';
GRANT SELECT ON fila_ja.vw_atendimentos     TO 'atendente_fila'@'localhost';

GRANT INSERT         ON fila_ja.pacientes TO 'atendente_fila'@'localhost';
GRANT INSERT, UPDATE ON fila_ja.ubs       TO 'atendente_fila'@'localhost';
GRANT UPDATE (status) ON fila_ja.fila     TO 'atendente_fila'@'localhost';

GRANT EXECUTE ON FUNCTION  fila_ja.gerar_id                TO 'atendente_fila'@'localhost';
GRANT EXECUTE ON FUNCTION  fila_ja.fn_contar_fila          TO 'atendente_fila'@'localhost';
GRANT EXECUTE ON FUNCTION  fila_ja.fn_tempo_espera         TO 'atendente_fila'@'localhost';
GRANT EXECUTE ON PROCEDURE fila_ja.sp_entrar_na_fila       TO 'atendente_fila'@'localhost';
GRANT EXECUTE ON PROCEDURE fila_ja.sp_chamar_paciente      TO 'atendente_fila'@'localhost';
GRANT EXECUTE ON PROCEDURE fila_ja.sp_finalizar_atendimento TO 'atendente_fila'@'localhost';

-- ---------- Profissional de saúde: consulta e finaliza ----------
GRANT SELECT ON fila_ja.vw_fila_atendimento TO 'profissional_fila'@'localhost';
GRANT SELECT ON fila_ja.vw_atendimentos     TO 'profissional_fila'@'localhost';
GRANT EXECUTE ON FUNCTION  fila_ja.fn_contar_fila           TO 'profissional_fila'@'localhost';
GRANT EXECUTE ON FUNCTION  fila_ja.fn_tempo_espera          TO 'profissional_fila'@'localhost';
GRANT EXECUTE ON PROCEDURE fila_ja.sp_finalizar_atendimento TO 'profissional_fila'@'localhost';
