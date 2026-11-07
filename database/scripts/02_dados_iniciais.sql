USE fila_ja;

SELECT 'Grupos de usuários' AS tabela, COUNT(*) AS total
FROM grupos_usuarios

UNION ALL

SELECT 'Usuários', COUNT(*)
FROM usuarios

UNION ALL

SELECT 'Pacientes', COUNT(*)
FROM pacientes

UNION ALL

SELECT 'UBS', COUNT(*)
FROM ubs

UNION ALL

SELECT 'Serviços', COUNT(*)
FROM servicos

UNION ALL

SELECT 'Serviços por UBS', COUNT(*)
FROM ubs_servico;
