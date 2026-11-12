-- Dados de demonstração: alguns pacientes na fila (usa a procedure transacional).
USE fila_ja;
CALL sp_entrar_na_fila(3, 2, 3, 4, @a, @b);
CALL sp_entrar_na_fila(4, 3, 4, 4, @a, @b);
CALL sp_entrar_na_fila(5, 3, 5, 4, @a, @b);
CALL sp_entrar_na_fila(6, 2, 6, 4, @a, @b);
