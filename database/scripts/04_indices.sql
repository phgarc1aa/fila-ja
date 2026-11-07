USE fila_ja;

SHOW INDEX FROM fila;

EXPLAIN
SELECT id_fila, senha, status
FROM fila
WHERE id_ubs = 3
  AND id_servico = 4
  AND status = 'AGUARDANDO';

EXPLAIN
SELECT id_fila, senha, data_entrada
FROM fila
ORDER BY data_entrada;