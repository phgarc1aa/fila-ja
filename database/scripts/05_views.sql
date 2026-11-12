-- =====================================================================
-- Fila Já - 05: views
-- =====================================================================
USE fila_ja;

-- Painel da fila: junta fila + paciente + UBS + serviço, escondendo as junções
-- da aplicação. Inclui id_ubs e id_servico (usados pelo botão "Chamar") e o
-- horário formatado de entrada.
CREATE OR REPLACE VIEW vw_fila_atendimento AS
SELECT
    f.id_fila,
    f.id_ubs,
    f.id_servico,
    f.senha,
    p.nome  AS paciente,
    u.nome  AS ubs,
    s.nome  AS servico,
    f.status,
    DATE_FORMAT(f.data_entrada, '%H:%i') AS horario,
    f.data_entrada
FROM fila f
INNER JOIN pacientes p ON f.id_paciente = p.id_paciente
INNER JOIN ubs       u ON f.id_ubs      = u.id_ubs
INNER JOIN servicos  s ON f.id_servico  = s.id_servico;

-- Histórico de atendimentos: une atendimento, paciente, UBS, serviço e o
-- profissional responsável, sem expor as tabelas base à aplicação.
CREATE OR REPLACE VIEW vw_atendimentos AS
SELECT
    a.id_atendimento,
    p.nome  AS paciente,
    u.nome  AS ubs,
    s.nome  AS servico,
    us.nome AS profissional,
    a.data_inicio,
    a.data_fim,
    a.observacoes
FROM atendimentos a
INNER JOIN fila      f  ON a.id_fila     = f.id_fila
INNER JOIN pacientes p  ON f.id_paciente = p.id_paciente
INNER JOIN ubs       u  ON f.id_ubs      = u.id_ubs
INNER JOIN servicos  s  ON f.id_servico  = s.id_servico
INNER JOIN usuarios  us ON a.id_usuario  = us.id_usuario;
