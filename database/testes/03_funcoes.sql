USE fila_ja;

SELECT gerar_id('pacientes') AS proximo_id_paciente;

SELECT fn_contar_fila(3, 4) AS pacientes_aguardando;

SELECT fn_tempo_espera(5) AS tempo_espera_minutos;

SHOW FUNCTION STATUS
WHERE Db = 'fila_ja';