-- TESTE 1: CONFERIR OS USUÁRIOS

SELECT
    User,
    Host
FROM mysql.user
WHERE User IN (
    'admin_fila',
    'atendente_fila',
    'profissional_fila'
);


-- TESTE 2: CONFERIR PERMISSÕES DO ADMINISTRADOR

SHOW GRANTS FOR 'admin_fila'@'localhost';


-- TESTE 3: CONFERIR PERMISSÕES DO ATENDENTE

SHOW GRANTS FOR 'atendente_fila'@'localhost';


-- TESTE 4: CONFERIR PERMISSÕES DO PROFISSIONAL

SHOW GRANTS FOR 'profissional_fila'@'localhost';